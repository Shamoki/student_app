import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CustomFlashcardPage extends StatefulWidget {
  final String unitId;
  final String unitName;

  const CustomFlashcardPage({
    super.key,
    required this.unitId,
    required this.unitName,
  });

  @override
  State<CustomFlashcardPage> createState() => _CustomFlashcardPageState();
}

class _CustomFlashcardPageState extends State<CustomFlashcardPage> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _newTopicController = TextEditingController();
  bool _isLoading = false;

  List<String> topics = [];
  String? selectedTopic;

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://localhost:5000/api/topics/${Uri.encodeComponent(widget.unitId)}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final fetchedTopics = List<String>.from(json.decode(response.body));
      setState(() {
        topics = fetchedTopics;
        if (fetchedTopics.isNotEmpty && !fetchedTopics.contains(selectedTopic)) {
          selectedTopic = fetchedTopics.last;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch topics")),
      );
    }
  }

  Future<void> _addTopic(String newTopic) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/topics'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "unit": widget.unitId,
        "name": newTopic,
      }),
    );

    if (response.statusCode == 201) {
      _newTopicController.clear();
      await _fetchTopics();
      setState(() {
        selectedTopic = newTopic;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add topic")),
      );
    }
  }

  Future<void> _saveFlashcard() async {
    if (_questionController.text.isEmpty || _answerController.text.isEmpty || selectedTopic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/flashcards'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "unitId": widget.unitId,
        "topic": selectedTopic,
        "question": _questionController.text,
        "answer": _answerController.text,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Flashcard added successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add flashcard")),
      );
    }
  }

  void _showAddTopicDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Topic"),
          content: TextField(
            controller: _newTopicController,
            decoration: const InputDecoration(hintText: "Enter topic name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final newTopic = _newTopicController.text.trim();
                if (newTopic.isNotEmpty) {
                  Navigator.pop(context);
                  _addTopic(newTopic);
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
      backgroundColor: Colors.grey[100],
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
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Add Flashcard to\n${widget.unitName}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    value: selectedTopic,
                    items: topics.map((topic) {
                      return DropdownMenuItem<String>(
                        value: topic,
                        child: Text(topic),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => selectedTopic = newValue),
                    decoration: const InputDecoration(
                      labelText: "Select Topic",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showAddTopicDialog,
                      child: const Text("Add New Topic", style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      labelText: "Question",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _answerController,
                    decoration: const InputDecoration(
                      labelText: "Answer",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveFlashcard,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Save Flashcard",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
