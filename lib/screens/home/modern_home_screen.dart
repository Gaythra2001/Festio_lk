import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';

import '../events/modern_event_detail_screen.dart';
import '../submission/event_submission_screen.dart';
import '../profile/modern_profile_screen.dart';
import '../recommendations/ai_recommendations_screen.dart';

import '../../widgets/event_calendar.dart';
import '../../widgets/juice_rating.dart';
import '../../core/providers/notification_provider.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _showAIBot = false;
  bool _showCalendar = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.addSystemNotification(
        'Welcome Back!',
        'Check out new cultural events in your area',
      );
    });
  }

  // Sample events
  final List<Map<String, dynamic>> _allEvents = [
    {
      'title': 'Kandy Esala Perahera',
      'date': 'Aug 15, 2024',
      'location': 'Kandy, Sri Lanka',
      'category': 'Festival',
      'imageUrl':
          'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800',
      'juice': 4.8,
    },
    {
      'title': 'Traditional Dance Performance',
      'date': 'Aug 20, 2024',
      'location': 'Colombo, Sri Lanka',
      'category': 'Dance',
      'imageUrl':
          'https://images.unsplash.com/photo-1504609773096-104ff2c73ba4?w=800',
      'juice': 4.2,
    },
  ];

  List<Map<String, dynamic>> get _filteredEvents {
    var events = _allEvents;

    if (_selectedCategory != 'All') {
      events = events.where((e) => e['category'] == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      events = events.where((e) {
        final title = e['title'].toLowerCase();
        final location = e['location'].toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || location.contains(query);
      }).toList();
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Festio LK',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              decoration: InputDecoration(
                                hintText: 'search_events'.tr(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.smart_toy,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AIRecommendationsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      ..._filteredEvents.map(
                        (event) => _buildEventCard(
                          title: event['title'],
                          date: event['date'],
                          location: event['location'],
                          imageUrl: event['imageUrl'],
                          juice: event['juice'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_showAIBot) _buildAIBotOverlay(),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required String date,
    required String location,
    required String imageUrl,
    required double juice,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(date, style: const TextStyle(color: Colors.white70)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ModernEventDetailScreen(
              title: title,
              date: date,
              location: location,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIBotOverlay() {
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
