import 'package:flutter/material.dart';
import '../models/feature.dart';

class FeatureCard extends StatelessWidget {
  final Feature feature;
  final VoidCallback? onTap;

  const FeatureCard({Key? key, required this.feature, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(feature.iconPath, width: 50, height: 50),
            const SizedBox(height: 8),
            Text(feature.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
