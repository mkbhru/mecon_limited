import 'package:flutter/material.dart';

class Greetings extends StatelessWidget {
  const Greetings({super.key});

  @override
  Widget build(BuildContext context) {
    final currDt = DateTime.now();
    return SizedBox(
      height: 50,
      child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currDt.hour < 12
                      ? "Morning, Manish 🤟"
                      : currDt.hour < 16
                          ? "Afternoon, Manish 🤟"
                          : "Evening, Manish 🤟",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          )),
    );
  }
}
