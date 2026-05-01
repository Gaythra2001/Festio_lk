import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:festio_lk/core/services/EventR_service.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AIRecommendationPage extends StatefulWidget {
  final String? topEventTitle;

  const AIRecommendationPage({super.key, this.topEventTitle});

  @override
  _AIRecommendationPageState createState() => _AIRecommendationPageState();
}

class _AIRecommendationPageState extends State<AIRecommendationPage> {
  final FirebaseService _firebaseService = FirebaseService();

  String _eventTopic = "";
  bool _isLoading = true;

  // Separate lists for clean professional display
  List<Map<String, String>> _events = [];
  List<Map<String, String>> _videos = [];
  List<Map<String, String>> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  /// Fetch results from Node.js proxy
  Future<void> fetchProxyResults(String query) async {
    setState(() {
      _isLoading = true;
      _events = [];
      _videos = [];
      _questions = [];
    });

    try {
      final url = Uri.parse(
        'http://localhost:3000/search?q=${Uri.encodeComponent(query)}', // Change to deployed URL in production
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Events
        for (var item in data['events_results'] ?? []) {
          _events.add({
            'title': item['title'] ?? "",
            'snippet': "${item['type'] ?? ""} • ${item['date'] ?? ""} • ${item['time'] ?? ""}",
            'link': "", // No direct link
            'thumbnail': item['thumbnail'] ?? "",
          });
        }

        // Videos
        for (var video in data['inline_videos'] ?? []) {
          _videos.add({
            'title': video['title'] ?? "",
            'snippet': "Video from ${video['platform'] ?? ""}",
            'link': video['link'] ?? "",
            'thumbnail': video['thumbnail'] ?? "",
          });
        }

        // Related Questions
        for (var q in data['related_questions'] ?? []) {
          _questions.add({
            'title': q['question'] ?? "",
            'snippet': q['snippet'] ?? "",
            'link': q['link'] ?? "",
            'thumbnail': "",
          });
        }
      } else {
        debugPrint("Proxy error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fetch top event
  Future<void> _fetchEventDetails() async {
    String? topTopic = widget.topEventTitle;
    if (topTopic != null && topTopic.isNotEmpty) {
      debugPrint("Using passed event: $topTopic");
    } else {
      final clicks = await _firebaseService.getUserClicks();
      if (clicks == null || clicks.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      topTopic = clicks.entries
          .reduce((a, b) => (a.value as int) > (b.value as int) ? a : b)
          .key;
    }

    setState(() {
      _eventTopic = topTopic!;
    });

    await fetchProxyResults(topTopic);
  }

  /// Open URL in browser
  void _launchURL(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Build a professional card with optional image
  Widget _buildItemCard(Map<String, String> item) {
    return GestureDetector(
      onTap: () => _launchURL(item['link'] ?? ""),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item['thumbnail'] != null && item['thumbnail']!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['thumbnail']!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              if (item['thumbnail'] != null && item['thumbnail']!.isNotEmpty)
                const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? "",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['snippet'] ?? "",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a section with a title
  Widget _buildSection(String title, List<Map<String, String>> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.map(_buildItemCard).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Top Event Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your most popular interest:",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _eventTopic,
                      style: const TextStyle(fontSize: 24, color: Colors.blue),
                    ),
                    const Divider(height: 30),
                    _buildSection("Events", _events),
                    _buildSection("Videos", _videos),
                    _buildSection("Related Questions", _questions),
                    Center(
                      child: ElevatedButton(
                        onPressed: _fetchEventDetails,
                        child: const Text("Refresh Results"),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}