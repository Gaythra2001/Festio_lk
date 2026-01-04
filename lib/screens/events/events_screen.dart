import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../widgets/event_calendar.dart';

class _Event {
  _Event({
    required this.title,
    required this.date,
    required this.location,
    required this.category,
    required this.image,
    required this.juice,
    required this.price,
  });

  final String title;
  final DateTime date;
  final String location;
  final String category;
  final String image;
  final double juice;
  final String price;
}

class _TabData {
  _TabData({required this.label, required this.events});

  final String label;
  final List<_Event> events;
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Festival', 'Dance', 'Music', 'Theater', 'Art', 'Food'];
  late final TabController _tabController;
  final List<_Event> _events = [
    _Event(
      title: 'Kandy Esala Perahera',
      date: DateTime(2026, 8, 15),
      location: 'Kandy',
      category: 'Festival',
      image: 'assets/images/kandy_perahera.jpg',
      juice: 4.8,
      price: 'Free',
    ),
    _Event(
      title: 'Traditional Dance Show',
      date: DateTime(2026, 1, 2),
      location: 'Colombo',
      category: 'Dance',
      image: 'assets/images/dance_show.jpg',
      juice: 4.2,
      price: 'LKR 1500',
    ),
    _Event(
      title: 'Baila Music Concert',
      date: DateTime(2026, 2, 5),
      location: 'Galle',
      category: 'Music',
      image: 'assets/images/music_concert.jpg',
      juice: 4.5,
      price: 'LKR 2000',
    ),
    _Event(
      title: 'Vesak Festival',
      date: DateTime(2026, 5, 12),
      location: 'Colombo',
      category: 'Festival',
      image: 'assets/images/vesak.jpg',
      juice: 4.9,
      price: 'Free',
    ),
    _Event(
      title: 'Classical Theater Performance',
      date: DateTime(2026, 3, 18),
      location: 'Kandy',
      category: 'Theater',
      image: 'assets/images/theater.jpg',
      juice: 4.0,
      price: 'LKR 1200',
    ),
    _Event(
      title: 'Art Exhibition',
      date: DateTime(2025, 4, 8),
      location: 'Colombo',
      category: 'Art',
      image: 'assets/images/art.jpg',
      juice: 3.8,
      price: 'LKR 800',
    ),
    _Event(
      title: 'Food Festival',
      date: DateTime(2026, 1, 25),
      location: 'Negombo',
      category: 'Food',
      image: 'assets/images/food.jpg',
      juice: 4.3,
      price: 'LKR 500',
    ),
    _Event(
      title: 'Drumming Workshop',
      date: DateTime(2026, 2, 14),
      location: 'Galle',
      category: 'Music',
      image: 'assets/images/drums.jpg',
      juice: 4.1,
      price: 'LKR 3000',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _selectedCategory == 'All'
        ? _events
        : _events.where((e) => e.category == _selectedCategory).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcomingEvents = filteredEvents
        .where((event) => !event.date.isBefore(today))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final pastEvents = filteredEvents
        .where((event) => event.date.isBefore(today))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Events',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover cultural events happening around you',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),

          const SizedBox(height: 24),

          // Calendar Widget
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F3A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: EventCalendar(events: const []),
          ),

          const SizedBox(height: 32),

          // Category Filter
          Text(
            'Filter by Category',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            )
                          : null,
                      color: isSelected ? null : const Color(0xFF1A1F3A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.1),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 32),

          _buildTabSwitcher(upcomingEvents, pastEvents),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher(List<_Event> upcomingEvents, List<_Event> pastEvents) {
    final tabs = [
      _TabData(label: 'Upcoming', events: upcomingEvents),
      _TabData(label: 'Past', events: pastEvents),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF111428), Color(0xFF1E2445)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: tabs
                .map((tab) => Tab(
                      text: '${tab.label} (${tab.events.length})',
                    ))
                .toList(),
            onTap: (_) {
              // TabController listener triggers setState; no-op here.
            },
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _buildEventsSection(
            _tabController.index == 0 ? 'Upcoming Events' : 'Past Events',
            _tabController.index == 0 ? upcomingEvents : pastEvents,
            key: ValueKey(_tabController.index),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsSection(String title, List<_Event> events, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          events.isEmpty ? '$title (0)' : title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        if (events.isEmpty)
          _buildEmptyState(title)
        else
          _buildEventsGrid(events),
      ],
    );
  }

  Widget _buildEventsGrid(List<_Event> events) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEmptyState(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151A32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: const Icon(Icons.event_available, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No $title yet',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We will list new events here as soon as they are scheduled.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(_Event event) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                event.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1A1F3A),
                  child: Icon(
                    Icons.event,
                    size: 48,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.category_outlined, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      event.category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFff9a9e), Color(0xFFfecfef)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFff9a9e).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.juice.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                  color: const Color(0xFF0F1428).withOpacity(0.65),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.white.withOpacity(0.75),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            DateFormat('EEE, MMM d, yyyy').format(event.date),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.white.withOpacity(0.75),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.location,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event.price,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              'View details',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
