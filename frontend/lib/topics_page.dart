import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flashcards.dart';

// ... same imports
class TopicsPage extends StatefulWidget {
  final String unitId;
  final String unitName;

  const TopicsPage({
    super.key,
    required this.unitId,
    required this.unitName,
  });

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  List<String> topics = [];
  final TextEditingController _newTopicController = TextEditingController();
  String? role;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _fetchTopics();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
    });
  }

  Future<void> _fetchTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/topics/${widget.unitId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            topics = List<String>.from(data);
          });
        } else {
          _showError("Unexpected response format");
        }
      } else {
        _showError("Failed to fetch topics");
      }
    } catch (e) {
      _showError("Error: $e");
    }
  }

  Future<void> _deleteTopic(String topicName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse("http://localhost:5000/api/topics/${widget.unitId}/$topicName"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      _fetchTopics();
    } else {
      _showError("Failed to delete topic");
    }
  }

  void _showEditTopicDialog(String oldName) {
    _newTopicController.text = oldName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Topic"),
          content: TextField(
            controller: _newTopicController,
            decoration: const InputDecoration(hintText: "Enter new topic name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final newName = _newTopicController.text.trim();
                if (newName.isEmpty) return;

                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');

                final response = await http.delete(
                  Uri.parse("http://localhost:5000/api/topics/${widget.unitId}/$oldName"),
                  headers: {'Authorization': 'Bearer $token'},
                );

                if (response.statusCode == 200) {
                  // Create with new name
                  await http.post(
                    Uri.parse('http://localhost:5000/api/topics'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({
                      "name": newName,
                      "unit": widget.unitId,
                    }),
                  );
                  Navigator.pop(context);
                  _newTopicController.clear();
                  _fetchTopics();
                } else {
                  _showError("Failed to edit topic");
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showAddTopicDialog() {
    _newTopicController.clear();
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
                    "unit": widget.unitId,
                  }),
                );

                if (response.statusCode == 201) {
                  Navigator.pop(context);
                  _newTopicController.clear();
                  _fetchTopics();
                } else {
                  _showError("Failed to add topic");
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
      body: Stack(children: [
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
            child: Column(children: [
              const SizedBox(height: 20),
              Text(
                "Topics for: ${widget.unitName}",
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
                            const Text("No topics yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: topics.length,
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
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
                                            unitId: widget.unitId,
                                            unitName: widget.unitName,
                                            topic: topic,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      topic,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                ),
                                if (role == 'teacher')
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.deepPurple),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditTopicDialog(topic);
                                      } else if (value == 'delete') {
                                        _deleteTopic(topic);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, color: Colors.deepPurple),
                                            SizedBox(width: 8),
                                            Text("Edit"),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text("Delete", style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ]),
          ),
        ),
      ]),
      floatingActionButton: role == 'teacher'
          ? FloatingActionButton(
              heroTag: "add_topic",
              onPressed: _showAddTopicDialog,
              backgroundColor: Colors.deepPurple,
              tooltip: "Add Topic",
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
