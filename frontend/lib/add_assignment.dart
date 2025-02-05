import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web_auth/flutter_web_auth.dart'; // For Google OAuth

class AddAssignmentPage extends StatefulWidget {
  const AddAssignmentPage({super.key});

  @override
  State<AddAssignmentPage> createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  List<Map<String, dynamic>> _classroomAssignments = []; // To store fetched assignments
  bool _isLoading = false; // To show loading state

  // 📅 Function to show date picker
  Future<void> _pickDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  // 🚀 Function to send assignment data to backend
  Future<void> _saveAssignment() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/assignments'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "title": _titleController.text,
        "description": _descriptionController.text,
        "dueDate": _selectedDueDate!.toIso8601String(),  // ✅ Send Date in ISO format
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, json.decode(response.body)); // ✅ Return new assignment
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to add assignment")));
    }
  }

  // 🔑 Function to authenticate with Google Classroom
  Future<void> _authenticateWithGoogle() async {
    const clientId = 'YOUR_GOOGLE_CLIENT_ID'; // Replace with your Google OAuth client ID
    const redirectUri = 'com.your.app://callback'; // Replace with your redirect URI
    const scope = 'https://www.googleapis.com/auth/classroom.courses.readonly https://www.googleapis.com/auth/classroom.coursework.me';

    final url = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scope,
    });

    try {
      final result = await FlutterWebAuth.authenticate(url: url.toString(), callbackUrlScheme: 'com.your.app');
      final code = Uri.parse(result).queryParameters['code'];
      if (code != null) {
        await _fetchGoogleClassroomAssignments(code);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to authenticate: $e")));
    }
  }

  // 📚 Function to fetch assignments from Google Classroom
  Future<void> _fetchGoogleClassroomAssignments(String code) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/google-classroom/assignments'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"code": code}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _classroomAssignments = List<Map<String, dynamic>>.from(data);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to fetch assignments")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🖋 Function to auto-fill form with selected assignment
  void _selectAssignment(Map<String, dynamic> assignment) {
    setState(() {
      _titleController.text = assignment['title'];
      _descriptionController.text = assignment['description'];
      _selectedDueDate = DateTime.parse(assignment['dueDate']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 Header
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Add Assignment",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // 🔗 Google Classroom Integration Button
            Center(
              child: ElevatedButton(
                onPressed: _authenticateWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Fetch from Google Classroom", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),

            // 📜 List of Google Classroom Assignments
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_classroomAssignments.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _classroomAssignments.length,
                  itemBuilder: (context, index) {
                    final assignment = _classroomAssignments[index];
                    return ListTile(
                      title: Text(assignment['title']),
                      subtitle: Text(DateFormat.yMMMd().format(DateTime.parse(assignment['dueDate']))),
                      onTap: () => _selectAssignment(assignment),
                    );
                  },
                ),
              ),

            // 📌 Assignment Title Field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Assignment Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // ✍ Assignment Description Field
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // 📅 Due Date Picker
            GestureDetector(
              onTap: _pickDueDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Due Date",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.deepPurple),
                  ),
                  controller: TextEditingController(
                    text: _selectedDueDate != null
                        ? DateFormat.yMMMd().format(_selectedDueDate!)
                        : "",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Save Button
            Center(
              child: ElevatedButton(
                onPressed: _saveAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Save Assignment", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}