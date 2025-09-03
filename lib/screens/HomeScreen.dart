import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import './home_page.dart' as home_page;
import 'notifications_page.dart';
import 'notes_page.dart';
import 'chat_page.dart';
import 'settings_page.dart' as settings_page;
import 'package:double_back_to_close/double_back_to_close.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const home_page.HomePage(),
    const NotificationsPage(),
    const NotesPage(),
    const ChatPage(),
    const settings_page.SettingsScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoubleBack(
        onFirstBackPress: (context) {
          final snackBar = SnackBar(content: Text('Press back again to exit'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
