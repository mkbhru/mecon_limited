import 'package:flutter/material.dart';
import 'attendance_card2.dart';
import '../services/attendance_service.dart'; // Import the API service
class AttendanceSummary extends StatefulWidget {
  const AttendanceSummary({Key? key}) : super(key: key);

  @override
  AttendanceSummaryState createState() => AttendanceSummaryState();
}

class AttendanceSummaryState extends State<AttendanceSummary> {
  Map<String, dynamic>? attendanceData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    setState(() => isLoading = true);
    final data = await ApiService().fetchAttendance();
    if (mounted) {
      setState(() {
        attendanceData = data;
        isLoading = false;
      });
    }
  }
   String formatTime(dynamic dateTimeString) {
    if (dateTimeString == null) return "--:--"; // Handle null case
    String dateTime = dateTimeString.toString(); // Ensure it's a string
    return (dateTime.length >= 11) ? dateTime.substring(11) : "--:--";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Attendance Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : attendanceData == null
                  ? const Center(child: Text("!Server is Down"))
                  : SizedBox(
                      height: 220,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: [
                          AttendanceCard(
                            icon: Icons.login,
                            iconColor: Colors.green,
                            title: "Check In",
                            time: formatTime(attendanceData?["FirstIn"]),
                            subtitle: attendanceData?["InStatusAct"] ?? "N/A",
                            points: "+150 pt",
                            pointsColor: Colors.green,
                          ),
                          AttendanceCard(
                            icon: Icons.logout,
                            iconColor: Colors.pinkAccent,
                            title: "Check Out",
                            time: formatTime(attendanceData?["LastOut"]),
                            subtitle: attendanceData?["OutStatusAct"] ?? "N/A",
                            points: "+100 pt",
                            pointsColor: Colors.green,
                          ),
                          AttendanceCard(
                            icon: Icons.timer,
                            iconColor: Colors.purple,
                            title: "Lunch Out",
                            time: formatTime(attendanceData?["LunchOUT"]),
                            subtitle: "On time",
                            points: "",
                            pointsColor: Colors.transparent,
                          ),
                          AttendanceCard(
                            icon: Icons.timelapse,
                            iconColor: Colors.brown,
                            title: "Lunch In",
                            time: formatTime(attendanceData?["LunchIN"]),
                            subtitle: "On time",
                            points: "+\$120.00",
                            pointsColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }
}
