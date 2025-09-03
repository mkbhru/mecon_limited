import 'package:flutter/material.dart';
import 'package:mecon_limited/generated/l10n.dart'; // localization

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
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<void Function(BuildContext)> onTapFunctions = [];
  final GlobalKey<AttendanceSummaryState> _attendanceKey = GlobalKey();

  @override
  void initState() {
    super.initState();

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
        MaterialPageRoute(builder: (context) => Calendar()),
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
    final loc = S.of(context);

    final List<Feature> features = [
      Feature(title: loc.todaysAttendance, iconPath: 'assets/icons/attendance.png'),
      Feature(title: loc.payslip, iconPath: 'assets/icons/payslip.png'),
      Feature(title: loc.attendanceCalendar, iconPath: 'assets/icons/calendar.png'),
      Feature(title: loc.meconBharti, iconPath: 'assets/icons/bharti.png'),
      Feature(title: loc.techQuest, iconPath: 'assets/icons/techquest.png'),
      Feature(title: loc.circulars, iconPath: 'assets/icons/circular.png'),
      Feature(title: loc.programmes, iconPath: 'assets/icons/programmes.png'),
      Feature(title: loc.tacd, iconPath: 'assets/icons/paybill.png'),
      Feature(title: loc.hrSandesh, iconPath: 'assets/icons/paybill.png'),
      Feature(title: loc.policiesGuidelines, iconPath: 'assets/icons/paybill.png'),
      Feature(title: loc.pdp, iconPath: 'assets/icons/paybill.png'),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70, // increase height to prevent overflow
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
                      onTap: () => onTapFunctions[index](context),
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
