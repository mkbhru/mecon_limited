import 'package:flutter/material.dart';
import 'attendance_card2.dart';
import '../services/attendance_service.dart'; // Import the API service
import 'punches_popup.dart';

class AttendanceSummary extends StatefulWidget {
  const AttendanceSummary({Key? key}) : super(key: key);

  @override
  AttendanceSummaryState createState() => AttendanceSummaryState();
}

class AttendanceSummaryState extends State<AttendanceSummary> with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? attendanceData;
  bool isLoading = false;
  bool _hasLoadedOnce = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load data only on first init
    if (!_hasLoadedOnce) {
      fetchAttendanceData();
      _hasLoadedOnce = true;
    }
  }

  Future<void> fetchAttendanceData() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final data = await ApiService().fetchAttendance().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (mounted) {
        setState(() {
          attendanceData = data;
          isLoading = false;
        });

        // Show success message if data was fetched
        if (data != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance refreshed'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Show error message
        String errorMessage = 'Failed to refresh attendance';
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Failed host lookup') ||
            e.toString().contains('NetworkException')) {
          errorMessage = 'No internet connection';
        } else if (e.toString().contains('TimeoutException') ||
                   e.toString().contains('timeout')) {
          errorMessage = 'Connection timeout';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 8),
                Text(errorMessage),
              ],
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red[700],
          ),
        );
      }
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headerText(attendanceData?["TrDt"] ?? ""),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: isLoading
                ? const SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : attendanceData == null
                    ? const SizedBox(
                        height: 80,
                        child: Center(
                          child: Text("Server is Busy!"),
                        ),
                      )
                    : Row(
                        key: const ValueKey('attendance_row'),
                        children: [
                          Expanded(
                            child: AttendanceCard(
                              icon: Icons.login,
                              iconColor: Colors.green,
                              title: "Check In",
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: showPunchesPopup,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time_filled,
                                            color: Colors.blue,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              "Punch Log",
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
                                      const Text(
                                        "View Details",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
