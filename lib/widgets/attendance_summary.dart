import 'package:flutter/material.dart';
import 'attendance_card2.dart'; // Import the AttendanceCard widget

class AttendanceSummary extends StatelessWidget {
  const AttendanceSummary({Key? key}) : super(key: key);

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
      // Light background color
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Attendance Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // ✅ Wrap GridView.count in Expanded to avoid layout issues
          SizedBox(
            height: 220,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6, // Adjust to prevent overflow
              children: const [
                AttendanceCard(
                  icon: Icons.login,
                  iconColor: Colors.green,
                  title: "Check In",
                  time: "09:08 am",
                  subtitle: "On time",
                  points: "+150 pt",
                  pointsColor: Colors.green,
                ),
                AttendanceCard(
                  icon: Icons.logout,
                  iconColor: Colors.pinkAccent,
                  title: "Check Out",
                  time: "--:-- --",
                  subtitle: "not punched out",
                  points: "+100 pt",
                  pointsColor: Colors.green,
                ),
                AttendanceCard(
                  icon: Icons.timer,
                  iconColor: Colors.purple,
                  title: "Lunch Out",
                  time: "01:04 pm",
                  subtitle: "On time ",
                  points: "",
                  pointsColor: Colors.transparent,
                ),
                AttendanceCard(
                  icon: Icons.timelapse,
                  iconColor: Colors.brown,
                  title: "Lunch In",
                  time: "01:10 pm",
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
