import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'topics_page.dart';

class EnrollInUnitPage extends StatefulWidget {
  const EnrollInUnitPage({super.key});

  @override
  State<EnrollInUnitPage> createState() => _EnrollInUnitPageState();
}

class _EnrollInUnitPageState extends State<EnrollInUnitPage> {
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> enrolledUnits = [];

  @override
  void initState() {
    super.initState();
    _fetchEnrolledUnits();
  }

  Future<void> _fetchEnrolledUnits() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://localhost:5000/api/units'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        enrolledUnits = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch your units")),
        );
      }
    }
  }

  void _showEnrollDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Join Unit with Code"),
          content: TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              hintText: "Enter unit code",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      await _enrollStudent();
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Join"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _enrollStudent() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/units/enroll-by-code'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'code': code}),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final unit = json.decode(response.body);
      _codeController.clear();
      await _fetchEnrolledUnits(); // Auto-refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Successfully joined ${unit['name']}")),
        );
      }
    } else {
      final error = json.decode(response.body)['error'] ?? 'Enrollment failed';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/background_soft.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.9),
                  BlendMode.lighten,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Enrolled Units:",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchEnrolledUnits,
                      child: enrolledUnits.isEmpty
                          ? ListView(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset('assets/animations/motivation.json', height: 200),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "You're not enrolled in any units yet",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: enrolledUnits.length,
                              itemBuilder: (context, index) {
                                final unit = enrolledUnits[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TopicsPage(
                                          unitId: unit['_id'],
                                          unitName: unit['name'],
                                          
                                          
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                                      ],
                                    ),
                                    child: Text(
                                      unit['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEnrollDialog,
        backgroundColor: Colors.deepPurple,
        tooltip: "Join Unit",
        child: const Icon(Icons.add),
      ),
    );
  }
}
