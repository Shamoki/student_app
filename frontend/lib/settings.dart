import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider for ThemeProvider
import 'package:navigation_history_observer/navigation_history_observer.dart'; // Import observer
import 'theme_provider.dart'; // Import ThemeProvider

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access ThemeProvider
    final isDarkMode = themeProvider.isDarkMode; // Check current theme mode

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: isDarkMode ? Colors.grey[900] : const Color.fromARGB(255, 255, 255, 255),
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
                        themeProvider.toggleTheme(); // Toggle theme
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
                    backgroundColor:
                        isDarkMode ? Colors.grey[900]! : Colors.purple,
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

  const _CustomListTile({
    required this.title,
    required this.icon,
    this.trailing,
    required this.tileColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tileColor,
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor)),
        leading: Icon(icon, color: textColor),
        trailing: trailing ??
            Icon(CupertinoIcons.forward, size: 18, color: textColor),
        onTap: () {},
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
