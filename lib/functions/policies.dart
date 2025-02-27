import 'package:flutter/material.dart';

class Policies extends StatelessWidget {
  const Policies({super.key});

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Policies/Guidelines")),
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
