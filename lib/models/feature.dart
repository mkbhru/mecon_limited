import 'package:flutter/material.dart';

class Feature {
  final String title;
  final String iconPath;
  final IconData? icon;
  final void Function(BuildContext)? onTap;

  Feature({required this.title, this.iconPath = "",this.icon, this.onTap});
}
