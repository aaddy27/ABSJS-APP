import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/network_helper.dart';

class ApiService {
  final String baseUrl = 'https://mrmapi.sadhumargi.in/api';
  
  // Add retry mechanism
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() requestFunction,
    {int maxRetries = 3}
  ) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        return await requestFunction().timeout(const Duration(seconds: 30));
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          rethrow;
        }
        // Wait before retry
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    throw Exception('Max retries exceeded');
  }

  /// Login using member_id and password
  Future<Map<String, dynamic>> loginWithMemberId(String memberId, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'login': memberId,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('member_id', data['member_id'].toString());
        await prefs.setString('family_id', data['family_id'].toString());
        await prefs.setBool('is_head_of_family', data['is_head_of_family']);

        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Invalid credentials'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong. Please try again.'};
    }
  }

/// Step 1: check mobile
Future<Map<String, dynamic>> checkMobile(String mobile) async {
  final url = Uri.parse('$baseUrl/check-mobile');

  try {
    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'mobile': mobile},
    );

    final data = json.decode(response.body);
    print("checkMobile() API RAW Response: $data");

    if (data.containsKey('member_id')) {
      return {
        'success': true,
        'single': true,
        'members': [
          {'member_id': data['member_id'], 'name': 'Member'}
        ],
        'message': data['message'] ?? '',
      };
    } else if (data.containsKey('members')) {
      return {
        'success': true,
        'single': false,
        'members': List<Map<String, dynamic>>.from(data['members']),
        'message': data['message'] ?? '',
      };
    } else {
      return {
        'success': false,
        'members': [],
        'message': data['message'] ?? 'No members found.',
      };
    }
  } catch (e) {
    print("checkMobile() error: $e");
    return {'success': false, 'message': 'Something went wrong while checking mobile.'};
  }
}




/// Step 2: Send OTP
Future<Map<String, dynamic>> sendOTP(String mobile, String memberId) async {
  final url = Uri.parse('$baseUrl/send-otp');

  try {
    print("Sending OTP request to: $url");
    print("Mobile: $mobile, Member ID: $memberId");
    
    final response = await _makeRequest(() => http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'mobile_number': mobile,
        'member_id': memberId,
      },
    ));

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': data['status'] == true || data['success'] == true,
        'message': data['message'] ?? 'OTP sent successfully',
      };
    } else {
      final error = json.decode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Failed to send OTP. Server error.',
      };
    }
  } catch (e) {
    print("SendOTP Error: $e");
    String errorMessage = NetworkHelper.getNetworkErrorMessage(e);
    
    return {
      'success': false,
      'message': errorMessage,
    };
  }
}
  
/// Step 3: Verify OTP
Future<Map<String, dynamic>> verifyOTP(String mobile, String otp, String memberId) async {
  final url = Uri.parse('$baseUrl/verify-otp');

  try {
    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'mobile_number': mobile, // ✅ corrected key
        'otp': otp,
        'member_id': memberId,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return {'success': true, 'data': data};
    } else {
      final error = json.decode(response.body);
      return {'success': false, 'message': error['message'] ?? 'OTP verification failed'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Something went wrong during OTP verification'};
  }
}


}
