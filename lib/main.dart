import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/HomeScreen.dart';
import 'services/auth_service.dart';
import 'services/user_preferences_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the preferences manager
  await UserPreferencesManager.instance.init();

  // Check if user is logged in
  bool loggedIn = await AuthService().isLoggedIn();

  runApp(MyApp(isLoggedIn: loggedIn));
}



class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MECON App',
      debugShowCheckedModeBanner: false,
      home: MainScreen(isLoggedIn: isLoggedIn),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isLoggedIn;

  const MainScreen({super.key, required this.isLoggedIn});

  @override
  _MainScreenState createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoginStatusSnackbar();
    });
  }

  void _showLoginStatusSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(widget.isLoggedIn ? 'Already logged in' : 'Please log in'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoggedIn ? HomeScreen() : LoginScreen();
  }
}
