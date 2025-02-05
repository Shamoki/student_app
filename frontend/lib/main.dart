import 'package:flutter/material.dart';
import 'package:onboarding/feed.dart';
import 'package:onboarding/prof.dart';
import 'package:onboarding/resultsPage.dart';
import 'package:provider/provider.dart'; // For ThemeProvider
import 'theme_provider.dart'; // Theme management
import 'settings.dart'; // Settings page
// Feed page
import 'home_page.dart'; // Home page
import 'login_page.dart'; // Login page
import 'signup_page.dart'; // Signup page
import 'onboarding_page.dart'; // Onboarding page
import 'otp.dart'; // OTP verification page
import 'waiting_page.dart';
import 'interests.dart';
//import 'report_page.dart';
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
      title: 'GariScan',
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
        '/waiting_page':(context) =>GariscanWaitingPage(userId: '',),
        '/profile':(context)=>ProfPage(),
        '/result':(context)=>ResultsPage(resultData: {},),
        '/interests':(context)=>InterestsPage(),
         //'/report': (context) => ReportPage(title: '', pdfPath: '', imageUrl: '', details: '',),
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
          title: 'Welcome to GariScan',
          description: 'Your go-to app for vehicle damage scanning.',
          image: 'assets/image0.png',
          bgColor: Colors.purple,
        ),
        OnboardingPageModel(
          title: 'Analyze Anywhere',
          description: 'Upload an image and assess it in minutes.',
          image: 'assets/image3.png',
          bgColor: Colors.purple,
        ),
        OnboardingPageModel(
          title: 'Cost Estimates',
          description: 'Find out repair costs in a few clicks.',
          image: 'assets/money.gif',
          bgColor: Colors.purple,
        ),
        OnboardingPageModel(
          title: 'Track Your History',
          description: 'Keep records of your assessments.',
          image: 'assets/image1.png',
          bgColor: Colors.purple,
        ),
      ],
    );
  }
}
