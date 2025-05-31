import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
static const String baseUrl = 'http://10.0.2.2:8000/api';
 
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    var url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-password': 'sabjs@1008',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)};
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    var url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-password': 'sabjs@1008',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)};
    }
  }

  static Future<Map<String, dynamic>> getUser(String token) async {
    var url = Uri.parse('$baseUrl/user');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'x-api-password': 'sabjs@1008',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': 'Unauthorized'};
    }
  }

  static Future<List<dynamic>> getAllUsers(String token) async {
    final url = Uri.parse('$baseUrl/users');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'x-api-password': 'sabjs@1008',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['users'];
    } else {
      return [];
    }
  }

  /// ✅ DELETE user
  static Future<bool> deleteUser(int id, String token) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'x-api-password': 'sabjs@1008',
      },
    );

    return response.statusCode == 200;
  }

  /// ✅ UPDATE user
  static Future<bool> updateUser(
      int id, String name, String email, String token) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'x-api-password': 'sabjs@1008',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
      }),
    );

    return response.statusCode == 200;
  }
}
