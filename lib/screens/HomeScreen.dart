import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart'; // Import the BottomNavBar widget
import './home_page.dart'; // Your home content
import './notifications_page.dart'; // Notifications content
import './notes_page.dart'; // Notes content
import 'settings_page.dart'; // Settings content
import './chat_page.dart';
import 'package:double_back_to_close/double_back_to_close.dart';

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
      body:  // Show selected page
      DoubleBack(
        onFirstBackPress: (context) {
          // you can use your custom here
          // change this with your custom action
          final snackBar = SnackBar(content: Text('Press back again to exit'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // ---
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


