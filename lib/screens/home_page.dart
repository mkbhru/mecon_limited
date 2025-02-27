import 'package:flutter/material.dart';
import '../models/feature.dart';
import '../widgets/feature_card.dart';
import '../widgets/attendance_summary.dart';
import '../widgets/greetings.dart';
import 'attendance_screen.dart';
import '../functions/payslip.dart';
import '../functions/calendar.dart';
import '../functions/mecon_bharti.dart';
import '../functions/techquest.dart';
import '../functions/circulars.dart';
import '../functions/programmes.dart';
import '../functions/tacd.dart';
import '../functions/hr_sandesh.dart';
import '../functions/policies.dart';
import '../functions/pdp.dart';
import 'package:double_back_to_close/double_back_to_close.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ✅ Define the list of features
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

  // ✅ Define corresponding onTap functions
  final List<void Function(BuildContext)> onTapFunctions = [];

  final GlobalKey<AttendanceSummaryState> _attendanceKey =
      GlobalKey(); // ✅ Key for AttendanceSummary

  @override
  void initState() {
    super.initState();

    // ✅ Initialize onTap functions list
    onTapFunctions.addAll([
      (context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AttendanceScreen()),
          ),
      (context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Payslip()),
          ),
      (context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Calendar()),
          ),
      (context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MeconBharti()),
          ),
      (context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Techquest()),
          ),
      (context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Circulars()),
          ),
      (context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Programmes()),
          ),
      (context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Tacd()),
          ),
      (context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HrSandesh()),
          ),
      (context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Policies()),
          ),
      (context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Pdp()),
          ),
    ]);
  }

  Future<void> _refresh() async {
    await _attendanceKey.currentState?.fetchAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Greetings(),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset('assets/icons/mecon.png', width: 40, height: 40),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                AttendanceSummary(key: _attendanceKey),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    return FeatureCard(
                      feature: features[index],
                      onTap: () =>
                          onTapFunctions[index](context), // ✅ Pass onTap
                    );
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
