import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart'; // Import your login page

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.person),
            title: Text("Account"),
            subtitle: Text("Manage your account settings"),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),

          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
            subtitle: Text("Set your notification preferences"),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),

          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Privacy"),
            subtitle: Text("Manage data and privacy settings"),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),

          const ListTile(
            leading: Icon(Icons.language),
            title: Text("Language"),
            subtitle: Text("Choose your preferred language"),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),

          const ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text("Dark Mode"),
            subtitle: Text("Enable or disable dark mode"),
            trailing: Switch(value: false, onChanged: null), // Dummy switch
          ),
          const Divider(),

          // Logout button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              // Delete token and redirect to login page
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.remove('token'); // Remove saved token

              // Navigate to login page and remove history
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
