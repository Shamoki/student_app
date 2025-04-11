import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_flashcard.dart';
import 'package:flutter/services.dart';

class Flashcards extends StatefulWidget {
  final String unitId;
  final String unitName;
  final String topic;

  const Flashcards({
    super.key,
    required this.unitId,
    required this.unitName,
    required this.topic,
  });

  @override
  State<Flashcards> createState() => _FlashcardsState();
}

class _FlashcardsState extends State<Flashcards> {
  List<dynamic> flashcards = [];
  List<dynamic> filteredFlashcards = [];
  TextEditingController searchController = TextEditingController();
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchFlashcardsByTopic();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role');
    });
  }

  Future<void> _fetchFlashcardsByTopic() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse(
        'http://localhost:5000/api/flashcards?unitId=${Uri.encodeComponent(widget.unitId)}&topic=${Uri.encodeComponent(widget.topic)}',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        flashcards = json.decode(response.body);
        filteredFlashcards = flashcards;
      });
    }
  }

  Future<void> _deleteFlashcard(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('http://localhost:5000/api/flashcards/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      _fetchFlashcardsByTopic();
    }
  }

  void _showEditFlashcardDialog(Map card) {
    final questionController = TextEditingController(text: card['question']);
    final answerController = TextEditingController(text: card['answer']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Flashcard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: questionController, decoration: const InputDecoration(labelText: "Question")),
            const SizedBox(height: 10),
            TextField(controller: answerController, decoration: const InputDecoration(labelText: "Answer")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');

              final response = await http.put(
                Uri.parse('http://localhost:5000/api/flashcards/${card["_id"]}'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  "question": questionController.text.trim(),
                  "answer": answerController.text.trim(),
                }),
              );

              if (response.statusCode == 200) {
                Navigator.pop(ctx);
                _fetchFlashcardsByTopic();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _filterFlashcards(String query) {
    final results = flashcards.where((card) {
      final question = card['question'].toString().toLowerCase();
      final answer = card['answer'].toString().toLowerCase();
      return question.contains(query.toLowerCase()) || answer.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredFlashcards = results;
    });
  }

<<<<<<< HEAD
=======
  void _showFlashcardOptions() {
    if (userRole != "teacher") return;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 250,
          child: Column(
            children: [
              const Text(
                "Choose Flashcard Type",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    
                    _buildFeatureCard(
                      "Custom Flashcard",
                      Icons.create,
                      Colors.green,
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomFlashcardPage(
                              unitId: widget.unitId,
                              unitName: widget.unitName,
                              topic: widget.topic,
                            ),
                          ),
                        ).then((refresh) {
                          if (refresh == true) {
                            _fetchFlashcardsByTopic();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

>>>>>>> b32167dc5451f4d708914199e00bf71f6bdfeba0
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_soft.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white70, BlendMode.lighten),
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
                    "${widget.unitName} – ${widget.topic} Flashcards",
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search question...",
                      prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    onChanged: _filterFlashcards,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: filteredFlashcards.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                Lottie.asset('assets/animations/motivation.json', height: 180),
                                const Text("No flashcards found", style: TextStyle(color: Colors.deepPurple)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredFlashcards.length,
                            itemBuilder: (context, index) {
                              final card = filteredFlashcards[index];
                              return Stack(
                                children: [
                                  FlipFlashcard(question: card['question'], answer: card['answer']),
                                  if (userRole == "teacher")
                                    Positioned(
                                      top: 20,
                                      right: 20,
                                      child: PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, color: Colors.deepPurple),
                                        onSelected: (value) {
                                          if (value == 'edit') _showEditFlashcardDialog(card);
                                          if (value == 'delete') _deleteFlashcard(card["_id"]);
                                          if (value == 'copy') {
                                            Clipboard.setData(ClipboardData(
                                              text: "Q: ${card['question']}\nA: ${card['answer']}",
                                            ));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Copied to clipboard")),
                                            );
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(value: 'edit', child: Text("Edit")),
                                          const PopupMenuItem(value: 'delete', child: Text("Delete")),
                                          const PopupMenuItem(value: 'copy', child: Text("Copy")),
                                        ],
                                      ),
                                    ),
                                ],
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
      floatingActionButton: userRole == "teacher"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomFlashcardPage(
                      unitId: widget.unitId,
                      unitName: widget.unitName,
                      topic: widget.topic,
                    ),
                  ),
                ).then((refresh) {
                  if (refresh == true) _fetchFlashcardsByTopic();
                });
              },
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class FlipFlashcard extends StatefulWidget {
  final String question;
  final String answer;

  const FlipFlashcard({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FlipFlashcard> createState() => _FlipFlashcardState();
}

class _FlipFlashcardState extends State<FlipFlashcard> {
  bool isFlipped = false;

  void _flipCard() => setState(() => isFlipped = !isFlipped);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: isFlipped
            ? Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.green),
                  const SizedBox(width: 20),
                  Expanded(child: Text(widget.answer, style: const TextStyle(fontSize: 16))),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.flash_on, color: Colors.deepPurple),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
