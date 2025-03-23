import 'package:flutter/material.dart';

class AutoFlashcardPage extends StatelessWidget {
  const AutoFlashcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Auto-Generate Flashcards"),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          "AI-powered flashcard generation will be implemented here.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      ),
    );
  }
}
