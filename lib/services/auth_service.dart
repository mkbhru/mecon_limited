import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'user_preferences_manager.dart';

class AuthService {
  final _prefsManager = UserPreferencesManager.instance;
  String? lastError;

  Future<bool> login(String persno, String password) async {
    lastError = null; // Reset error

    try {
      final url = Uri.parse('$API_BASE_URL/Auth/login');
      final response = await http.post(
        url,
        body: jsonEncode({'pers_no': persno, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']; // Assuming the API returns a token

        // Save token and automatically parse user data
        await _prefsManager.saveToken(token);

        return true;
      } else if (response.statusCode == 401) {
        lastError = 'Invalid credentials';
        return false;
      } else {
        lastError = 'Server error. Please try again later.';
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (e.toString().contains('timeout') || e.toString().contains('Connection timeout')) {
        lastError = 'Connection timeout. Please check your internet connection.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        lastError = 'No internet connection. Please check your network.';
      } else {
        lastError = 'Network error. Please try again.';
      }
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    // Check if token exists and is not expired (local check only, no API call)
    final hasToken = await _prefsManager.hasToken();
    if (!hasToken) {
      debugPrint('No token found');
      return false;
    }

    final isExpired = await _prefsManager.isTokenExpired();
    if (isExpired) {
      debugPrint('Token is expired');
      await logout(); // Clean up expired token
      return false;
    }

    debugPrint('Token exists and is valid (local check)');
    return true;
  }

  Future<void> logout() async {
    await _prefsManager.logout();
  }
}

