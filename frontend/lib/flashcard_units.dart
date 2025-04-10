import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<Map<String, dynamic>> units = [];
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
        units = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch units")),
        );
      }
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final newUnit = _newUnitController.text.trim();
                if (newUnit.isEmpty) return;

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
                  final addedUnit = json.decode(response.body);
                  if (!mounted) return;
                  Navigator.of(context).pop(); // Close the add unit dialog
                  _newUnitController.clear();
                  setState(() {
                    units.add(addedUnit);
                  });

                  await Future.delayed(const Duration(milliseconds: 100));

                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Unit Created"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Share this class code with students:"),
                          const SizedBox(height: 10),
                          SelectableText(
                            addedUnit['code'] ?? 'N/A',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: addedUnit['code'] ?? ''),
                              );
                              if (mounted) Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text("Copy Code"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  if (!mounted) return;
                  Navigator.of(context).pop();
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

  Future<void> _deleteUnit(String unitId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse("http://localhost:5000/api/units/$unitId"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        units.removeWhere((u) => u['_id'] == unitId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unit and its flashcards deleted")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete unit")),
        );
      }
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> unit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Unit and Flashcards"),
          content: Text("Are you sure you want to delete \"${unit['name']}\" and all its flashcards?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUnit(unit['_id']);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
                    "Flashcard Unit:",
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
                                  "You have no flashcards yet",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: units.length,
                            itemBuilder: (context, index) {
                              final unit = units[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => Flashcards(
                                                unitId: unit['_id'],
                                                unitName: unit['name'],
                                                topic: '',
                                                unit: '',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          unit['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert, color: Colors.deepPurple),
  onSelected: (value) async {
    if (value == 'delete') {
      _showDeleteConfirmation(unit);
    } else if (value == 'copy_code') {
      await Clipboard.setData(ClipboardData(text: unit['code'] ?? ''));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unit code copied")),
        );
      }
    }
  },
  itemBuilder: (BuildContext context) => [
    PopupMenuItem<String>(
      value: 'copy_code',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.copy, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Copy Code"),
                const SizedBox(height: 4),
                Text(
                  unit['code'] ?? 'N/A',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'delete',
      child: Row(
        children: const [
          Icon(Icons.delete, color: Colors.red),
          SizedBox(width: 8),
          Text("Delete", style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
  ],
)

                                  ],
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
        tooltip: "Add Unit",
        child: const Icon(Icons.add),
      ),
    );
  }
}
