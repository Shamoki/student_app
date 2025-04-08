import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClassroomLinksForm extends StatefulWidget {
  const ClassroomLinksForm({super.key});

  @override
  State<ClassroomLinksForm> createState() => _ClassroomLinksFormState();
}

class _ClassroomLinksFormState extends State<ClassroomLinksForm> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _classCodeController = TextEditingController();
  final TextEditingController _meetingLinkController = TextEditingController();
  String _selectedPlatform = 'Zoom';

  bool _isLoading = false;
  final List<Map<String, dynamic>> _classroomLinks = [];

  final List<String> _platforms = [
    'Zoom',
    'Google Classroom',
    'Google Meet',
    'Microsoft Teams',
    'Other'
  ];

  bool _isValidUrl(String input) {
    final uri = Uri.tryParse(input);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  Future<void> _saveClassroomLink() async {
    if (_classNameController.text.isEmpty ||
        _classCodeController.text.isEmpty ||
        _meetingLinkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (!_isValidUrl(_meetingLinkController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid meeting URL")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/classroom-links'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "className": _classNameController.text,
        "classCode": _classCodeController.text,
        "meetingLink": _meetingLinkController.text,
        "platform": _selectedPlatform,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _classroomLinks.add(json.decode(response.body));
        _classNameController.clear();
        _classCodeController.clear();
        _meetingLinkController.clear();
        _selectedPlatform = 'Zoom';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Classroom link added")),
      );
      //go back
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add classroom link")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Add Classroom Link",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: "Online Class Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _classCodeController,
              decoration: const InputDecoration(
                labelText: "Class Code / Link Code",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _meetingLinkController,
              decoration: const InputDecoration(
                labelText: "Meeting URL (e.g., Zoom/Meet link)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedPlatform,
              decoration: const InputDecoration(
                labelText: "Platform",
                border: OutlineInputBorder(),
              ),
              items: _platforms.map((platform) {
                return DropdownMenuItem(value: platform, child: Text(platform));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPlatform = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveClassroomLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Link",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
