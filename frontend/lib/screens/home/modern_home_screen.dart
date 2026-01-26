import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';

import '../events/modern_event_detail_screen.dart';
import '../submission/event_submission_screen.dart';
import '../recommendations/ai_recommendations_screen.dart';
import '../organizer/organizer_promotion_screen.dart';

import '../../widgets/event_calendar.dart';
import '../../widgets/juice_rating.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/providers/event_provider.dart';
import '../../widgets/app_footer.dart';
import 'package:intl/intl.dart';

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

      // Load upcoming events from provider
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.loadUpcomingEvents();
    });
  }

  // Sample events data
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
    {
      'title': 'Cultural Music Festival',
      'date': 'Sep 5, 2024',
      'location': 'Galle, Sri Lanka',
      'category': 'Music',
      'imageUrl':
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800',
      'juice': 4.6,
    },
    {
      'title': 'Vesak Lantern Festival',
      'date': 'May 23, 2024',
      'location': 'Colombo, Sri Lanka',
      'category': 'Festival',
      'imageUrl':
          'https://images.unsplash.com/photo-1478145787956-f6f12c59624d?w=800',
      'juice': 3.9,
    },
    {
      'title': 'Traditional Theater Show',
      'date': 'Sep 10, 2024',
      'location': 'Kandy, Sri Lanka',
      'category': 'Theater',
      'imageUrl':
          'https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?w=800',
      'juice': 3.5,
    },
    {
      'title': 'Baila Night Concert',
      'date': 'Oct 2, 2024',
      'location': 'Negombo, Sri Lanka',
      'category': 'Music',
      'imageUrl':
          'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800',
      'juice': 4.4,
    },
  ];

  List<Map<String, dynamic>> get _filteredEvents {
    // Get events from provider
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final providerEvents = eventProvider.upcomingEvents.map((event) {
      return {
        'title': event.title,
        'date': DateFormat('MMM dd, yyyy').format(event.startDate),
        'location': event.location,
        'category': event.category,
        'imageUrl': event.imageUrl ??
            'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800',
        'juice': 4.5, // Default rating
      };
    }).toList();

    // Combine with hardcoded sample events
    var events = [...providerEvents, ..._allEvents];

    // Filter by category
    if (_selectedCategory != 'All') {
      events = events.where((e) => e['category'] == _selectedCategory).toList();
    }

    // Filter by search query
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

              // Content
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
                          // AI Bot Button - Professional styling
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF667eea)
                                          .withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.smart_toy_outlined,
                                      color: Colors.white, size: 22),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AIRecommendationsScreen(),
                                      ),
                                    );
                                  },
                                  tooltip: 'AI Recommendations',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8fd3f4),
                                      Color(0xFF84fab0)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF84fab0)
                                          .withOpacity(0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.campaign_outlined,
                                      color: Colors.white, size: 22),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const OrganizerPromotionScreen(),
                                      ),
                                    );
                                  },
                                  tooltip: 'Organizer Dashboard',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Categories
                      Text(
                        'category'.tr(),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryChip('All'),
                            _buildCategoryChip('Music'),
                            _buildCategoryChip('Dance'),
                            _buildCategoryChip('Festival'),
                            _buildCategoryChip('Theater'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Calendar Section
                      if (_showCalendar)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'event_calendar',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Consumer<EventProvider>(
                              builder: (context, eventProvider, child) {
                                return EventCalendar(
                                  events: eventProvider.upcomingEvents,
                                  onDateSelected: (date) {
                                    // Handle date selection
                                  },
                                  onEventsForDateChanged: (events) {
                                    // Handle events for selected date
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),

                      // Featured Events
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Search Results (${_filteredEvents.length})'
                                : _selectedCategory == 'All'
                                    ? 'Featured Events'
                                    : '$_selectedCategory Events',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty ||
                              _selectedCategory != 'All')
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _selectedCategory = 'All';
                                  _searchController.clear();
                                });
                              },
                              child: Text(
                                'Clear',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6C63FF),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Event Cards
                      if (_filteredEvents.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.white38,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No events found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._filteredEvents.map((event) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildEventCard(
                                title: event['title']!,
                                date: event['date']!,
                                location: event['location']!,
                                imageUrl: event['imageUrl']!,
                                juice: event['juice']! as double,
                              ),
                            )),

                      const SizedBox(height: 40),
                      const AppFooter(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // AI Bot Overlay
          if (_showAIBot) _buildAIBotOverlay(),
        ],
      ),

      // Floating Action Button - Professional styling
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EventSubmissionScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, size: 24),
          label: Text(
            'Add Event',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  )
                : null,
            color: isSelected ? null : const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ),
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
    return GestureDetector(
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
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 25,
              offset: const Offset(0, 12),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF1A1F3A),
                      child: const Icon(Icons.event, color: Colors.white38),
                    );
                  },
                ),
              ),

              // Gradient Overlay - Enhanced for better readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    JuiceRatingCompact(rating: juice),
                  ],
                ),
              ),

              // Favorite Button with glass effect
              Positioned(
                top: 16,
                right: 16,
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIBotOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showAIBot = false;
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping on the bot
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F3A),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF667eea),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.25),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // AI Icon with gradient
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'AI Event Recommender',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Get personalized event recommendations based on your interests and location!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Recommendation Buttons
                    _buildAIButton(
                      'Recommend Events Near Me',
                      Icons.location_on,
                      () {
                        setState(() {
                          _showAIBot = false;
                          _selectedCategory = 'All';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                '🤖 AI found 6 events near you in Colombo!'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    _buildAIButton(
                      'Based on My Interests',
                      Icons.favorite,
                      () {
                        setState(() {
                          _showAIBot = false;
                          _selectedCategory = 'Music';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('🤖 AI recommends Music events for you!'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    _buildAIButton(
                      'Popular Right Now',
                      Icons.trending_up,
                      () {
                        setState(() {
                          _showAIBot = false;
                          _selectedCategory = 'Festival';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('🤖 Showing trending Festival events!'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // Close Button
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAIBot = false;
                        });
                      },
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIButton(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
