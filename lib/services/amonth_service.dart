import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  Future<List<dynamic>> fetchAttendance(
      String persNo, int year, int month) async {
    // Print API base URL for debugging
    print("API_BASE_URL = $API_BASE_URL");

    final url =
        Uri.parse("$API_BASE_URL/attendance/AMonth/attendance-month/$persNo/$year/$month");

    print("Full URL = $url"); // optional, prints full request URL

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load attendance data");
    }
  }
}
