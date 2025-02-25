import 'package:flutter/material.dart';
import '../models/feature.dart';
import '../widgets/feature_card.dart';
import '../widgets/attendance_summary.dart';
import '../widgets/greetings.dart';
import 'attendance_screen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Feature> features = [
    Feature(title: 'Attendance', iconPath: 'assets/icons/attendance.png'),
    Feature(title: 'Payslip', iconPath: 'assets/icons/payslip.png'),
    Feature(title: 'Calendar', iconPath: 'assets/icons/calendar.png'),
    Feature(title: 'Mecon Bharti', iconPath: 'assets/icons/bharti.png'),
    Feature(title: 'TechQuest', iconPath: 'assets/icons/techquest.png'),
    Feature(title: 'Circulars', iconPath: 'assets/icons/circular.png'),
    Feature(title: 'Programmes', iconPath: 'assets/icons/programmes.png'),
    Feature(title: 'TACD', iconPath: 'assets/icons/paybill.png'),
    Feature(title: 'HR Sandesh', iconPath: 'assets/icons/paybill.png'),
    Feature(title: 'Policies/Guidelines', iconPath: 'assets/icons/paybill.png'),
    Feature(title: 'PDP', iconPath: 'assets/icons/paybill.png'),
  ];

  final GlobalKey<AttendanceSummaryState> _attendanceKey =
      GlobalKey(); // ✅ Add key

  Future<void> _refresh() async {
    await _attendanceKey.currentState
        ?.fetchAttendanceData(); // ✅ Refresh attendance
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Greetings(),
        actions: [
          Padding(
              padding: const EdgeInsets.all(10.0),
              child:
                  Image.asset('assets/icons/mecon.png', width: 40, height: 40)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh, // ✅ Swipe down to refresh attendance
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // ✅ Allows scrolling for refresh
            child: Column(
              children: [
                AttendanceSummary(key: _attendanceKey), // ✅ Pass key
                GridView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevents double scrolling
                  shrinkWrap:
                      true, // Allows the grid to take only the required space
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cards per row
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    return FeatureCard(feature: features[index],
                        onTap: () {
                      Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const AttendanceScreen()),
                          );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
