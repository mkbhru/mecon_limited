// lib/theme_notifier.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier() {
    _loadThemeFromPrefs();
  }

  // Current theme mode
  ThemeMode get themeMode => _themeMode;

  // Helper: is dark mode active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Toggle between light & dark mode
  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }

  // Set a specific theme and persist
  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    _saveThemeToPrefs(mode);
  }

  // Load theme from SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  // Save theme to SharedPreferences
  Future<void> _saveThemeToPrefs(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }
}
