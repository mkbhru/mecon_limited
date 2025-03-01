import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Greetings extends StatefulWidget {
  const Greetings({Key? key}) : super(key: key);

  @override
  _GreetingsState createState() => _GreetingsState();
}

class _GreetingsState extends State<Greetings> {
  String fullName = "User"; // Default user name

  @override
  void initState() {
    super.initState();
    _fetchFullName(); // Fetch username when widget initializes
  }

  Future<void> _fetchFullName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String storedName = prefs.getString("FullName") ?? "User";
      List<String> nameParts = storedName.split(" ");
      fullName =
          nameParts.isNotEmpty ? nameParts.first : "User"; // Extract first name
    });
  }

  // Public method to refresh the username (Call this after login)
  void refreshName() {
    _fetchFullName();
  }

  @override
  Widget build(BuildContext context) {
    final currDt = DateTime.now();
    String greeting = currDt.hour < 12
        ? "Morning, $fullName 👋"
        : currDt.hour < 16
            ? "Afternoon, $fullName 👋"
            : "Evening, $fullName 👋";

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
