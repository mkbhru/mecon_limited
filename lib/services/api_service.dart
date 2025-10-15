import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';
import '../models/punch_data.dart';
import '../utils/constants.dart';
import 'user_preferences_manager.dart';

class ApiService {
  static final _prefsManager = UserPreferencesManager.instance;

  // Helper method to get common headers with token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _prefsManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'token': token,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Attendance>> fetchAttendance() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$API_BASE_URL/attendance'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Attendance.fromJson(json)).toList();
    } else {
      throw Exception("Failed to loads attendance data");
    }
  }

  static Future<PunchDataResponse> fetchPunchesOnDate({
    required String persNo,
    required int year,
    required int month,
    required int day,
  }) async {
    final headers = await _getHeaders();
    final url = '$API_BASE_URL/attendance/fetch-punches-on-date/$persNo/$year/$month/${day.toString().padLeft(2, '0')}';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return PunchDataResponse.fromJson(data);
    } else {
      throw Exception("Failed to fetch punch data");
    }
  }
}
