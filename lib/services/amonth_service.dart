import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';


class ApiService {

  Future<List<dynamic>> fetchAttendance(
      String persNo, int year, int month) async {
    final url =
        Uri.parse("$API_BASE_URL/AMonth/attendance-month/$persNo/$year/$month");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load attendance data");
    }
  }
}
