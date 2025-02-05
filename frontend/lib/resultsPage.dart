import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultsPage({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    // Extract predictions and image data
    final predictions = resultData['predictions'];
    final Uint8List processedImage = Uint8List.fromList(resultData['processedImage']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Results"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display the Processed Image
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(
                    processedImage,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Prediction Details Section
              const Text(
                "Prediction Details:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: Text(
                  predictions.toString(), // Display the prediction metadata
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Download Button
              ElevatedButton.icon(
                onPressed: () => _downloadImage(processedImage),
                icon: const Icon(Icons.download),
                label: const Text("Download Processed Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Exit Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text("Exit to Home"),
            ),
          ],
        ),
      ),
    );
  }

  // Function to download the processed image
  void _downloadImage(Uint8List imageBytes) {
    final blob = html.Blob([imageBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.Url.revokeObjectUrl(url);
  }
}
