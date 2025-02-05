import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class GariscanWaitingPage extends StatefulWidget {
  const GariscanWaitingPage({super.key, required String userId});

  @override
  // ignore: library_private_types_in_public_api
  _GariscanWaitingPageState createState() => _GariscanWaitingPageState();
}

class _GariscanWaitingPageState extends State<GariscanWaitingPage> {
  late IO.Socket socket; // Define the WebSocket client
  String? userId; // To store the userId fetched from SharedPreferences

  @override
  void initState() {
    super.initState();
    _initializeSocket(); // Initialize WebSocket after fetching userId
  }

  Future<void> _initializeSocket() async {
    // Fetch userId from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId == null || userId!.isEmpty) {
      print('Error: userId is empty or null. Redirecting to login.');
      Navigator.pushReplacementNamed(context, '/login'); // Redirect to login
      return;
    }

    // Initialize WebSocket connection
    socket = IO.io('http://localhost:5000', <String, dynamic>{ // Replace with your backend URL
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    // Join the user's WebSocket room
    socket.onConnect((_) {
      print('Connected to WebSocket');
      socket.emit('join', userId); // Send userId to join the room
    });

    // Listen for predictionComplete event
    socket.on('predictionComplete', (data) {
      print('Prediction received: $data');
      _handlePredictionComplete(data);
    });

    // Listen for processingError event
    socket.on('processingError', (data) {
      print('Processing error: $data');
      _handleProcessingError(data);
    });

    // Handle disconnection
    socket.onDisconnect((_) => print('Disconnected from WebSocket'));
  }

  @override
  void dispose() {
    socket.disconnect(); // Disconnect the WebSocket when the page is disposed
    super.dispose();
  }

  // Handle prediction completion
  void _handlePredictionComplete(dynamic data) {
    Navigator.pushReplacementNamed(
      context,
      '/result', // Redirect to result page
      arguments: {
        'predictions': data['predictions'], // Prediction data
        'processedImage': data['processedImage'], // Processed image
      },
    );
  }

  // Handle processing error
  void _handleProcessingError(dynamic data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(data['msg'] ?? 'An error occurred during processing.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color.fromARGB(255, 240, 240, 240)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lottie Animation
            Expanded(
              flex: 4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Lottie.asset(
                    'assets/animations/inspect.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Tagline Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                children: const [
                  Text(
                    "While You Wait for us to analyze, take note of some safety tips:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Safety Tips Carousel
            Expanded(
              flex: 5,
              child: PageView(
                controller: PageController(viewportFraction: 0.85),
                children: [
                  _buildSafetyCard(
                    icon: Icons.warning,
                    title: "Move to Safety",
                    description: "If possible, move to the side of the road to avoid traffic.",
                  ),
                  _buildSafetyCard(
                    icon: Icons.phone,
                    title: "Emergency Assistance",
                    description: "Call Kenya's emergency number 999 for help.",
                  ),
                  _buildSafetyCard(
                    icon: Icons.camera_alt,
                    title: "Document the Scene",
                    description: "Take photos and exchange contact details.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.purple),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
