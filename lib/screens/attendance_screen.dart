import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/attendance.dart';
import '../widgets/attendance_card.dart';

class AttendanceScreen extends StatefulWidget {
   static void navigate(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => AttendanceScreen()));
  }
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<List<Attendance>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = ApiService.fetchAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),
      body: FutureBuilder<List<Attendance>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Failed to load data"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No attendance records available"));
          }

          List<Attendance> attendanceList = snapshot.data!;
          Attendance today =
              attendanceList.first; // Assuming the first item is today’s data

          return Column(
            children: [
              // Highlight today's attendance
              Card(
                elevation: 5,
                color: Colors.blueAccent,
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today's Attendance",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      Text("First In: ${today.firstIn}",
                          style: const TextStyle(color: Colors.white)),
                      Text("Lunch In: ${today.lunchIn}",
                          style: const TextStyle(color: Colors.white)),
                      Text("Lunch Out: ${today.lunchOut}",
                          style: const TextStyle(color: Colors.white)),
                      Text("Last Out: ${today.lastOut}",
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),

              // Display past attendance in a scrollable list
              Expanded(
                child: ListView.builder(
                  itemCount: attendanceList.length,
                  itemBuilder: (context, index) {
                    return AttendanceCard(attendance: attendanceList[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
