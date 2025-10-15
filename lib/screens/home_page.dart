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

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
            MaterialPageRoute(builder: (context) =>  Calendar()),
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        title: const Greetings(),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset('assets/icons/mecon.png', width: 40, height: 40),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        strokeWidth: 2.5,
        displacement: 40,
        color: Theme.of(context).primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AttendanceSummary(key: _attendanceKey),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return FeatureCard(
                      feature: features[index],
                      onTap: () =>
                          onTapFunctions[index](context), // ✅ Pass onTap
                    );
                  },
                  childCount: features.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
