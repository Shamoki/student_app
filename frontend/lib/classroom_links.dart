import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // For Clipboard
import 'package:url_launcher/url_launcher.dart'; // For opening URLs
import 'dart:convert';
import 'classroom_form.dart';

class ClassroomLinksPage extends StatefulWidget {
  const ClassroomLinksPage({super.key});
  @override
  State<ClassroomLinksPage> createState() => _ClassroomLinksPageState();
}

class _ClassroomLinksPageState extends State<ClassroomLinksPage> {
  List<Map<String, dynamic>> classroomLinks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClassroomLinks();
  }

  Future<void> fetchClassroomLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("⚠️ No token found in SharedPreferences");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/classroom-links'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          classroomLinks = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Fetch failed: ${response.body}")),
        );
      }
    } catch (e) {
      print("🔥 EXCEPTION: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching: $e")),
      );
    }
  }

  void _goToAddForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClassroomLinksForm()),
    );
    await fetchClassroomLinks(); // Refresh after returning
  }

  Future<void> _launchMeetingUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the link")),
      );
    }
  }

  void _showLinkDetails(Map<String, dynamic> link) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(link['className'], style: const TextStyle(color: Colors.deepPurple)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Platform: ${link['platform']}"),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(child: Text("Class Code:")),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.deepPurple),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link['classCode']));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Class code copied")),
                    );
                  },
                )
              ],
            ),
            SelectableText(link['classCode']),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(child: Text("Meeting Link:")),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.deepPurple),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link['meetingLink']));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Meeting link copied")),
                    );
                  },
                )
              ],
            ),
            GestureDetector(
              onTap: () => _launchMeetingUrl(link['meetingLink']),
              child: Text(
                link['meetingLink'],
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.deepPurple)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Optional background image
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
                    "Online Class Links",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : classroomLinks.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset('assets/animations/motivation.json', height: 200),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "No online class links yet",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: classroomLinks.length,
                                itemBuilder: (context, index) {
                                  final link = classroomLinks[index];
                                  return GestureDetector(
                                    onTap: () => _showLinkDetails(link),
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
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            link['className'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text("Platform: ${link['platform']}"),
                                        ],
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
        heroTag: "add_classroom_link",
        onPressed: _goToAddForm,
        backgroundColor: Colors.deepPurple,
        tooltip: "Add Link",
        child: const Icon(Icons.add),
      ),
    );
  }
}
