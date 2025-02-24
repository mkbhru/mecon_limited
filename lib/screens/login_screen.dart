import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// import 'home_page.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController persnoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

  void handleLogin() async {
    setState(() => isLoading = true);

    bool success = await authService.login(
      persnoController.text.trim(),
      passwordController.text.trim(),
    );
    // bool success = true;

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('MECON Employee Login', style: TextStyle(fontWeight: FontWeight.bold),)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Image.asset('assets/icons/mecon2.png', width: 120, height: 120),
            SizedBox(height: 80),
            TextField(
              controller: persnoController,
              decoration: InputDecoration(labelText: 'Personnel No'),
              // keyboardType: TextInputType.number,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : handleLogin,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
