import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';
import '../locale_notifier.dart';
import 'package:mecon_limited/generated/l10n.dart'; // ✅ only this one

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(S.of(context).account),
            subtitle: Text(S.of(context).manageAccount),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(S.of(context).notifications),
            subtitle: Text(S.of(context).manageNotifications),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(S.of(context).privacy),
            subtitle: Text(S.of(context).managePrivacy),
          ),

          // 🌐 Language Selector
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(S.of(context).language),
            subtitle: Text(
              localeNotifier.locale.languageCode == 'hi'
                  ? S.of(context).hindi
                  : S.of(context).english,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(S.of(context).chooseLanguage),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<Locale>(
                        title: Text(S.of(context).english),
                        value: const Locale('en'),
                        groupValue: localeNotifier.locale,
                        onChanged: (value) {
                          localeNotifier.setLocale(value!);
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<Locale>(
                        title: Text(S.of(context).hindi),
                        value: const Locale('hi'),
                        groupValue: localeNotifier.locale,
                        onChanged: (value) {
                          localeNotifier.setLocale(value!);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 🌙 Dark Mode Toggle
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: Text(S.of(context).darkMode),
            subtitle: Text(S.of(context).darkModeSubtitle),
            value: themeNotifier.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeNotifier.setTheme(
                  value ? ThemeMode.dark : ThemeMode.light);
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              S.of(context).logout,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              // TODO: add logout logic
            },
          ),
        ],
      ),
    );
  }
}
