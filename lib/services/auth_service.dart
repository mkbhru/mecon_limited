import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  Future<bool> login(String persno, String password) async {
    final url = Uri.parse('$API_BASE_URL/Auth/login');
    final response = await http.post(
      url,
      body: jsonEncode({'persno': persno, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']; // Assuming the API returns a token

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return true;
    } else {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse("$API_BASE_URL/employee/validate-token"),
        headers: {
          "token": token,
          "Content-Type": "application/json"
        },
      );
      // return true;
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}

