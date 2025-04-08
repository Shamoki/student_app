import 'package:flutter/material.dart';
import 'package:onboarding/flashcard_units.dart';
import 'package:onboarding/home_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'prof.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const NewFlashcardPage(), // 📚 Flashcard Units page
    const ProfPage(),         // 👤 Optional: profile page
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
            child: ProfilePopupMenu(), // Reuse same popup menu
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
          icon: const Icon(Icons.book),
          title: const Text("Flashcards"),
          selectedColor: Colors.deepPurple,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.person),
          title: const Text("Profile"),
          selectedColor: Colors.deepPurple,
        ),
      ],
    );
  }
}
