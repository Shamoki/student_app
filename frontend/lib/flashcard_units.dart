import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:onboarding/flashcards.dart';
import 'package:shared_preferences/shared_preferences.dart';


class NewFlashcardPage extends StatefulWidget {
  const NewFlashcardPage({super.key});

  @override
  State<NewFlashcardPage> createState() => _NewFlashcardPageState();
}

class _NewFlashcardPageState extends State<NewFlashcardPage> {
  List<String> units = [];
  final TextEditingController _newUnitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUnits();
  }

  Future<void> _fetchUnits() async {
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
        units = List<String>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch units")),
      );
    }
  }

  void _showAddUnitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Unit"),
          content: TextField(
            controller: _newUnitController,
            decoration: const InputDecoration(hintText: "Enter unit name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_newUnitController.text.trim().isEmpty) return;
                final newUnit = _newUnitController.text.trim();
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');

                final response = await http.post(
                  Uri.parse("http://localhost:5000/api/units"),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({"name": newUnit}),
                );

                if (response.statusCode == 201) {
                  setState(() {
                    units.add(newUnit);
                  });
                  Navigator.pop(context);
                  _newUnitController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to add unit")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🖼️ Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_soft.jpg'),
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
                    "Your Classes",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: units.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset('assets/animations/motivation.json', height: 200),
                                const SizedBox(height: 20),
                                const Text(
                                  "No Classes yet",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: units.length,
                            itemBuilder: (context, index) {
                              final unit = units[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Flashcards(unit: '',topic: ''), // ✅ Pass the selected unit
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    unit,
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
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_class",
        onPressed: _showAddUnitDialog,
        backgroundColor: Colors.deepPurple,
        tooltip: "Add Class",
        child: const Icon(Icons.add),
      ),
    );
  }
}
