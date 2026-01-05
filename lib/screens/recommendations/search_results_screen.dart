import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_preferences_model.dart';
import '../../core/models/event_model.dart';
import '../../core/providers/event_provider.dart';
import '../events/modern_event_detail_screen.dart';

/// Google-Style Search Results Screen
class SearchResultsScreen extends StatefulWidget {
  final UserPreferencesModel userPreferences;

  const SearchResultsScreen({
    Key? key,
    required this.userPreferences,
  }) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<EventModel> _systemEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
    // Disable right-click on web
    _disableRightClick();
  }

  void _disableRightClick() {
    // Add JavaScript to disable right-click
    if (identical(0, 0.0)) {
      // This is web
      SystemChannels.platform.invokeMethod('disableRightClick');
    }
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);

    try {
      debugPrint('🔍 Loading search results...');
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // Filter events based on user preferences
      final allEvents = eventProvider.events;
      debugPrint('📊 Total events available: ${allEvents.length}');

      final filteredEvents = _filterEventsByPreferences(allEvents);
      debugPrint('✅ Filtered events: ${filteredEvents.length}');

      setState(() {
        _systemEvents = filteredEvents;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading results: $e');
      setState(() => _isLoading = false);
    }
  }

  List<EventModel> _filterEventsByPreferences(List<EventModel> events) {
    return events.where((event) {
      // Filter by budget
      if (event.ticketPrice != null &&
          widget.userPreferences.maxBudget != null) {
        if (event.ticketPrice! > widget.userPreferences.maxBudget!) {
          return false;
        }
      }

      // Filter by area
      if (widget.userPreferences.primaryArea != null) {
        if (!event.location
            .toLowerCase()
            .contains(widget.userPreferences.primaryArea!)) {
          return false;
        }
      }

      // Filter by event type
      if (widget.userPreferences.favoriteEventTypes.isNotEmpty) {
        final eventCategory = event.category.toLowerCase();
        final matchesType = widget.userPreferences.favoriteEventTypes.any(
          (type) =>
              eventCategory.contains(type) ||
              event.tags.any(
                (tag) => tag.toLowerCase().contains(type),
              ),
        );
        if (!matchesType) return false;
      }

      // Filter by artist
      if (widget.userPreferences.favoriteArtists.isNotEmpty) {
        final eventText = '${event.title} ${event.description}'.toLowerCase();
        final matchesArtist = widget.userPreferences.favoriteArtists.any(
          (artist) => eventText.contains(artist.toLowerCase()),
        );
        if (matchesArtist) return true;
      }

      return true;
    }).toList();
  }

  String _buildSearchQuery() {
    final parts = <String>[];

    if (widget.userPreferences.favoriteEventTypes.isNotEmpty) {
      parts.add(widget.userPreferences.favoriteEventTypes.join(' '));
    }

    if (widget.userPreferences.favoriteArtists.isNotEmpty) {
      parts.add(widget.userPreferences.favoriteArtists.first);
    }

    if (widget.userPreferences.primaryArea != null) {
      parts.add('in ${widget.userPreferences.primaryArea}');
    }

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onSecondaryTap: () {
          // Disable right-click
          return;
        },
        child: CustomScrollView(
          slivers: [
            // Google-style App Bar
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              toolbarHeight: 70,
              flexibleSpace: _buildGoogleHeader(),
            ),

            // Search Stats
            SliverToBoxAdapter(
              child: _buildSearchStats(),
            ),

            // System Events Section
            SliverToBoxAdapter(
              child: _buildSectionHeader('Events from Festio.lk'),
            ),

            // System Events Results
            _isLoading
                ? SliverToBoxAdapter(
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : _systemEvents.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No events found matching your preferences',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your filters or check back later',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildSystemEventResult(
                                _systemEvents[index]);
                          },
                          childCount: _systemEvents.length,
                        ),
                      ),

            // External-style Results Section
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildSectionHeader('Related Events & Information'),
                ],
              ),
            ),

            // Mock External Results (styled like Google)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildExternalStyleResult(index);
                },
                childCount: 5,
              ),
            ),

            // Footer
            SliverToBoxAdapter(
              child: _buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),

          // Google logo
          Image.asset(
            'assets/images/google_logo.png',
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'Festio',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A73E8),
                ),
              );
            },
          ),
          const SizedBox(width: 24),

          // Search box
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _buildSearchQuery(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildSearchStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        'About ${_systemEvents.length} results (0.${DateTime.now().millisecond} seconds)',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSystemEventResult(EventModel event) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModernEventDetailScreen(
              title: event.title,
              date:
                  '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
              location: event.location,
              imageUrl: event.imageUrl ?? '',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // URL breadcrumb
            Row(
              children: [
                if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      event.imageUrl!,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event, size: 16),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'festio.lk › events › ${event.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Title
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF1A0DAB),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              '${event.startDate.day}/${event.startDate.month}/${event.startDate.year} · ${event.location} · ${event.ticketPrice != null ? 'LKR ${event.ticketPrice}' : 'Free'}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              event.description.length > 200
                  ? '${event.description.substring(0, 200)}...'
                  : event.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Tags
            if (event.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: event.tags.take(3).map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExternalStyleResult(int index) {
    final mockResults = [
      {
        'title':
            'Best ${widget.userPreferences.favoriteEventTypes.isNotEmpty ? widget.userPreferences.favoriteEventTypes.first : 'Events'} in ${widget.userPreferences.primaryArea ?? 'Sri Lanka'}',
        'url': 'www.events.lk',
        'description':
            'Discover upcoming ${widget.userPreferences.favoriteEventTypes.isNotEmpty ? widget.userPreferences.favoriteEventTypes.first : 'events'} in your area. Find tickets, schedules, and more information about local entertainment.'
      },
      {
        'title':
            'Top Artists & Performers - ${widget.userPreferences.favoriteArtists.isNotEmpty ? widget.userPreferences.favoriteArtists.first : 'Popular Shows'}',
        'url': 'www.ticketmaster.lk',
        'description':
            'Buy tickets for ${widget.userPreferences.favoriteArtists.isNotEmpty ? widget.userPreferences.favoriteArtists.first : 'top performers'}. Secure your seats for upcoming concerts and shows with our easy booking system.'
      },
      {
        'title':
            'Event Calendar ${DateTime.now().year} - ${widget.userPreferences.primaryArea ?? 'Sri Lanka'}',
        'url': 'www.eventcalendar.lk',
        'description':
            'Complete calendar of events happening in ${widget.userPreferences.primaryArea ?? 'your area'}. Filter by category, date, and price to find your perfect event.'
      },
      {
        'title': 'Entertainment Guide - What\'s On This Weekend',
        'url': 'www.entertainment.lk',
        'description':
            'Your guide to weekend entertainment. Festivals, concerts, sports events, and cultural shows all in one place. Plan your perfect weekend out.'
      },
      {
        'title': 'Buy Event Tickets Online - Secure Booking',
        'url': 'www.tickets.lk',
        'description':
            'Safe and secure online ticket booking. Get instant confirmation for concerts, sports, and cultural events. Best prices guaranteed.'
      },
    ];

    final result = mockResults[index % mockResults.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // URL breadcrumb
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.language, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                result['url']!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Title
          Text(
            result['title']!,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF1A0DAB),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            result['description']!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sri Lanka',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('Help'),
              _buildFooterLink('Privacy'),
              _buildFooterLink('Terms'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
