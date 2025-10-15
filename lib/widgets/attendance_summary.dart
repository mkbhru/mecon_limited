import 'package:flutter/material.dart';
import 'attendance_card2.dart';
import '../services/attendance_service.dart'; // Import the API service
import 'punches_popup.dart';

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

  String headerText(dynamic dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return "loading..";

    DateTime? dateTime = DateTime.tryParse(dateTimeString.toString());

    if (dateTime == null) return "--:--"; // Handle invalid date

    DateTime today = DateTime.now();

    if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day) {
      return "Today's Attendance";
    } else if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day - 1) {
      return "Yesterday's Attendance";
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}'s Attendance";
    }
  }

  void showPunchesPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const PunchesPopup();
      },
    );
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
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.all(8),
      child: isLoading
          ? SizedBox(height: 240,child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "fetching live data..",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Center(child: CircularProgressIndicator()),
            ],
          ))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerText(attendanceData?["TrDt"] ?? ""),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : attendanceData == null
                        ? const Center(child: Text("Server is Busy!"))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate responsive aspect ratio based on screen width
                              double screenWidth = constraints.maxWidth;
                              double aspectRatio = screenWidth < 350 ? 1.4 : 1.6;

                              return GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 12,
                                childAspectRatio: aspectRatio,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                              AttendanceCard(
                                icon: Icons.login,
                                iconColor: Colors.green,
                                title: "Check In",
                                time: formatTime(attendanceData?["FirstIn"]),
                                subtitle:
                                    attendanceData?["InStatusAct"] ?? "N/A",
                                points: "+150 pt",
                                pointsColor: Colors.green,
                              ),
                              AttendanceCard(
                                icon: Icons.logout,
                                iconColor: Colors.pinkAccent,
                                title: "Check Out",
                                time: formatTime(attendanceData?["LastOut"]),
                                subtitle:
                                    attendanceData?["OutStatusAct"] ?? "N/A",
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
                              );
                            },
                          ),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: showPunchesPopup,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            color: Colors.blue,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Today's Punch Log",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
