import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart'; // Import the BottomNavBar widget
import '../services/user_preferences_manager.dart';
import './home_page.dart'; // Your home content
import './notifications_page.dart'; // Notifications content
import './notes_page.dart'; // Notes content
import 'settings_page.dart'; // Settings content
import './chat_page.dart';
import './admin_page.dart';
import 'package:double_back_to_close/double_back_to_close.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _prefsManager = UserPreferencesManager.instance;
  int _selectedIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _prefsManager.isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  List<Widget> get _pages {
    final pages = [
      HomePage(),
      const NotificationsPage(),
      const NotesPage(),
      const ChatPage(),
      SettingsPage(),
    ];

    // Add admin page if user is admin
    if (_isAdmin) {
      pages.add(const AdminPage());
    }

    return pages;
  }

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
        isAdmin: _isAdmin,
      ),
    );
  }

  
}


