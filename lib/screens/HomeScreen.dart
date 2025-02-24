import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart'; // Import the BottomNavBar widget
import './home_page.dart'; // Your home content
import './notifications_page.dart'; // Notifications content
import './notes_page.dart'; // Notes content
import 'settings_page.dart'; // Settings content
import './chat_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    NotificationsPage(),
    NotesPage(),
    ChatPage(),
    SettingsPage(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Show selected page
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
