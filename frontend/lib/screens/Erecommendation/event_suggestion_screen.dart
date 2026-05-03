import 'package:festio_lk/core/services/EventR_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../events/modern_event_detail_screen.dart';
import 'package:festio_lk/screens/Erecommendation/AIRecommendationPage.dart';

class EventSuggestionScreen extends StatefulWidget {
  const EventSuggestionScreen({super.key});

  @override
  State<EventSuggestionScreen> createState() => _EventSuggestionScreenState();
}

Widget _buildPreviewImage(String imageUrl) {
  final uri = Uri.tryParse(imageUrl);
  final bool isNetworkImage = uri != null && uri.hasScheme;

  if (isNetworkImage) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.event, size: 16),
        );
      },
    );
  }

  return Image.asset(
    imageUrl,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.event, size: 16),
      );
    },
  );
}

class _EventSuggestionScreenState extends State<EventSuggestionScreen> {
  List<Map<String, dynamic>> suggestions = [];
  Map<String, dynamic>? clickData;
  String userDistrict = '';

  List<Map<String, dynamic>> allEvents = [];

  List<Map<String, dynamic>> sameDistrictEvents = [];
  List<Map<String, dynamic>> similarOtherDistrictEvents = [];

  @override
  void initState() {
    super.initState();
    loadSuggestions();
  }

  String normalize(String value) {
    return value.toLowerCase().trim();
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> loadSuggestions() async {
    debugPrint('🔵 ===== loadSuggestions START =====');

    final prefs = await FirebaseService().getUserPreferences();
    final clicks = await FirebaseService().getUserClicks();
    final events = await FirebaseService().getApprovedEvents();
    allEvents = events;

    debugPrint('📦 Raw Preferences: $prefs');
    debugPrint('📊 Raw Click Data: $clicks');

    if (prefs == null) {
      debugPrint('❌ Preferences are NULL. Stopping.');
      return;
    }

    clickData = (clicks ?? {}).map((k, v) => MapEntry(k.toString().trim(), v));

    debugPrint('📊 Processed Click Data: $clickData');

    userDistrict = prefs['district'] ?? '';
    List<String> preferred =
        List<String>.from(prefs['preferredCategories'] ?? []);

    debugPrint('📍 User District: $userDistrict');
    debugPrint('🎯 Preferred Categories: $preferred');

    // 1️⃣ Filter user's district events by preferred categories
    sameDistrictEvents = allEvents.where((event) {
      bool categoryMatch = preferred
          .map((e) => normalize(e))
          .contains(normalize(event['category']));

      bool districtMatch =
          normalize(event['location']).contains(normalize(userDistrict));

      debugPrint("🔎 Checking Event: ${event['title']} | "
          'CategoryMatch: $categoryMatch | '
          'DistrictMatch: $districtMatch');

      return categoryMatch && districtMatch;
    }).toList();

    debugPrint('✅ Same District Events Found: ${sameDistrictEvents.length}');

    // Sort by duration first, then clicks
    for (var event in sameDistrictEvents) {
      final duration =
          await FirebaseService().getEventTotalDurationByTitle(event['title']);

      event['duration'] = duration;

      event['clickCount'] = clickData?[event['title'].toString().trim()] ?? 0;

      debugPrint("⏱ Event: ${event['title']} | "
          "Duration: ${event['duration']} | "
          "Clicks: ${event['clickCount']}");
    }

    sameDistrictEvents.sort((a, b) {
      if (b['duration'] != a['duration']) {
        return b['duration'].compareTo(a['duration']);
      } else {
        return b['clickCount'].compareTo(a['clickCount']);
      }
    });

    debugPrint('📊 After Sorting Same District Events:');
    for (var e in sameDistrictEvents) {
      debugPrint(
          "🏆 ${e['title']} | Duration: ${e['duration']} | Clicks: ${e['clickCount']}");
    }

    // Determine top event
    similarOtherDistrictEvents = [];

    if (sameDistrictEvents.isNotEmpty) {
      Map<String, dynamic> topEvent = sameDistrictEvents.first;

      debugPrint("🥇 Top Event Selected: ${topEvent['title']}");

      // Filter similar events in other districts
      similarOtherDistrictEvents = allEvents.where((event) {
        bool sameCategory =
            normalize(event['category']) == normalize(topEvent['category']);

        bool differentDistrict =
            !normalize(event['location']).contains(normalize(userDistrict));

        debugPrint("🔁 Checking Similar Event: ${event['title']} | "
            'SameCategory: $sameCategory | '
            'DifferentDistrict: $differentDistrict');

        return sameCategory && differentDistrict;
      }).toList();

      debugPrint(
          '🌍 Similar Events Found: ${similarOtherDistrictEvents.length}');

      // Sort similar events by clicks
      similarOtherDistrictEvents.sort((a, b) {
        int clicksA = clickData?[a['title'].toString().trim()] ?? 0;
        int clicksB = clickData?[b['title'].toString().trim()] ?? 0;
        return clicksB.compareTo(clicksA);
      });

      debugPrint('📊 After Sorting Similar Events:');
      for (var e in similarOtherDistrictEvents) {
        debugPrint(
            "⭐ ${e['title']} | Clicks: ${clickData?[e['title'].toString().trim()] ?? 0}");
      }
    } else {
      debugPrint('⚠️ No Same District Events Found.');
    }

    debugPrint('🔵 ===== loadSuggestions END =====');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141A3D),
        title: const Text('Recommended For You'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥🔥🔥 ADDED AI BUTTON HERE (TOP LEFT)
              if (sameDistrictEvents.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.smart_toy, color: Colors.white),
                    label: const Text(
                      'AI Insights',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      final topEvent = sameDistrictEvents.first;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AIRecommendationPage(
                            topEventTitle: topEvent['title'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 🔥 YOUR ORIGINAL CODE CONTINUES BELOW (UNCHANGED)

              if (sameDistrictEvents.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Events You May Like',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sameDistrictEvents.length,
                    itemBuilder: (context, index) {
                      final event = sameDistrictEvents[index];
                      bool isMostPopular = index == 0;
                      return buildEventCard(event,
                          isMostPopular: isMostPopular);
                    },
                  ),
                ),
              ],
              if (similarOtherDistrictEvents.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Recommended Similar Events in Other Districts',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: similarOtherDistrictEvents.length,
                    itemBuilder: (context, index) {
                      final event = similarOtherDistrictEvents[index];
                      return buildEventCard(event, isMostPopular: false);
                    },
                  ),
                ),
              ],
              if (sameDistrictEvents.isNotEmpty &&
                  similarOtherDistrictEvents.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No similar events available in other districts',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEventCard(Map<String, dynamic> event,
      {required bool isMostPopular}) {
    int clickCount = clickData?[event['title'].toString().trim()] ?? 0;
    int durationSeconds = event['duration'] ?? 0;
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;

    return GestureDetector(
      onTap: () async {
        final openedAt = DateTime.now();

        // Start or update the session in Firestore
        await FirebaseService()
            .startOrUpdateEventSession(eventTitle: event['title']);

        // Navigate to event detail page
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ModernEventDetailScreen(
              title: event['title'],
              date: event['date'] != null
                  ? "${(event['date'] as DateTime).day}/"
                      "${(event['date'] as DateTime).month}/"
                      "${(event['date'] as DateTime).year}"
                  : '',
              location: event['location'],
              imageUrl: event['imageUrl'],
            ),
          ),
        );

        // After returning, end session and update duration
        await FirebaseService()
            .endEventSession(eventTitle: event['title'], openedAt: openedAt);

        // Increment clicks
        await FirebaseService().incrementEventClick(event['title'].toString());

        // Reload suggestions and update UI
        await loadSuggestions();
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isMostPopular
              ? Border.all(color: Colors.orangeAccent, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: isMostPopular
                  ? Colors.orange.withOpacity(0.6)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isMostPopular ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildPreviewImage(
                  (event['imageUrl'] ?? event['image_url'] ?? '').toString(),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              if (isMostPopular)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Most Like',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${event['date']} • ${event['location']}",
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.visibility,
                            size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '$clickCount clicks',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.timer,
                            size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '$minutes m $seconds s spent',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: Colors.white),
                        ),
                      ],
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
}
