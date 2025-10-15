import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'user_preferences_manager.dart';

class ApiService {
  final _prefsManager = UserPreferencesManager.instance;

  Future<Map<String, dynamic>?> fetchAttendance() async {
    try {
      // Get persNo from preferences manager
      final persNo = await _prefsManager.getPersNo();

      if (persNo == null || persNo.isEmpty) {
        return null;
      }

      // Make API request using persNo with timeout
      final response = await http.get(
        Uri.parse("$API_BASE_URL/attendance/attendance/$persNo"),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
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
    } catch (e) {
      // Re-throw to let caller handle the error
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchLatestPunches() async {
    try {
      // Get persNo from preferences manager
      final persNo = await _prefsManager.getPersNo();

      if (persNo == null || persNo.isEmpty) {
        return null;
      }

      final response = await http.get(
        Uri.parse("$API_BASE_URL/attendance/fetch-latest-punches/$persNo"),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
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
    } catch (e) {
      // Re-throw to let caller handle the error
      rethrow;
    }
  }
}
