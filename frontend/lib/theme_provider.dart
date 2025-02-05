import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  // Getter for dark mode state
  bool get isDarkMode => _isDarkMode;

  // Constructor to load the saved theme preference on initialization
  ThemeProvider() {
    _loadThemePreference();
  }

  // Method to toggle the theme between light and dark
  void toggleTheme() {
    _isDarkMode = !_isDarkMode; // Toggle the current theme
    _saveThemePreference(); // Save the updated preference locally
    notifyListeners(); // Notify listeners to rebuild UI
  }

  // Save the current theme preference in SharedPreferences
  Future<void> _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Load the saved theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false; // Default to light mode
    notifyListeners(); // Notify listeners to rebuild UI
  }
}
