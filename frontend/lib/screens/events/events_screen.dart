import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../widgets/event_calendar.dart';
import '../../core/models/event_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/event_provider.dart';
import '../../core/providers/recommendation_provider.dart';
import '../../core/services/ml_recommendation_service.dart';
import 'modern_event_detail_screen.dart';

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
  final List<String> _categories = ['All', 'Festival', 'Dance', 'Music', 'Theater', 'Art', 'Food', 'Poya Days'];
  late final TabController _tabController;
  late final List<_Event> _events;
  final MLRecommendationService _mlService = MLRecommendationService();
  late Future<List<RecommendationModel>> _mlFuture;
  String _currentUserId = 'guest_user';
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _dateKeys = {};

  List<_Event> _getBaseEvents() => [
    _Event(
      title: 'Kandy Esala Perahera',
      date: DateTime(2026, 8, 15),
      location: 'Kandy',
      category: 'Festival',
      image: 'assets\images\festival\Kandy Esala Perahera.jpg',
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
      image: 'assets/images/festival/Vesak festival.jpg',
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
      image: '../assets/images/aaa/food.png',
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

  // Poya days for 2026 with actual full moon dates
  List<_Event> _generatePoyaDays() {
    final poyaDays = [
      {'name': 'Duruthu Full Moon Poya', 'date': DateTime(2026, 1, 3), 'location': 'Kelaniya Temple', 'image': 'assets/images/poya/Poya 1.jpg'},
      {'name': 'Navam Full Poya', 'date': DateTime(2026, 2, 10), 'location': 'Gangaramaya Temple', 'image': 'assets/images/poya/Poya 2.jpg'},
      {'name': 'Medin Full Poya', 'date': DateTime(2026, 3, 12), 'location': 'Temples Nationwide', 'image': 'assets/images/poya/Poya 3.jpg'},
      {'name': 'Bak Full Poya', 'date': DateTime(2026, 4, 10), 'location': 'Temples Nationwide', 'image': 'assets/images/poya/Poya 4.jpg'},
      {'name': 'Vesak Full Poya', 'date': DateTime(2026, 5, 11), 'location': 'All Buddhist Temples', 'image': 'assets/images/poya/Poya 5.jpg'},
      {'name': 'Poson Full Poya', 'date': DateTime(2026, 6, 9), 'location': 'Mihintale', 'image': 'assets/images/poya/Poya 6.jpg'},
      {'name': 'Esala Full Poya', 'date': DateTime(2026, 7, 9), 'location': 'Temples Nationwide', 'image': 'assets/images/poya/Poya 7.jpg'},
      {'name': 'Nikini Full Poya', 'date': DateTime(2026, 8, 7), 'location': 'Temples Nationwide', 'image': 'assets/images/poya/Poya 8.jpg'},
      {'name': 'Binara Full Poya', 'date': DateTime(2026, 9, 6), 'location': 'Temples Nationwide', 'image': 'assets/images/poya/Poya 9.png'},
      {'name': 'Vap Full Poya', 'date': DateTime(2026, 10, 5), 'location': 'Temples Nationwide', 'image': 'assets/images/poya/Poya 10.png'},
      {'name': 'Il Full Poya', 'date': DateTime(2026, 11, 4), 'location': 'Temples Nationwide', 'image': 'assets/images/poya/Poya 11.jpg'},
      {'name': 'Unduvap Full Poya', 'date': DateTime(2026, 12, 3), 'location': 'Anuradhapura', 'image': 'assets/images/poya/Poya 12.jpg'},
    ];

    return poyaDays.map((poya) => _Event(
      title: poya['name'] as String,
      date: poya['date'] as DateTime,
      location: poya['location'] as String,
      category: 'Poya Days',
      image: poya['image'] as String,
      juice: 4.7,
      price: 'Free',
    )).toList();
  }

  @override
  void initState() {
    super.initState();
    _events = [..._getBaseEvents(), ..._generatePoyaDays()];
    _tabController = TabController(length: 2, vsync: this);
    _mlFuture = Future.value(<RecommendationModel>[]); // Hydrated once auth/user context is available
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    final resolvedUserId = auth.user?.id ?? 'guest_user';

    if (resolvedUserId != _currentUserId) {
      _currentUserId = resolvedUserId;
      setState(() {
        _mlFuture = _loadMlRecommendations(resolvedUserId);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<RecommendationModel>> _loadMlRecommendations(String userId) {
    return _mlService.getRecommendations(userId: userId, limit: 6, excludeViewed: true);
  }

  EventModel? _findEventForRec(String eventId, List<EventModel> events) {
    try {
      return events.firstWhere((event) => event.id == eventId);
    } catch (_) {
      // fall through
    }

    try {
      return events.firstWhere((event) => event.title.toLowerCase() == eventId.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  void _scrollToDate(DateTime date) {
    final dateKey = '${date.year}-${date.month}-${date.day}';
    final key = _dateKeys[dateKey];
    
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  void _scrollToToday() {
    final now = DateTime.now();
    _scrollToDate(now);
  }

  EventModel _convertToEventModel(_Event event) {
    return EventModel(
      id: event.title.hashCode.toString(),
      title: event.title,
      description: event.title,
      startDate: event.date,
      endDate: event.date,
      location: event.location,
      category: event.category,
      organizerId: 'system',
      organizerName: 'System',
      isApproved: true,
      isSpam: false,
      spamScore: 0.0,
      trustScore: 100,
      submittedAt: DateTime.now(),
    );
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
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Today button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              GestureDetector(
                onTap: _scrollToToday,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.today, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Today',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildMlRecommendationsCard(),

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
            child: EventCalendar(
              events: filteredEvents.map(_convertToEventModel).toList(),
              onDateSelected: (date) {
                _scrollToDate(date);
              },
            ),
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
    // Group events by date for section headers
    final Map<String, List<_Event>> eventsByDate = {};
    for (final event in events) {
      final dateKey = '${event.date.year}-${event.date.month}-${event.date.day}';
      eventsByDate.putIfAbsent(dateKey, () => []).add(event);
    }

    final dateKeys = eventsByDate.keys.toList()..sort();
    
    return Column(
      children: [
        for (int i = 0; i < dateKeys.length; i++) ..._buildDateSection(dateKeys[i], eventsByDate[dateKeys[i]]!, i),
      ],
    );
  }

  List<Widget> _buildDateSection(String dateKey, List<_Event> dateEvents, int sectionIndex) {
    final firstEvent = dateEvents.first;
    final date = firstEvent.date;
    
    // Create or reuse GlobalKey for this date
    _dateKeys.putIfAbsent(dateKey, () => GlobalKey());
    final key = _dateKeys[dateKey]!;
    
    final now = DateTime.now();
    final isToday = date.year == now.year && 
                   date.month == now.month && 
                   date.day == now.day;
    
    return [
      Container(
        key: key,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.only(bottom: 12, top: sectionIndex > 0 ? 24 : 0),
        decoration: BoxDecoration(
          gradient: isToday 
            ? const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              )
            : null,
          color: isToday ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isToday 
              ? Colors.transparent 
              : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: isToday ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(date),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isToday ? Colors.white : Colors.white70,
              ),
            ),
            if (isToday) ... [
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Today',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF23C864).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${dateEvents.length}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF23C864),
                ),
              ),
            ),
          ],
        ),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: dateEvents.length,
        itemBuilder: (context, index) {
          return _buildEventCard(dateEvents[index]);
        },
      ),
    ];
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
              child: event.image.startsWith('http')
                  ? Image.network(
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
                    )
                  : Image.asset(
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

  Widget _buildMlRecommendationsCard() {
    final eventProvider = context.watch<EventProvider>();
    final recommendationProvider = context.read<RecommendationProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF141A33), Color(0xFF1F2747)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Recommendations',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Personalized picks powered by the ML model',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _mlFuture = _loadMlRecommendations(_currentUserId);
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.white70),
                tooltip: 'Refresh recommendations',
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<RecommendationModel>>(
            future: _mlFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  children: const [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading recommendations...', style: TextStyle(color: Colors.white70)),
                  ],
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Could not load recommendations',
                  style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13),
                );
              }

              final recs = snapshot.data ?? [];
              if (recs.isEmpty) {
                return Text(
                  'No recommendations available. Try again later.',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                );
              }

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: recs.map((rec) {
                  final matchedEvent = _findEventForRec(rec.eventId, eventProvider.events);
                  if (matchedEvent != null) {
                    return _buildRecommendedEventCard(
                      context: context,
                      event: matchedEvent,
                      rec: rec,
                      recProvider: recommendationProvider,
                    );
                  }
                  return _buildRecommendationPlaceholder(rec);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedEventCard({
    required BuildContext context,
    required EventModel event,
    required RecommendationModel rec,
    required RecommendationProvider recProvider,
  }) {
    return _RecommendationCard(
      event: event,
      rec: rec,
      recProvider: recProvider,
      userId: _currentUserId,
    );
  }

  Widget _buildRecommendationPlaceholder(RecommendationModel rec) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rec.eventId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rec.reason,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score: ${rec.score.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatefulWidget {
  final EventModel event;
  final RecommendationModel rec;
  final RecommendationProvider recProvider;
  final String userId;

  const _RecommendationCard({
    required this.event,
    required this.rec,
    required this.recProvider,
    required this.userId,
  });

  @override
  State<_RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<_RecommendationCard> {
  bool? _feedbackGiven; // true = liked, false = disliked, null = no feedback
  bool _isProcessing = false;

  Future<void> _handleFeedback(bool liked) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _feedbackGiven = liked;
    });

    try {
      await widget.recProvider.recordInteraction(
        userId: widget.userId,
        eventId: widget.event.id,
        interactionType: liked ? 'like' : 'dislike',
      );
      
      await widget.recProvider.provideFeedback(
        userId: widget.userId,
        eventId: widget.event.id,
        liked: liked,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              liked ? '👍 Thanks for the feedback!' : '👎 We\'ll improve our recommendations',
              style: GoogleFonts.poppins(),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: liked ? const Color(0xFF23C864) : const Color(0xFFff6b6b),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _feedbackGiven = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Record click interaction
        await widget.recProvider.recordInteraction(
          userId: widget.userId,
          eventId: widget.event.id,
          interactionType: 'click',
        );

        // Track event view
        await widget.recProvider.trackEventView(widget.userId, widget.event);

        if (!mounted) return;
        
        // Navigate to rich detail screen
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ModernEventDetailScreen(
              title: widget.event.title,
              date: DateFormat('MMM d, yyyy').format(widget.event.startDate),
              location: widget.event.location,
              imageUrl: widget.event.imageUrl ?? 'https://via.placeholder.com/800x400',
              eventId: widget.event.id,
            ),
          ),
        );

        // Track view end when returning
        if (mounted) {
          await widget.recProvider.trackEventViewEnd(widget.userId, widget.event.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _feedbackGiven == true
              ? const Color(0xFF23C864).withOpacity(0.1)
              : _feedbackGiven == false
                  ? const Color(0xFFff6b6b).withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _feedbackGiven == true
                ? const Color(0xFF23C864).withOpacity(0.3)
                : _feedbackGiven == false
                    ? const Color(0xFFff6b6b).withOpacity(0.3)
                    : Colors.white.withOpacity(0.08),
            width: _feedbackGiven != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _feedbackGiven == true
                  ? const Color(0xFF23C864).withOpacity(0.2)
                  : _feedbackGiven == false
                      ? const Color(0xFFff6b6b).withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23C864).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.rec.score.toStringAsFixed(2),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF23C864),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isProcessing ? null : () => _handleFeedback(true),
                  icon: Icon(
                    _feedbackGiven == true ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    size: 18,
                    color: _feedbackGiven == true
                        ? const Color(0xFF23C864)
                        : Colors.white70,
                  ),
                  tooltip: 'Like this recommendation',
                ),
                IconButton(
                  onPressed: _isProcessing ? null : () => _handleFeedback(false),
                  icon: Icon(
                    _feedbackGiven == false ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
                    size: 18,
                    color: _feedbackGiven == false
                        ? const Color(0xFFff6b6b)
                        : Colors.white70,
                  ),
                  tooltip: 'Not relevant',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.event.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.white60),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.event.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.rec.reason,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('MMM d, yyyy').format(widget.event.startDate),
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

