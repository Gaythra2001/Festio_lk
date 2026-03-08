import 'dart:ui';

import 'package:festio_lk/core/services/EventR_service.dart';
import 'package:festio_lk/screens/Erecommendation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../events/modern_event_detail_screen.dart';
import '../submission/event_submission_screen.dart';
import '../recommendations/ai_recommendations_screen.dart';
import '../organizer/modern_organizer_dashboard.dart';
import '../ai/trust_and_budget_screens.dart';

import '../../widgets/event_calendar.dart';
import '../../widgets/juice_rating.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/providers/event_provider.dart';
import '../../core/models/event_model.dart';
import '../../widgets/app_footer.dart';

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
  bool _pageReady = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _eventsKey = GlobalKey();

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

      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.loadUpcomingEvents();

      if (mounted) {
        setState(() => _pageReady = true);
      }
    });
  }

  final List<Map<String, dynamic>> _allEvents = [
    {
      'title': 'Kandy Esala Perahera',
      'date': 'Aug 15, 2024',
      'location': 'Kandy, Sri Lanka',
      'category': 'Festival',
      'imageUrl':
          'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=1200',
      'juice': 4.8,
    },
    {
      'title': 'Traditional Dance Performance',
      'date': 'Aug 20, 2024',
      'location': 'Colombo, Sri Lanka',
      'category': 'Dance',
      'imageUrl':
          'https://images.unsplash.com/photo-1504609773096-104ff2c73ba4?w=1200',
      'juice': 4.2,
    },
    {
      'title': 'Cultural Music Festival',
      'date': 'Sep 5, 2024',
      'location': 'Galle, Sri Lanka',
      'category': 'Music',
      'imageUrl':
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=1200',
      'juice': 4.6,
    },
    {
      'title': 'Vesak Lantern Festival',
      'date': 'May 23, 2024',
      'location': 'Colombo, Sri Lanka',
      'category': 'Festival',
      'imageUrl':
          'https://images.unsplash.com/photo-1478145787956-f6f12c59624d?w=1200',
      'juice': 3.9,
    },
    {
      'title': 'Traditional Theater Show',
      'date': 'Sep 10, 2024',
      'location': 'Kandy, Sri Lanka',
      'category': 'Theater',
      'imageUrl':
          'https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?w=1200',
      'juice': 3.5,
    },
    {
      'title': 'Baila Night Concert',
      'date': 'Oct 2, 2024',
      'location': 'Negombo, Sri Lanka',
      'category': 'Music',
      'imageUrl':
          'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=1200',
      'juice': 4.4,
    },
  ];

  List<EventModel> _getMergedEventModels(List<EventModel> providerEvents) {
    final List<EventModel> localStaticEvents = _allEvents.map((e) {
      DateTime date;
      try {
        date = DateFormat('MMM dd, yyyy').parse(e['date']);
      } catch (_) {
        date = DateTime.now();
      }
      return EventModel(
        id: 'static_${e['title'].hashCode}',
        title: e['title'],
        description: e['title'],
        startDate: date,
        endDate: date,
        location: e['location'],
        category: e['category'],
        imageUrl: e['imageUrl'],
        organizerId: 'system',
        organizerName: 'System',
        isApproved: true,
        status: 'approved',
        submittedAt: DateTime.now(),
      );
    }).toList();

    // De-duplicate: If provider has an event with same title as static, prefer provider
    final staticTitles =
        localStaticEvents.map((e) => e.title.toLowerCase()).toSet();
    final uniqueProviderEvents = providerEvents
        .where((e) => !staticTitles.contains(e.title.toLowerCase()))
        .toList();

    return [...uniqueProviderEvents, ...localStaticEvents];
  }

  List<EventModel> _getFilteredEvents(List<EventModel> mergedEvents) {
    var events = mergedEvents;

    if (_selectedCategory != 'All') {
      events = events.where((e) => e.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      events = events.where((e) {
        final title = e.title.toLowerCase();
        final location = e.location.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || location.contains(query);
      }).toList();
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 760;
    final contentPadding = EdgeInsets.symmetric(
      horizontal: isDesktop ? 36 : 20,
      vertical: isDesktop ? 28 : 20,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          _buildDecorativeBackground(),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF6078EA).withOpacity(0.55),
                        const Color(0xFF7ED6DF).withOpacity(0.35),
                      ],
                    ),
                  ),
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Festio LK',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Find events that fit your day',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                actions: [
                  _buildAppBarAction(
                    icon: Icons.smart_toy_outlined,
                    tooltip: 'AI Picks',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AIRecommendationsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAppBarAction(
                    icon: Icons.campaign_outlined,
                    tooltip: 'Organizer Dashboard',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ModernOrganizerDashboard(),
                        ),
                      );
                    },
                  ),
                  _buildAppBarAction(
                    icon: Icons.verified_user_outlined,
                    tooltip: 'Trust Assessment',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrustAssessmentScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAppBarAction(
                    icon: Icons.account_balance_wallet_outlined,
                    tooltip: 'Budget Planning',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BudgetPlanningScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: contentPadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: _pageReady ? 1 : 0,
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 500),
                              offset: _pageReady
                                  ? Offset.zero
                                  : const Offset(0, 0.05),
                              curve: Curves.easeOutCubic,
                              child: _buildHeroSection(isDesktop),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader(
                            title: 'Quick Actions',
                            subtitle: 'Start planning in a single tap.',
                          ),
                          const SizedBox(height: 16),
                          _buildQuickActions(isDesktop),
                          const SizedBox(height: 32),
                          _buildSectionHeader(
                            title: 'Browse by Category',
                            subtitle: 'Pick a vibe and discover what is on.',
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
                          _buildSectionHeader(
                            title: 'Upcoming Events',
                            subtitle: _searchQuery.isNotEmpty
                                ? 'Results for "$_searchQuery"'
                                : _selectedCategory == 'All'
                                    ? 'Handpicked for you this season.'
                                    : 'Top $_selectedCategory events near you.',
                            action: TextButton.icon(
                              onPressed: () {
                                setState(() => _showCalendar = !_showCalendar);
                              },
                              icon: Icon(
                                _showCalendar
                                    ? Icons.calendar_month
                                    : Icons.calendar_today_outlined,
                                color: Colors.white,
                              ),
                              label: Text(
                                _showCalendar
                                    ? 'Hide Calendar'
                                    : 'Show Calendar',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_showCalendar)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Consumer<EventProvider>(
                                builder: (context, eventProvider, child) {
                                  final merged = _getMergedEventModels(
                                      eventProvider.upcomingEvents);
                                  final merged = _getMergedEventModels(eventProvider.events);
                                  return EventCalendar(
                                    events: _getFilteredEvents(merged),
                                    onDateSelected: (date) {},
                                    onEventsForDateChanged: (events) {},
                                  );
                                },
                              ),
                            ),
                          Container(
                            key: _eventsKey,
                            child: Consumer<EventProvider>(
                              builder: (context, eventProvider, child) {
                                final merged = _getMergedEventModels(
                                    eventProvider.upcomingEvents);
                                final filtered = _getFilteredEvents(merged);
                                return _buildEventSection(
                                    isDesktop, isTablet, filtered);
                              },
                            ),
                          ),
                          const SizedBox(height: 40),
                          const AppFooter(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showAIBot) _buildAIBotOverlay(),
        ],
      ),
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

  Widget _buildDecorativeBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E27),
                  Color(0xFF0F1638),
                ],
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -80,
            child: _buildGlowOrb(
              size: 240,
              colors: [
                const Color(0xFF667eea).withOpacity(0.45),
                const Color(0xFF764ba2).withOpacity(0.1),
              ],
            ),
          ),
          Positioned(
            bottom: -140,
            left: -60,
            child: _buildGlowOrb(
              size: 280,
              colors: [
                const Color(0xFF84fab0).withOpacity(0.4),
                const Color(0xFF8fd3f4).withOpacity(0.12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildHeroSection(bool isDesktop) {
    final headlineStyle = GoogleFonts.spaceGrotesk(
      fontSize: isDesktop ? 40 : 32,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: Colors.white,
    );

    final subheadStyle = GoogleFonts.poppins(
      fontSize: 15,
      height: 1.6,
      color: Colors.white70,
    );

    final searchField = TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText: 'search_events'.tr(),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _selectedCategory = 'All';
                  });
                },
                icon: const Icon(Icons.close, color: Colors.white70),
              )
            : null,
      ),
    );

    final heroCard = _buildHeroCard();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF141A3D).withOpacity(0.7),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroBadge('New cultural events every week'),
                      const SizedBox(height: 18),
                      Text('Plan your next cultural escape',
                          style: headlineStyle),
                      const SizedBox(height: 12),
                      Text(
                        'Discover authentic festivals, music nights, and heritage gatherings across Sri Lanka. Start with a quick search or let our AI guide you.',
                        style: subheadStyle,
                      ),
                      const SizedBox(height: 20),
                      searchField,
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              final context = _eventsKey.currentContext;
                              if (context != null) {
                                Scrollable.ensureVisible(
                                  context,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutCubic,
                                );
                              }
                            },
                            icon: const Icon(Icons.explore_outlined),
                            label: const Text('Explore Events'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _showAIBot = true);
                            },
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('AI Concierge'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: heroCard),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroBadge('New cultural events every week'),
                const SizedBox(height: 16),
                Text('Plan your next cultural escape', style: headlineStyle),
                const SizedBox(height: 12),
                Text(
                  'Discover authentic festivals, music nights, and heritage gatherings across Sri Lanka.',
                  style: subheadStyle,
                ),
                const SizedBox(height: 18),
                searchField,
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final context = _eventsKey.currentContext;
                          if (context != null) {
                            Scrollable.ensureVisible(
                              context,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        icon: const Icon(Icons.explore_outlined),
                        label: const Text('Explore Events'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _showAIBot = true);
                        },
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('AI Concierge'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                heroCard,
              ],
            ),
    );
  }

  Widget _buildHeroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: [Color(0xFF8fd3f4), Color(0xFF84fab0)],
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0A0E27),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?w=1400',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF1A1F3A),
                    child: const Icon(Icons.event, color: Colors.white38),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esala Perahera Preview',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reserve your spot for the grand procession in Kandy.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ModernEventDetailScreen(
                            title: 'Kandy Esala Perahera',
                            date: 'Aug 15, 2024',
                            location: 'Kandy, Sri Lanka',
                            imageUrl:
                                'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=1200',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('View Spotlight'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDesktop) {
    final items = [
      _QuickAction(
        title: 'AI Picks',
        subtitle: 'Get a curated plan.',
        icon: Icons.auto_awesome,
        gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
        onTap: () => setState(() => _showAIBot = true),
      ),
      _QuickAction(
        title: 'Plan Budget',
        subtitle: 'Estimate costs fast.',
        icon: Icons.account_balance_wallet_outlined,
        gradient: const [Color(0xFF84fab0), Color(0xFF8fd3f4)],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BudgetPlanningScreen(),
            ),
          );
        },
      ),
      _QuickAction(
        title: 'Organizer Tools',
        subtitle: 'Manage your events.',
        icon: Icons.campaign_outlined,
        gradient: const [Color(0xFFfa709a), Color(0xFFfee140)],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ModernOrganizerDashboard(),
            ),
          );
        },
      ),
      _QuickAction(
        title: 'Trust Score',
        subtitle: 'Check organizer status.',
        icon: Icons.verified_user_outlined,
        gradient: const [Color(0xFFa8edea), Color(0xFFfed6e3)],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TrustAssessmentScreen(),
            ),
          );
        },
      ),
      _QuickAction(
        title: 'My Picks', // <-- shorter title
        subtitle: 'Personalized events', // optional shorter subtitle
        icon: Icons.app_registration,
        gradient: const [Color(0xFF43cea2), Color(0xFF185a9d)],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const HomeScreen(), // or your personal recommendation page
            ),
          );
        },
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items
          .map(
            (item) => SizedBox(
              width: isDesktop ? 260 : 300,
              child: _buildQuickActionCard(item),
            ),
          )
          .toList(),
    );
  }

  Widget _buildQuickActionCard(_QuickAction item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF171D3D),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: item.gradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _buildEventSection(
      bool isDesktop, bool isTablet, List<EventModel> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.event_busy,
                size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
        childAspectRatio: isDesktop ? 0.85 : 1.1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(
          title: event.title,
          date: DateFormat('MMM dd, yyyy').format(event.startDate),
          location: event.location,
          imageUrl: event.imageUrl ??
              'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=1200',
          juice: 4.5, // Default rating for now
        );
      },
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
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.08),
              width: 1.2,
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
              fontSize: 13,
              letterSpacing: 0.2,
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
      onTap: () async {
         await FirebaseService().incrementEventClick(title);
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
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.25),
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                            fontSize: 13,
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
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    JuiceRatingCompact(rating: juice),
                  ],
                ),
              ),
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
              onTap: () {},
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
                      'AI Event Concierge',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tell us what you love and we will match festivals, concerts, and cultural nights for you.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
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
                            content:
                                Text('AI found 6 events near you in Colombo!'),
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
                                Text('AI recommends Music events for you!'),
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
                            content: Text('Showing trending Festival events!'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
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
    _scrollController.dispose();
    super.dispose();
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}
