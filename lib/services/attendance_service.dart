import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'user_preferences_manager.dart';

class ApiService {
  final _prefsManager = UserPreferencesManager.instance;

  Future<Map<String, dynamic>?> fetchAttendance() async {
    // Get persNo from preferences manager
    final persNo = await _prefsManager.getPersNo();

    if (persNo == null || persNo.isEmpty) {
      return null;
    }

    // Make API request using persNo
    final response = await http.get(
      Uri.parse("$API_BASE_URL/attendance/attendance/$persNo"),
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is List && decodedBody.isNotEmpty) {
        return decodedBody[0]; // Return the first item if it's a list
      } else if (decodedBody is Map<String, dynamic>) {
        return decodedBody; // Return as is if it's already a map
      } else {
        return null; // Unexpected format
      }
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchLatestPunches() async {
    // Get persNo from preferences manager
    final persNo = await _prefsManager.getPersNo();

    if (persNo == null || persNo.isEmpty) {
      return null;
    }

    final response = await http.get(
      Uri.parse("$API_BASE_URL/attendance/fetch-latest-punches/$persNo"),
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is List) {
        return List<Map<String, dynamic>>.from(decodedBody);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}
