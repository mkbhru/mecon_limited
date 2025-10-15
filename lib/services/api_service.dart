import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';
import '../models/punch_data.dart';
import '../utils/constants.dart';

class ApiService {
  static Future<List<Attendance>> fetchAttendance() async {
    final response = await http.get(Uri.parse('$API_BASE_URL/attendance'));

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
    final url = '$API_BASE_URL/attendance/fetch-punches-on-date/$persNo/$year/$month/${day.toString().padLeft(2, '0')}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return PunchDataResponse.fromJson(data);
    } else {
      throw Exception("Failed to fetch punch data");
    }
  }
}
