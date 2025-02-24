import 'package:flutter/material.dart';
import '../models/attendance.dart';

class AttendanceCard extends StatelessWidget {
  final Attendance attendance;

  const AttendanceCard({Key? key, required this.attendance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: ListTile(
        title: Text(attendance.date,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("First In: ${attendance.firstIn}"),
            Text("Lunch In: ${attendance.lunchIn}"),
            Text("Lunch Out: ${attendance.lunchOut}"),
            Text("Last Out: ${attendance.lastOut}"),
          ],
        ),
      ),
    );
  }
}
