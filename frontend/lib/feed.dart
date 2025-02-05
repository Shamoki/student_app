import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedPageApp extends StatefulWidget {
  const FeedPageApp({super.key});

  @override
  State<FeedPageApp> createState() => _FeedPageAppState();
}

class _FeedPageAppState extends State<FeedPageApp> {
  List<dynamic> articles = [];
  bool isLoading = true;
  bool hasError = false;
  List<String> userInterests = [];

  @override
  void initState() {
    super.initState();
    _fetchUserInterests();
  }

  // ✅ Step 1: Fetch user interests from the backend
  Future<void> _fetchUserInterests() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    if (userId == null || token == null) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse("http://localhost:5000/api/auth/get-interests/$userId"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userInterests = List<String>.from(data["interests"]["categories"] ?? []);
      });
      fetchMediumArticles();
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // ✅ Step 2: Fetch Medium articles based on user interests
  Future<void> fetchMediumArticles() async {
    if (userInterests.isEmpty) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    final String interestsQuery = userInterests.join(",");
    final String backendAPI =
        "http://localhost:5000/api/medium/articles?interests=$interestsQuery";

    try {
      final response = await http.get(Uri.parse(backendAPI));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          articles = data["items"];
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception("Failed to load articles");
      }
    } catch (e) {
      print("Error fetching articles: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      "Latest Articles",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: Lottie.asset(
                            'assets/animations/loading.json',
                            height: 200,
                          ),
                        )
                      : hasError || articles.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset('assets/animations/inspect.json', height: 150),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "No articles available based on your interests.",
                                    style: TextStyle(fontSize: 16, color: Colors.black54),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: articles.length,
                              itemBuilder: (context, index) {
                                final article = articles[index];
                                final String title = article["title"] ?? "No Title";
                                final String pubDate = article["pubDate"] ?? "Unknown Date";
                                final String url = article["link"] ?? "";

                                return GestureDetector(
                                  onTap: () async {
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      title: Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: Text(
                                        pubDate,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
