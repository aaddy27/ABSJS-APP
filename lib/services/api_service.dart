import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://mrmapi.sadhumargi.in/api';

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
    print("checkMobile() API RAW Response: $data"); // 🔍 debug log

    // Return the 'members' list correctly
    return {
      'success': response.statusCode == 200 && data['members'] != null,
      'members': data['members'] ?? [],
      'message': data['message'] ?? '',
    };
  } catch (e) {
    print("checkMobile() error: $e"); // debug
    return {'success': false, 'message': 'Something went wrong while checking mobile.'};
  }
}



/// Step 2: Send OTP
Future<Map<String, dynamic>> sendOTP(String mobile, String memberId) async {
  final url = Uri.parse('$baseUrl/send-otp');

  try {
    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'mobile_number': mobile, // ✅ correct key
        'member_id': memberId,   // if required
      },
    );

    final data = json.decode(response.body);
    return {
      'success': data['status'] == true,
      'message': data['message'] ?? '',
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Something went wrong while sending OTP.',
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
