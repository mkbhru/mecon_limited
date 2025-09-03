import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/l10n.dart';

class Greetings extends StatefulWidget {
  const Greetings({Key? key}) : super(key: key);

  @override
  _GreetingsState createState() => _GreetingsState();
}

class _GreetingsState extends State<Greetings> {
  String fullName = "User";

  @override
  void initState() {
    super.initState();
    _fetchFullName();
  }

  Future<void> _fetchFullName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final storedName = prefs.getString("FullName") ?? "User";
      final nameParts = storedName.split(" ");
      fullName = nameParts.isNotEmpty ? nameParts.first : "User";
    });
  }

  void refreshName() {
    _fetchFullName();
  }

  String getGreeting(S loc) {
    final hour = DateTime.now().hour;
    if (hour < 12) return loc.goodMorning(fullName);
    if (hour < 17) return loc.goodAfternoon(fullName);
    return loc.goodEvening(fullName);
  }

  String getMonthName(S loc, int month) {
    switch (month) {
      case 1:
        return loc.monthJan;
      case 2:
        return loc.monthFeb;
      case 3:
        return loc.monthMar;
      case 4:
        return loc.monthApr;
      case 5:
        return loc.monthMay;
      case 6:
        return loc.monthJun;
      case 7:
        return loc.monthJul;
      case 8:
        return loc.monthAug;
      case 9:
        return loc.monthSep;
      case 10:
        return loc.monthOct;
      case 11:
        return loc.monthNov;
      case 12:
        return loc.monthDec;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final now = DateTime.now();
    final formattedDate =
        "${now.day} ${getMonthName(loc, now.month)} ${now.year}";

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ Column takes only needed space
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getGreeting(loc),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1, // ✅ prevent overflow
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 14),
              maxLines: 1, // ✅ prevent overflow
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
