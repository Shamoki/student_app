import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flashcards.dart';

class TopicsPage extends StatefulWidget {
  final String unit;
  const TopicsPage({super.key, required this.unit});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  List<String> topics = [];
  final TextEditingController _newTopicController = TextEditingController();

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
      Uri.parse('http://localhost:5000/api/topics/${Uri.encodeComponent(widget.unit)}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        topics = List<String>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch topics")),
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
              onPressed: () async {
                final newTopic = _newTopicController.text.trim();
                if (newTopic.isEmpty) return;

                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');

                final response = await http.post(
                  Uri.parse('http://localhost:5000/api/topics'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({
                    "name": newTopic,
                    "unit": widget.unit,
                  }),
                );

                if (response.statusCode == 201) {
                  Navigator.pop(context);
                  _newTopicController.clear();
                  _fetchTopics(); // refresh
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to add topic")),
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
          // Background
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
                  Text(
  "Topics: ${widget.unit}",
  style: const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.deepPurple,
  ),
),

                  const SizedBox(height: 20),
                  Expanded(
                    child: topics.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset('assets/animations/motivation.json', height: 200),
                                const SizedBox(height: 20),
                                const Text(
                                  "No topics yet",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: topics.length,
                            itemBuilder: (context, index) {
                              final topic = topics[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Flashcards(unit: widget.unit, topic: topic),
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
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    topic,                             
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
        heroTag: "add_topic",
        onPressed: _showAddTopicDialog,
        backgroundColor: Colors.deepPurple,
        tooltip: "Add Topic",
        child: const Icon(Icons.add),
      ),
    );
  }
}
