import 'package:flutter/material.dart';
import 'package:onboarding/feed.dart';
import 'package:onboarding/prof.dart';
import 'package:onboarding/resultsPage.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'settings.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'onboarding_page.dart';
import 'otp.dart';
import 'flashcard_units.dart';
import 'assignments.dart';
import 'waiting_page.dart';
import 'interests.dart';
import 'package:lottie/lottie.dart';
import 'teacher_homepage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'StudentCompanionApp',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingWrapper(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => SignupPage(),
        '/otp': (context) => OTPVerificationPage(email: ''),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/feed': (context) => FeedPageApp(),
        '/waiting_page': (context) => GariscanWaitingPage(userId: ''),
        '/profile': (context) => ProfPage(),
        //'/classrooms': (context) => const ClassroomLinksPage(),
        '/result': (context) => ResultsPage(resultData: {}),
        '/assignments': (context) => const AssignmentsPage(),
        '/flashcards': (context) => const NewFlashcardPage(),
        '/interests': (context) => InterestsPage(),
        '/teacher-home': (context) => const TeacherHomePage(),

      },
    );
  }
}

class OnboardingWrapper extends StatelessWidget {
  const OnboardingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      pages: [
        OnboardingPageModel(
          title: 'Welcome to CurioScholar',
          description: 'Fuel your academic curiosity.',
          image: Lottie.asset(
            'assets/lottie/screen0.json',
            height: 300,
            width: 300,
            fit: BoxFit.contain,
          ),
          bgColor: Colors.purple,
        ),
        OnboardingPageModel(
          title: 'Personalized Recommendations',
          description: 'Get research that matches your interests.',
          image: Lottie.asset(
            'assets/lottie/screen1.json',
            height: 300,
            width: 300,
            fit: BoxFit.contain,
          ),
          bgColor: Colors.purple,
        ),
        OnboardingPageModel(
          title: 'Select Your Interests',
          description: 'Choose topics you care about most.',
          image: Lottie.asset(
            'assets/lottie/screen2.json',
            height: 300,
            width: 300,
            fit: BoxFit.contain,
          ),
          bgColor: Colors.purple,
        ),
        OnboardingPageModel(
          title: 'Explore and Learn',
          description: 'Discover articles curated for you.',
          image: Lottie.asset(
            'assets/lottie/screen3.json',
            height: 300,
            width: 300,
            fit: BoxFit.contain,
          ),
          bgColor: Colors.purple,
        ),
      ],
    );
  }
}