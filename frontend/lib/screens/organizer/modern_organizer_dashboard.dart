import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';

import '../../core/providers/promotion_provider.dart';
import '../../core/providers/event_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/providers/organizer_chatbot_provider.dart';
import '../../core/services/ai/revenue_optimization_service.dart';
import '../../core/services/analytics_api_service.dart';
import 'organizer_chatbot_widget.dart';

/// Modern Organizer Dashboard - Component 2: MA-EPOM (Multilingual Event Promotion Optimization)
class ModernOrganizerDashboard extends StatefulWidget {
  final String? initialEventId;
  const ModernOrganizerDashboard({super.key, this.initialEventId});

  @override
  State<ModernOrganizerDashboard> createState() =>
      _ModernOrganizerDashboardState();
}

class _ModernOrganizerDashboardState extends State<ModernOrganizerDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  int _selectedTab = 0;
  String _selectedEventId = '';
  String _selectedLanguage = 'en';
  bool _isLoading = false;
  bool _isRevenueLoading = false;
  String? _revenueError;
  String? _revenueNotice;
  Map<String, dynamic>? _revenueOptimization;
  Map<String, dynamic>? _analyticsSummary;

  final RevenueOptimizationService _revenueOptimizationService =
      RevenueOptimizationService();
  final AnalyticsApiService _analyticsApiService = AnalyticsApiService();

  final Map<String, Map<String, dynamic>> _promotionTiers = {
    'starter': {
      'name': 'Starter',
      'price': '₨1,500',
      'duration': '3 days',
      'reach': '~5K',
      'features': [
        'Basic visibility',
        'Email notifications',
        '3-day promotion'
      ],
      'color': const Color(0xFF00D4FF),
      'icon': Icons.flash_on,
    },
    'professional': {
      'name': 'Professional',
      'price': '₨3,500',
      'duration': '7 days',
      'reach': '~15K',
      'features': [
        'Enhanced visibility',
        'Multi-channel notifications',
        'Featured badge',
        '7-day promotion'
      ],
      'color': const Color(0xFF00D9FF),
      'icon': Icons.rocket_launch,
      'popular': true,
    },
    'enterprise': {
      'name': 'Enterprise',
      'price': '₨7,000',
      'duration': '14 days',
      'reach': '~50K+',
      'features': [
        'Maximum visibility',
        'All channels + SMS',
        'Homepage featured',
        'Priority support',
        '14-day campaign'
      ],
      'color': const Color(0xFF00E5FF),
      'icon': Icons.star,
    },
  };

  final Map<String, String> _languageNames = {
    'en': 'English',
    'si': 'Sinhala',
    'ta': 'Tamil'
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();
    Future.microtask(() {
      context.read<PromotionProvider>().load();
      _trackDashboardView();
      _loadAnalyticsSummary();
    });
  }

  Future<void> _trackDashboardView() async {
    final authProvider = context.read<AuthProvider>();
    final organizerId = authProvider.user?.id ?? 'unknown';
    try {
      await _analyticsApiService.trackEvent(
        organizerId: organizerId,
        eventId: _selectedEventId.isNotEmpty ? _selectedEventId : null,
        eventType: 'organizer_dashboard_view',
        metadata: {
          'screen': 'modern_organizer_dashboard',
        },
      );
    } catch (_) {}
  }

  Future<void> _loadAnalyticsSummary() async {
    final authProvider = context.read<AuthProvider>();
    final organizerId = authProvider.user?.id ?? 'unknown';
    try {
      final summary = await _analyticsApiService.getSummary(
        organizerId: organizerId,
        eventId: _selectedEventId.isNotEmpty ? _selectedEventId : null,
        windowDays: 30,
      );
      if (mounted) {
        setState(() {
          _analyticsSummary = summary;
        });
      }
    } catch (_) {}
  }

  int _getAnalyticsCount(String eventType) {
    if (_analyticsSummary == null) return 0;
    final counts = _analyticsSummary!['event_type_counts'];
    if (counts is Map) {
      final value = counts[eventType];
      if (value is int) return value;
      if (value is num) return value.toInt();
    }
    return 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildChatbotFAB(context),
    );
  }

  Widget _buildChatbotFAB(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final organizerId = authProvider.user?.id ?? 'unknown';

    return FloatingActionButton(
      onPressed: () => _openChatbot(context, organizerId),
      backgroundColor: Color(0xFF00D4FF),
      child: Icon(Icons.chat_bubble, color: Colors.white),
      tooltip: 'AI Assistant',
    );
  }

  void _openChatbot(BuildContext context, String organizerId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => OrganizerChatbotProvider(
          organizerId: organizerId,
          eventId: _selectedEventId.isNotEmpty ? _selectedEventId : 'all',
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => OrganizerChatbotWidget(
            organizerId: organizerId,
            eventId: _selectedEventId.isNotEmpty ? _selectedEventId : 'all',
            onClose: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00D4FF).withOpacity(0.1),
                  const Color(0xFF764BA2).withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        '📢 Organizer Dashboard',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D4FF), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Center(
                          child: Text(
                            'Organizer Mode',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 100,
            left: 16,
            right: 16,
            bottom: 32,
          ),
          child: Column(
            children: [
              _buildStatsSection(),
              const SizedBox(height: 32),
              _buildRevenueOptimizationSection(),
              const SizedBox(height: 32),
              _buildPromotionTiersSection(),
              const SizedBox(height: 32),
              _buildLanguagePromotionSection(),
              const SizedBox(height: 32),
              _buildCampaignAnalyticsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadRevenueOptimization() async {
    if (_isRevenueLoading) return;
    setState(() {
      _isRevenueLoading = true;
      _revenueError = null;
      _revenueNotice = null;
    });

    final authProvider = context.read<AuthProvider>();
    final organizerId = authProvider.user?.id ?? 'unknown';
    final eventId = _selectedEventId.isNotEmpty ? _selectedEventId : 'default';

    try {
      await _analyticsApiService.trackEvent(
        organizerId: organizerId,
        eventId: eventId,
        eventType: 'revenue_optimization_generate',
        metadata: {
          'source': 'dashboard_button',
        },
      );
    } catch (_) {}

    try {
      final result = await _revenueOptimizationService.optimizeRevenue(
        organizerId: organizerId,
        eventId: eventId,
        currentPrice: 2500,
        ticketsSold: 180,
        ticketsAvailable: 400,
        daysUntilEvent: 10,
        competitorAvgPrice: 2700,
        marketingBoost: 0.35,
        demandGrowthRate: 0.2,
      );

      setState(() {
        _revenueOptimization = result;
      });
      _loadAnalyticsSummary();
    } catch (e) {
      setState(() {
        _revenueNotice = 'Preview data shown (backend unreachable).';
        _revenueOptimization = _buildRevenuePreview();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRevenueLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _buildRevenuePreview() {
    return {
      'recommended_price': 3200.0,
      'expected_revenue_optimized': 1275000.0,
      'price_change_pct': 6.67,
      'demand_index': 1.18,
      'reasons': [
        'Strong demand momentum detected',
        'Marketing lift is increasing conversion',
        'Event is approaching; adjust price for conversion'
      ]
    };
  }

  Widget _buildRevenueOptimizationSection() {
    final data = _revenueOptimization;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00D4FF).withOpacity(0.12),
            const Color(0xFF764BA2).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Revenue Optimization Engine',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Dynamic pricing and revenue lift predictions',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isRevenueLoading ? null : _loadRevenueOptimization,
                      icon: _isRevenueLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.auto_graph, color: Colors.white, size: 18),
                      label: Text(
                        _isRevenueLoading ? 'Optimizing...' : 'Generate',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4FF),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_revenueError != null)
                  Text(
                    _revenueError!,
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  )
                else if (_revenueNotice != null)
                  Text(
                    _revenueNotice!,
                    style: GoogleFonts.poppins(
                      color: Colors.amberAccent,
                      fontSize: 12,
                    ),
                  )
                else if (data == null)
                  Text(
                    'Tap Generate to get AI-driven pricing recommendations and revenue projections.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  )
                else
                  Column(
                    children: [
                      if (_analyticsSummary != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.analytics,
                                    size: 16,
                                    color: const Color(0xFF00D4FF)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Last 30 days: ${_analyticsSummary!['total_events']} tracked actions',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.price_change,
                              title: 'Recommended Price',
                              value: '₨${data['recommended_price']}',
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.trending_up,
                              title: 'Revenue Lift',
                              value: '₨${data['expected_revenue_optimized']}',
                              color: const Color(0xFF764BA2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.percent,
                              title: 'Price Change',
                              value: '${data['price_change_pct']}%',
                              color: const Color(0xFF00D4FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.insights,
                              title: 'Demand Index',
                              value: '${data['demand_index']}',
                              color: const Color(0xFF00D9FF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (data['reasons'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Why this recommendation?',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...List<Widget>.from(
                              (data['reasons'] as List<dynamic>).map(
                                (reason) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          size: 14, color: const Color(0xFF00D4FF)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          reason.toString(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00D4FF).withOpacity(0.15),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campaign Overview',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.visibility,
                        title: 'Total Reach',
                        value: '124.5K',
                        color: const Color(0xFF00D4FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.trending_up,
                        title: 'Engagement',
                        value: '8.2%',
                        color: const Color(0xFF00E5FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_month,
                        title: 'Active',
                        value: '12',
                        color: const Color(0xFF764BA2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.language,
                        title: 'Languages',
                        value: '3',
                        color: const Color(0xFF667eea),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionTiersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promotion Tiers',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Choose the perfect tier for your event promotion',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _promotionTiers.entries.map((entry) {
              final tier = entry.value;
              final isPopular = tier['popular'] ?? false;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildPromotionTierCard(
                  tier: tier,
                  isPopular: isPopular,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionTierCard({
    required Map<String, dynamic> tier,
    required bool isPopular,
  }) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tier['color'].withOpacity(0.15),
            tier['color'].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tier['color'].withOpacity(isPopular ? 0.6 : 0.3),
          width: isPopular ? 2 : 1.5,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: tier['color'].withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier['name'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tier['reach'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: tier['color'],
                          ),
                        ),
                      ],
                    ),
                    if (isPopular)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              tier['color'],
                              tier['color'].withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          'Popular',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  tier['price'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: tier['color'],
                  ),
                ),
                Text(
                  'for ${tier['duration']}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (tier['features'] as List<String>)
                      .map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: tier['color'],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [tier['color'], tier['color'].withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showTierSelectionDialog(tier['name']);
                        },
                        child: Center(
                          child: Text(
                            'Select Tier',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguagePromotionSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B9D).withOpacity(0.15),
            const Color(0xFFFFD93D).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Multilingual Promotion',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'MA-EPOM: Optimize across 3 languages',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.language,
                      size: 32,
                      color: const Color(0xFFFFD93D),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D4FF), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  onTap: (index) {
                    setState(() {
                      _selectedLanguage = ['en', 'si', 'ta'][index];
                    });
                  },
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Tab(text: '🇬🇧 English'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Tab(text: '🇱🇰 Sinhala'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Tab(text: '🇮🇳 Tamil'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLanguageEditor(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Campaign Title',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter promotion title for $_selectedLanguage',
            hintStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Colors.white38,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF00D4FF),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.white,
          ),
          maxLines: 1,
        ),
        const SizedBox(height: 16),
        Text(
          'Campaign Message',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter promotion message...',
            hintStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Colors.white38,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF00D4FF),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.white,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _showSuccessSnackbar('Campaign updated for $_selectedLanguage');
                },
                child: Center(
                  child: Text(
                    'Update Campaign',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignAnalyticsSection() {
    final impressions = _analyticsSummary != null
      ? _getAnalyticsCount('organizer_dashboard_view')
      : null;
    final clicks = _analyticsSummary != null
      ? _getAnalyticsCount('revenue_optimization_generate')
      : null;
    final conversions = _analyticsSummary != null
      ? _getAnalyticsCount('promotion_tier_selected')
      : null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea).withOpacity(0.15),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campaign Analytics',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildAnalyticsRow(
                  'Impressions',
                  impressions != null ? impressions.toString() : '24,583',
                  Icons.visibility,
                  const Color(0xFF00D4FF),
                  '↑ 12.5%',
                ),
                const SizedBox(height: 16),
                _buildAnalyticsRow(
                  'Clicks',
                  clicks != null ? clicks.toString() : '2,134',
                  Icons.touch_app,
                  const Color(0xFF764BA2),
                  '↑ 8.2%',
                ),
                const SizedBox(height: 16),
                _buildAnalyticsRow(
                  'Conversions',
                  conversions != null ? conversions.toString() : '856',
                  Icons.check_circle,
                  const Color(0xFF00E5FF),
                  '↑ 15.3%',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667eea).withOpacity(0.3),
                          const Color(0xFF764BA2).withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF667eea).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _loadAnalyticsSummary();
                          _showSuccessSnackbar('Refreshing analytics...');
                        },
                        child: Center(
                          child: Text(
                            'View Detailed Report',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(
    String label,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: Text(
            change,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.greenAccent,
            ),
          ),
        ),
      ],
    );
  }

  void _showTierSelectionDialog(String tierName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0E27).withOpacity(0.95),
                const Color(0xFF1A1E3F).withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Confirm Selection',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You selected the $tierName tier for your event promotion',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00D4FF),
                                    Color(0xFF764BA2)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    try {
                                      final authProvider =
                                          context.read<AuthProvider>();
                                      final organizerId =
                                          authProvider.user?.id ?? 'unknown';
                                      await _analyticsApiService.trackEvent(
                                        organizerId: organizerId,
                                        eventId: _selectedEventId.isNotEmpty
                                            ? _selectedEventId
                                            : null,
                                        eventType: 'promotion_tier_selected',
                                        metadata: {
                                          'tier': tierName,
                                        },
                                      );
                                      _loadAnalyticsSummary();
                                    } catch (_) {}
                                    _showSuccessSnackbar(
                                        '$tierName tier selected successfully!');
                                  },
                                  child: Center(
                                    child: Text(
                                      'Confirm',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00D4FF).withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
