import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import JWT decoder
import '../utils/constants.dart';

class ApiService {
  Future<Map<String, dynamic>?> fetchAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token"); // Retrieve JWT token

    if (token == null) {
      print("No token found!");
      return null;
    }
    // print("Token: $token");

    // Decode JWT token to extract `PersNo`
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String? sub = decodedToken["sub"]; // Extract `PersNo` claim
    String? persNo = sub;
    String empInfoJson = decodedToken["empInfo"]?? "";
    if (persNo == null) {
      print("PersNo not found in token!");
      return null;
    }
    //  Parse `empInfo` JSON string into a Map
    Map<String, dynamic> empInfo = jsonDecode(empInfoJson);

    await prefs.setString('persNo', sub ?? '');
    await prefs.setString('FullName', empInfo["FullName"] ?? '');

    await prefs.setString('persNo', sub?? '');
    print("successfully saved in prefs: ${prefs.getString("persNo")}");
    print("successfully saved in prefs: ${prefs.getString("FullName")}");


    print("Extracted PersNo: $persNo"); // Debugging log

    // Make API request using extracted `PersNo`
    final response = await http.get(
      Uri.parse("$API_BASE_URL/attendance/attendance/$persNo"), // Pass PersNo in API URL
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
      print("Failed to fetch attendance: ${response.statusCode}");
      return null;
    }
  }
}
