import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:onboarding/flashcard_units.dart';
import 'prof.dart';
import 'assignments.dart';
import 'package:shared_preferences/shared_preferences.dart';



class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}
 
class _TeacherHomePageState extends State<TeacherHomePage> {
  final int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
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
    
  }

  // ✅ Fetch User's Name from SharedPreferences
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "User";
    });
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
                "Welcome,Teacher $username 👋",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 10),
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
      {"title": "Flashcards", "icon": Icons.book, "color": Colors.green},
     
      
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
          } else if (title == "Flashcards") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewFlashcardPage()),
            );
          }
          /*else if (title == "Online class links") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClassroomLinksPage()),
            );
          }*/
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
                "You have a assignment deadline soon!",
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
