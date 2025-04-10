import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// For Google OAuth
import 'package:shared_preferences/shared_preferences.dart';

class AddAssignmentPage extends StatefulWidget {
  const AddAssignmentPage({super.key});

  @override
  State<AddAssignmentPage> createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  final List<Map<String, dynamic>> _classroomAssignments = [];
  final bool _isLoading = false;

  Future<void> _pickDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    setState(() {
      _selectedDueDate = pickedDate;
    });
  }

  Future<void> _saveAssignment() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
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

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/assignments'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ✅ Token included here
      },
      body: json.encode({
        "title": _titleController.text,
        "description": _descriptionController.text,
        "dueDate": _selectedDueDate!.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, json.decode(response.body));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add assignment")),
      );
    }
  }



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
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Add Assignment",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Center(
              
            ),
            const SizedBox(height: 20),
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
                      subtitle: Text(
                        DateFormat.yMMMd()
                            .format(DateTime.parse(assignment['dueDate'])),
                      ),
                      onTap: () => _selectAssignment(assignment),
                    );
                  },
                ),
              ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Assignment Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _pickDueDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Due Date",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today,
                        color: Colors.deepPurple),
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
            Center(
              child: ElevatedButton(
                onPressed: _saveAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  "Save Assignment",
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
