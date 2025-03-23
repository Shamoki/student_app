import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:lottie/lottie.dart';
import 'custom_flashcard.dart';
import 'auto_flashcard.dart';
import 'package:flutter/services.dart';

class Flashcards extends StatefulWidget {
  final String unit;
  const Flashcards({super.key, required this.unit});

  @override
  State<Flashcards> createState() => _FlashcardsState();
}

class _FlashcardsState extends State<Flashcards> {
  List<dynamic> flashcards = [];
  List<dynamic> filteredFlashcards = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFlashcardsByUnit();
  }

  Future<void> _fetchFlashcardsByUnit() async {
    final response = await http.get(Uri.parse(
        'http://localhost:5000/api/flashcards?unit=${Uri.encodeComponent(widget.unit)}'));

    if (response.statusCode == 200) {
      setState(() {
        flashcards = json.decode(response.body);
        filteredFlashcards = flashcards;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch flashcards for this unit")),
      );
    }
  }

  Future<void> _deleteFlashcard(String id) async {
    final response = await http.delete(Uri.parse('http://localhost:5000/api/flashcards/$id'));

    if (response.statusCode == 200) {
      _fetchFlashcardsByUnit(); // Refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete flashcard")),
      );
    }
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

  void _showFlashcardOptions() {
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
                      "Auto-Generate",
                      Icons.auto_awesome,
                      Colors.blue,
                      () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AutoFlashcardPage()));
                      },
                    ),
                    _buildFeatureCard(
                      "Custom Flashcard",
                      Icons.create,
                      Colors.green,
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CustomFlashcardPage(unit: '',)),
                        ).then((refresh) {
                          if (refresh == true) {
                            _fetchFlashcardsByUnit();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
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
                      widget.unit,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search question...",
                        prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: _filterFlashcards,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: filteredFlashcards.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset('assets/animations/motivation.json', height: 180),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "No flashcards found.",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.deepPurple),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredFlashcards.length,
                              itemBuilder: (context, index) {
                                final card = filteredFlashcards[index];
                                return GestureDetector(
                                  onLongPress: () {
                                    showMenu(
                                      context: context,
                                      position: RelativeRect.fromLTRB(100, 100, 100, 100),
                                      items: [
                                        PopupMenuItem(
                                          child: const Text("Copy"),
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(
                                              text: "Q: ${card['question']}\nA: ${card['answer']}"));
                                          },
                                        ),
                                        PopupMenuItem(
                                          child: const Text("Delete"),
                                          onTap: () {
                                            Future.delayed(Duration.zero, () {
                                              _deleteFlashcard(card["_id"]);
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                  child: FlipFlashcard(
                                    question: card["question"],
                                    answer: card["answer"],
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
          onPressed: _showFlashcardOptions,
          child: const Icon(Icons.add),
          backgroundColor: Colors.deepPurple,
        ),
      ),
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

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: const EdgeInsets.symmetric(vertical: 10),
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            final rotate = Tween(begin: pi, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: rotate,
              child: child,
              builder: (context, child) {
                final isUnder = (ValueKey(isFlipped) != child?.key);
                final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
                return Transform(
                  transform: Matrix4.rotationY(value),
                  alignment: Alignment.center,
                  child: child,
                );
              },
            );
          },
          layoutBuilder: (widget, list) => Stack(children: [if (widget != null) widget, ...list]),
          child: isFlipped ? _buildCardBack() : _buildCardFront(),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      key: const ValueKey(false),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.flash_on, size: 36, color: Colors.deepPurple),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              widget.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      key: const ValueKey(true),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, size: 36, color: Colors.green),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              widget.answer,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
