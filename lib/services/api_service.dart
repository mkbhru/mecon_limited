import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl =
      "http://localhost:5000/api"; // Change to your .NET API URL

  static Future<List<Attendance>> fetchAttendance() async {
    final response = await http.get(Uri.parse('$API_BASE_URL/attendance'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Attendance.fromJson(json)).toList();
    } else {
      throw Exception("Failed to loads attendance data");
    }
  }
}
