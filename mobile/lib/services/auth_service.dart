import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_info';
  
  // 10.0.2.2 maps to host machine's localhost when running on Android Emulator
  static String _baseUrl = 'http://10.0.2.2:8000/api'; 

  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  static String get baseUrl => _baseUrl;

  // Log in user — MUST use x-www-form-urlencoded for FastAPI OAuth2PasswordRequestForm
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, jsonEncode(user));

        return {'success': true, 'user': user};
      } else {
        String errorMsg = 'Identifiants incorrects';
        try {
          errorMsg = jsonDecode(response.body)['detail'] ?? errorMsg;
        } catch (_) {}
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      return {'success': false, 'error': 'Impossible de se connecter au serveur: $e'};
    }
  }

  // Log out user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Get active session token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get current user profile info
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Get HTTP headers with Authorization token
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
