import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'user_preferences_manager.dart';

class AuthService {
  final _prefsManager = UserPreferencesManager.instance;

  Future<bool> login(String persno, String password) async {
    final url = Uri.parse('$API_BASE_URL/Auth/login');
    final response = await http.post(
      url,
      body: jsonEncode({'pers_no': persno, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']; // Assuming the API returns a token

      // Save token and automatically parse user data
      await _prefsManager.saveToken(token);

      return true;
    } else {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    // Check if token exists and is not expired
    final hasToken = await _prefsManager.hasToken();
    if (!hasToken) return false;

    final isExpired = await _prefsManager.isTokenExpired();
    if (isExpired) {
      await logout(); // Clean up expired token
      return false;
    }

    // Validate token with backend
    final token = await _prefsManager.getToken();
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse("$API_BASE_URL/employee/validate-token"),
        headers: {
          "token": token,
          "Content-Type": "application/json"
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _prefsManager.logout();
  }
}

