import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'interests.dart'; // Optional: if you're using readableCategoryNames from a shared file

class FeedPageApp extends StatefulWidget {
  const FeedPageApp({super.key});

  @override
  State<FeedPageApp> createState() => _FeedPageAppState();
}

class _FeedPageAppState extends State<FeedPageApp> {
  List<dynamic> articles = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchRecommendedArticles();
  }

  Future<void> fetchRecommendedArticles() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    if (userId == null || token == null) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    try {
      final interestRes = await http.get(
        //change ip address
        Uri.parse("http://192.168.1.44:5001/api/auth/get-interests/$userId"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (interestRes.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          hasError = true;
        });
        return;
      }

      final interests = json.decode(interestRes.body);
      final categories = List<String>.from(interests["interests"]["categories"] ?? []);

      if (categories.isEmpty) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          hasError = true;
        });
        return;
      }

      final flaskRes = await http.post(
        //change ip address
        Uri.parse("http://192.168.1.44:5001/recommend/categories"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'topics': categories}),
      );

      if (flaskRes.statusCode == 200) {
        final data = json.decode(flaskRes.body);
        if (!mounted) return;
        setState(() {
          articles = data;
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  String formatCategories(String raw) {
    return raw
        .split(' ')
        .map((c) => readableCategoryNames[c.trim()] ?? c.trim())
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: Text(
                  "Recommended Articles",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchRecommendedArticles,
                edgeOffset: 20,
                displacement: 60,
                color: Colors.deepPurple,
                child: isLoading
                    ? Center(
                        child: Lottie.asset(
                          'assets/animations/loading.json',
                          height: 150,
                        ),
                      )
                    : hasError || articles.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 100),
                              Lottie.asset('assets/animations/inspect.json', height: 150),
                              const SizedBox(height: 16),
                              const Center(
                                child: Text(
                                  "No recommendations available.",
                                  style: TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              final article = articles[index];
                              final title = article['title'] ?? 'Untitled';
                              final category = article['categories'] ?? 'Unknown';
                              final link = article['link'] ?? '';

                              return GestureDetector(
                                onTap: () async {
                                  final uri = Uri.parse(link);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        formatCategories(category),
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        "Read more...",
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
