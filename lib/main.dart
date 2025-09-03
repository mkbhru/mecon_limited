// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme_notifier.dart'; // Theme management
import 'locale_notifier.dart'; // Language management
import 'screens/login_screen.dart';
import 'screens/HomeScreen.dart';
import 'services/auth_service.dart';
import 'generated/l10n.dart'; // ✅ Generated localization import


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool loggedIn = await AuthService().isLoggedIn();
  final prefs = await SharedPreferences.getInstance();
  String? user = prefs.getString('token');
  if (user == null) loggedIn = false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
      ],
      child: MyApp(isLoggedIn: loggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return MaterialApp(
      title: 'MECON App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.themeMode,
      locale: localeNotifier.locale, // ✅ apply selected locale

      // ✅ use generated delegates
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

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
        content: Text(widget.isLoggedIn ? 'Already logged in' : 'Please log in'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
