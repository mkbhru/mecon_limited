import 'package:flutter/material.dart';

class MeconBharti extends StatelessWidget {
  const MeconBharti({super.key});

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mecon Bharti")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "In Progress",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
