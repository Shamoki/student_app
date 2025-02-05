import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:onboarding/feed.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'prof.dart';
import 'assignments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    FeedPageApp(),
    const ProfPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _pages[_selectedIndex],
          ),
          const Positioned(
            top: 20,
            right: 16,
            child: ProfilePopupMenu(),
          ),
        ],
      ),
      bottomNavigationBar: _buildSalomonBottomBar(context),
    );
  }

  Widget _buildSalomonBottomBar(BuildContext context) {
    return SalomonBottomBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home),
          title: const Text("Home"),
          selectedColor: Colors.deepPurple.withOpacity(0.8),
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.article),
          title: const Text("Feed"),
          selectedColor: Colors.deepPurple.withOpacity(0.8),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "User"; // Default username
  bool hasUpcomingDeadline = false; // Default: No deadline alert

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkUpcomingDeadlines();
  }

  // ✅ Fetch User's Name from SharedPreferences
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "User";
    });
  }

  // ✅ Check if an assignment is due in 2 days or less
  Future<void> _checkUpcomingDeadlines() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/assignments'));
      if (response.statusCode == 200) {
        List<dynamic> assignments = json.decode(response.body);

        DateTime now = DateTime.now();
        for (var assignment in assignments) {
          DateTime dueDate = DateTime.parse(assignment["dueDate"]);
          if (dueDate.difference(now).inDays <= 2) {
            setState(() {
              hasUpcomingDeadline = true;
            });
            return; // ✅ Stop checking after finding an assignment
          }
        }

        // If no deadline is found, keep it false
        setState(() {
          hasUpcomingDeadline = false;
        });
      }
    } catch (e) {
      print("Error fetching assignments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Welcome, $username 👋",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 10),
            if (hasUpcomingDeadline) const DynamicTopWidget(), // ✅ Show only if deadline is near
            const SizedBox(height: 20),
            Expanded(child: _buildFeatureGrid(context)),
          ],
        ),
      ),
    );
  }

  static Widget _buildFeatureGrid(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {"title": "Assignments & Deadlines", "icon": Icons.assignment, "color": Colors.blue},
      {"title": "Notes & Resources", "icon": Icons.book, "color": Colors.green},
      {"title": "Study Planner", "icon": Icons.schedule, "color": Colors.orange},
      {"title": "Wellness & Motivation", "icon": Icons.self_improvement, "color": Colors.deepPurple},
      {"title": "Discussions & Q&A", "icon": Icons.chat, "color": Colors.red},
    ];

    return GridView.builder(
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          feature["title"] as String,
          feature["icon"] as IconData,
          feature["color"] as Color,
          context,
        );
      },
    );
  }

  static Widget _buildFeatureCard(String title, IconData icon, Color color, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          if (title == "Assignments & Deadlines") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AssignmentsPage()),
            );
          }
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class DynamicTopWidget extends StatelessWidget {
  const DynamicTopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Lottie.asset('assets/animations/deadline.json'),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "You have a deadline soon!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePopupMenu extends StatelessWidget {
  const ProfilePopupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
      icon: const Icon(Icons.person, size: 30, color: Colors.deepPurple),
      onSelected: (Menu item) {
        switch (item) {
          case Menu.profile:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
          case Menu.settings:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
          case Menu.signOut:
            Navigator.pushReplacementNamed(context, '/login');
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<Menu>>[
        const PopupMenuItem<Menu>(value: Menu.profile, child: Text('Profile')),
        const PopupMenuItem<Menu>(value: Menu.settings, child: Text('Settings')),
        const PopupMenuItem<Menu>(value: Menu.signOut, child: Text('Sign Out')),
      ],
    );
  }
}

enum Menu { profile, settings, signOut }
