import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n.dart'; // ✅ localization
import '../widgets/attendance_card2.dart';
import '../services/attendance_service.dart';
import 'punches_popup.dart';
import '../locale_notifier.dart';

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
    if (dateTimeString == null) return "--:--";
    String dateTime = dateTimeString.toString();
    return (dateTime.length >= 11) ? dateTime.substring(11) : "--:--";
  }

  String headerText(dynamic dateTimeString, S loc) {
    if (dateTimeString == null || dateTimeString.isEmpty) return loc.loading;
    DateTime? dateTime = DateTime.tryParse(dateTimeString.toString());
    if (dateTime == null) return "--:--";

    DateTime today = DateTime.now();

    if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day) {
      return loc.todaysAttendance;
    } else if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day - 1) {
      return loc.yesterdaysAttendance;
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${loc.attendance}";
    }
  }

  void showPunchesPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const PunchesPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    // Wrap in Consumer so UI rebuilds when locale changes
    return Consumer<LocaleNotifier>(
      builder: (context, localeNotifier, child) {
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
              ? SizedBox(
            height: 240,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  loc.fetchingData,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headerText(attendanceData?["TrDt"] ?? "", loc),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              attendanceData == null
                  ? Center(child: Text(loc.serverBusy))
                  : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AttendanceCard(
                    icon: Icons.login,
                    iconColor: Colors.green,
                    title: loc.checkIn,
                    time: formatTime(attendanceData?["FirstIn"]),
                    subtitle:
                    attendanceData?["InStatusAct"] ?? loc.na,
                    points: "+150 pt",
                    pointsColor: Colors.green,
                  ),
                  AttendanceCard(
                    icon: Icons.logout,
                    iconColor: Colors.pinkAccent,
                    title: loc.checkOut,
                    time: formatTime(attendanceData?["LastOut"]),
                    subtitle:
                    attendanceData?["OutStatusAct"] ?? loc.na,
                    points: "+100 pt",
                    pointsColor: Colors.green,
                  ),
                  AttendanceCard(
                    icon: Icons.timer,
                    iconColor: Colors.purple,
                    title: loc.lunchOut,
                    time: formatTime(attendanceData?["LunchOUT"]),
                    subtitle: loc.onTime,
                    points: "",
                    pointsColor: Colors.transparent,
                  ),
                  AttendanceCard(
                    icon: Icons.timelapse,
                    iconColor: Colors.brown,
                    title: loc.lunchIn,
                    time: formatTime(attendanceData?["LunchIN"]),
                    subtitle: loc.onTime,
                    points: "+\$120.00",
                    pointsColor: Colors.green,
                  ),
                ],
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
                      border: Border.all(
                          color: Colors.blue.withOpacity(0.3)),
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
                          loc.todaysPunchLog,
                          style: const TextStyle(
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
      },
    );
  }
}
