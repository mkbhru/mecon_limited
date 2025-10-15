import 'package:flutter/material.dart';
import '../services/user_preferences_manager.dart';

class Greetings extends StatefulWidget {
  const Greetings({Key? key}) : super(key: key);

  @override
  _GreetingsState createState() => _GreetingsState();
}

class _GreetingsState extends State<Greetings> {
  final _prefsManager = UserPreferencesManager.instance;
  String firstName = "User"; // Default user name

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch username when widget initializes
  }

  Future<void> _fetchUserName() async {
    final name = await _prefsManager.getFirstName();
    if (mounted) {
      setState(() {
        firstName = name;
      });
    }
  }

  // Public method to refresh the username (Call this after login)
  void refreshName() {
    _fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    final currDt = DateTime.now();
    String greeting = currDt.hour < 12
        ? "Morning, $firstName 👋"
        : currDt.hour < 16
            ? "Afternoon, $firstName 👋"
            : "Evening, $firstName 👋";

    return SizedBox(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "${currDt.day} ${[
                  'January',
                  'February',
                  'March',
                  'April',
                  'May',
                  'June',
                  'July',
                  'August',
                  'September',
                  'October',
                  'November',
                  'December'
                ][currDt.month - 1]} ${currDt.year}",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
