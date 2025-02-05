import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  List<String> selectedInterests = [];
  List<String> selectedSubInterests = [];
  bool isLoading = false;

  // Expanded interest categories
  final Map<String, List<String>> interestCategories = {
    "Technology & Computer Science": [
      "Artificial Intelligence",
      "Cybersecurity",
      "Software Development",
      "Cloud Computing",
      "Game Development",
      "Blockchain",
      "Data Science"
    ],
    "Engineering": [
      "Mechanical Engineering",
      "Electrical Engineering",
      "Civil Engineering",
      "Robotics",
      "Aeronautical Engineering"
    ],
    "Science & Medicine": [
      "Biotechnology",
      "Neuroscience",
      "Genetics",
      "Pharmacology",
      "Public Health",
      "Astrophysics"
    ],
    "Business & Finance": [
      "Marketing",
      "Entrepreneurship",
      "Economics",
      "Investment & Trading",
      "Leadership",
      "Supply Chain Management"
    ],
    "Arts & Humanities": [
      "Graphic Design",
      "Photography",
      "Music Production",
      "Philosophy",
      "History",
      "Creative Writing",
      "Film & Animation"
    ],
    "Social Sciences & Law": [
      "Psychology",
      "Political Science",
      "Criminal Justice",
      "International Relations",
      "Legal Studies"
    ],
    "High School Subjects": [
      "Mathematics",
      "Physics",
      "Biology",
      "Chemistry",
      "English Literature",
      "Geography",
      "Computer Studies"
    ],
  };

  Future<void> _saveInterests() async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    if (userId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not found. Please log in.")));
      return;
    }

    final response = await http.put(
      Uri.parse("http://localhost:5000/api/auth/set-interests"),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        "userId": userId,
        "interests": [...selectedInterests, ...selectedSubInterests],
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      prefs.setBool('interestsSet', true); // Save locally so user isn't asked again
      Navigator.pushReplacementNamed(context, "/home"); // ✅ Redirect to home after setting interests
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save interests.")));
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
        selectedSubInterests.removeWhere((sub) => interestCategories[interest]?.contains(sub) ?? false);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  void _toggleSubInterest(String subInterest) {
    setState(() {
      selectedSubInterests.contains(subInterest)
          ? selectedSubInterests.remove(subInterest)
          : selectedSubInterests.add(subInterest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ White Background
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Choose topics you love! This helps us personalize content for you.",
              style: TextStyle(fontSize: 20, color: Colors.purple),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 📌 Interest Selection
            Expanded(
              child: ListView(
                children: interestCategories.keys.map((category) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      iconColor: Colors.purple,
                      title: Row(
                        children: [
                          Checkbox(
                            value: selectedInterests.contains(category),
                            onChanged: (_) => _toggleInterest(category),
                            activeColor: Colors.purple,
                          ),
                          Expanded(
                            child: Text(
                              category,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      children: interestCategories[category]!.map((subCategory) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ChoiceChip(
                            label: Text(subCategory),
                            selected: selectedSubInterests.contains(subCategory),
                            onSelected: (_) => _toggleSubInterest(subCategory),
                            selectedColor: Colors.purple.withOpacity(0.2),
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: selectedSubInterests.contains(subCategory) ? Colors.purple : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 📌 Save Interests Button
            ElevatedButton(
              onPressed: isLoading ? null : _saveInterests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save & Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
