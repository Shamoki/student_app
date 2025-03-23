import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResourcesPage extends StatefulWidget {
  final String subject;

  const ResourcesPage({super.key, required this.subject});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  List<dynamic> resources = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  Future<void> _fetchResources() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/resources/${widget.subject}'));

    if (response.statusCode == 200) {
      setState(() {
        resources = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to fetch resources")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.subject} - Resources"),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : resources.isEmpty
              ? const Center(
                  child: Text(
                    "No resources available!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                )
              : ListView.builder(
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final resource = resources[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: _getResourceIcon(resource["type"]),
                        title: Text(
                          resource["title"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(resource["description"]),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new, color: Colors.blue),
                          onPressed: () {
                            _openResource(resource["url"]);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Open the resource link
  void _openResource(String url) {
    // Implement URL launcher (import 'package:url_launcher/url_launcher.dart';)
    // launch(url);
  }

  // Get an appropriate icon based on the resource type
  Widget _getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case "pdf":
        return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40);
      case "video":
        return const Icon(Icons.video_library, color: Colors.blue, size: 40);
      case "article":
        return const Icon(Icons.article, color: Colors.orange, size: 40);
      default:
        return const Icon(Icons.book, color: Colors.green, size: 40);
    }
  }
}
