import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_assignment.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  List<dynamic> assignments = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/assignments'));

    if (response.statusCode == 200) {
      setState(() {
        assignments = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to fetch assignments")));
    }
  }

  Future<void> _toggleCompletion(String id) async {
    final response = await http.put(Uri.parse('http://localhost:5000/api/assignments/$id'));

    if (response.statusCode == 200) {
      _fetchAssignments();
    }
  }

  Future<void> _deleteAssignment(String id) async {
    final response = await http.delete(Uri.parse('http://localhost:5000/api/assignments/$id'));

    if (response.statusCode == 200) {
      _fetchAssignments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      
      body: assignments.isEmpty
          ? Center(  
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
 
  const Text(
    "Assignments and Deadlines",
    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.deepPurple),
  ),
  const SizedBox(height: 50), 
   // Space between the text and Lottie animation
  Lottie.asset('assets/animations/motivation.json', height: 200),
  const SizedBox(height: 20), // Space between Lottie and "No Assignments!" text
  const Text(
    "No assignments!",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
  ),
],

              ),
            )
          : ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];

                return GestureDetector(
                  onTap: () => _toggleCompletion(assignment["_id"]),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        assignment["completed"] ? Icons.check_circle : Icons.assignment,
                        color: assignment["completed"] ? Colors.green : Colors.deepPurple,
                      ),
                      title: Text(
                        assignment["title"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: assignment["completed"] ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        "Due: ${DateFormat.yMMMd().format(DateTime.parse(assignment["dueDate"]))}", // ✅ Format the date
                        style: TextStyle(color: assignment["completed"] ? Colors.grey : Colors.deepPurple),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAssignment(assignment["_id"]),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddAssignmentPage()),
        ).then((_) => _fetchAssignments()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
