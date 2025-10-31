import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkHelper {
  
  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if specific host is reachable
  static Future<bool> canReachHost(String host) async {
    try {
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Test API endpoint connectivity
  static Future<Map<String, dynamic>> testApiConnection(String baseUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'API is reachable'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'API connection failed: ${e.toString()}'
      };
    }
  }

  /// Get network error message based on error type
  static String getNetworkErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('resolve host') || errorString.contains('bulksms')) {
      return 'SMS service temporarily unavailable. Please try again later.';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorString.contains('socket')) {
      return 'Connection failed. Please check your internet connection.';
    } else if (errorString.contains('certificate') || errorString.contains('ssl')) {
      return 'Security certificate error. Please try again.';
    } else if (errorString.contains('connection refused')) {
      return 'Server connection refused. Please try again later.';
    }
    
    return 'Network error. Please check your internet connection and try again.';
  }
}