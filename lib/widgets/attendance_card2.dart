import 'package:flutter/material.dart';
import '../services/attendance_service.dart';

class AttendanceCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const AttendanceCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  String time = "--:--";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFirstPunch();
  }

  Future<void> fetchFirstPunch() async {
    final punches = await ApiService().fetchLatestPunches();
    if (mounted) {
      setState(() {
        if (punches != null && punches.isNotEmpty) {
          // Get the first punch (check-in time)
          final firstPunch = punches[0];
          final punchTime = firstPunch['punchTime'];
          time = punchTime ?? "--:--";
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: widget.iconColor, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            isLoading
                ? const SizedBox(
                    width: 40,
                    height: 14,
                    child: LinearProgressIndicator(minHeight: 2),
                  )
                : Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
