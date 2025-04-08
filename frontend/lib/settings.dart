import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor:
            isDarkMode ? Colors.grey[900] : const Color.fromARGB(255, 255, 255, 255),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            children: [
              _SingleSection(
                title: "General",
                textColor: isDarkMode ? Colors.white : Colors.black,
                children: [
                  _CustomListTile(
                    title: "About Phone",
                    icon: CupertinoIcons.device_phone_portrait,
                    tileColor: isDarkMode ? Colors.grey[850]! : Colors.white,
                    textColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                  _CustomListTile(
                    title: "Dark Mode",
                    icon: CupertinoIcons.moon,
                    tileColor: isDarkMode ? Colors.grey[850]! : Colors.white,
                    textColor: isDarkMode ? Colors.white : Colors.black,
                    trailing: CupertinoSwitch(
                      value: isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                  _CustomListTile(
                    title: "System Apps Updater",
                    icon: CupertinoIcons.cloud_download,
                    tileColor: isDarkMode ? Colors.grey[850]! : Colors.white,
                    textColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                  _CustomListTile(
                    title: "Security Status",
                    icon: CupertinoIcons.lock_shield,
                    tileColor: isDarkMode ? Colors.grey[850]! : Colors.white,
                    textColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                ],
              ),
              _SingleSection(
                title: "Preferences",
                textColor: isDarkMode ? Colors.white : Colors.black,
                children: [
                  _CustomListTile(
                    title: "Reset Interests",
                    icon: CupertinoIcons.refresh,
                    tileColor: isDarkMode ? Colors.grey[850]! : Colors.white,
                    textColor: isDarkMode ? Colors.white : Colors.black,
                    trailing: null,
                    onTap: () async {
                      final shouldReset = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset Interests'),
                          content: const Text('Are you sure you want to reset your interests?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Yes, Reset'),
                            ),
                          ],
                        ),
                      );

                      if (shouldReset == true) {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? token = prefs.getString('token');
                        String? userId = prefs.getString('userId');

                        final response = await http.post(
                          Uri.parse('http://172.20.10.4:5001/api/auth/reset-interests'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $token', // Optional if you're checking it
                          },
                          body: jsonEncode({
                            "userId": userId,
                          }),
                        );

                        if (response.statusCode == 200) {
                          Navigator.pushReplacementNamed(context, '/interests');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to reset interests')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    List<Route<dynamic>> history =
                        NavigationHistoryObserver().history.toList();

                    bool homeExists =
                        history.any((route) => route.settings.name == '/home');

                    if (homeExists) {
                      Navigator.of(context)
                          .popUntil((route) => route.settings.name == '/home');
                    } else {
                      Navigator.of(context).pushNamed('/home');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.grey[900]! : Colors.purple,
                  ),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final Color tileColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _CustomListTile({
    required this.title,
    required this.icon,
    this.trailing,
    required this.tileColor,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tileColor,
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor)),
        leading: Icon(icon, color: textColor),
        trailing: trailing ?? Icon(CupertinoIcons.forward, size: 18, color: textColor),
        onTap: onTap ?? () {},
      ),
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color textColor;

  const _SingleSection({
    required this.title,
    required this.children,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontSize: 16, color: textColor),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
