import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../core/providers/promotion_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/organizer_chatbot_provider.dart';
import '../../core/services/analytics_api_service.dart';
import 'organizer_chatbot_widget.dart';
import 'widgets/ai_revenue_optimizer_card.dart';

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
  final String _selectedEventId = '';
  String _selectedLanguage = 'en';
  double _currentPrice = 2500;
  double _ticketsAvailable = 400;
  double _daysUntilEvent = 10;
  String _eventCategory = 'Music';
  String _selectedLocation = 'Colombo';
  double _organizerRating = 4.5;
  String _weatherForecast = 'Clear';
  double _pastAttendanceCount = 800;
  bool _isWeekend = true;
  final AnalyticsApiService _analyticsApiService = AnalyticsApiService();
  Map<String, dynamic>? _analyticsSummary;

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


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();
    Future.microtask(() async {
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
      backgroundColor: const Color(0xFF00D4FF),
      tooltip: 'AI Assistant',
      child: const Icon(Icons.chat_bubble, color: Colors.white),
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

  Widget _buildLiveDemandSignals() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E3F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(
            'Live Demand Signals',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          _buildDemandBadge('Demand Pulse: 1.2x - surging', Colors.blueAccent),
          const SizedBox(width: 8),
          _buildDemandBadge('Sell-through: 42%', Colors.purpleAccent),
          const SizedBox(width: 8),
          _buildDemandBadge('Marketing ROI: 4.2x', Colors.cyanAccent),
        ],
      ),
    );
  }

  Widget _buildDemandBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSeasonalTrendSection() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E3F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Seasonal Trend',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 12),
              _buildDemandBadge('surging', Colors.cyanAccent),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 1),
                      const FlSpot(2, 1.5),
                      const FlSpot(4, 1.2),
                      const FlSpot(6, 2.5),
                      const FlSpot(8, 2.0),
                      const FlSpot(10, 3.5),
                    ],
                    isCurved: true,
                    color: Colors.cyanAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.cyanAccent.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
              _buildLiveDemandSignals(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              AIRevenueOptimizerCard(
                eventId: _selectedEventId.isNotEmpty ? _selectedEventId : 'default',
                eventCategory: _eventCategory,
                daysBeforeEvent: _daysUntilEvent.toInt(),
                venueCapacity: _ticketsAvailable.toInt(),
                currentPrice: _currentPrice,
                location: _selectedLocation,
                organizerRating: _organizerRating,
                weatherForecast: _weatherForecast,
                pastAttendance: _pastAttendanceCount.toInt(),
                isWeekend: _isWeekend,
                apiBaseUrl: 'http://localhost:8001',
                onPriceUpdated: (newPrice) {
                  setState(() {
                    _currentPrice = newPrice;
                  });
                },
              ),
              const SizedBox(height: 32),
              _buildSeasonalTrendSection(),
              const SizedBox(height: 32),
              _buildRealTimeInputs(),
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

  String _formatAnalyticsCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }










  Widget _buildRealTimeInputs() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E3F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time Inputs',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          _buildSliderRow('Current ticket price', _currentPrice, 500, 10000, 'LKR', (val) {
            setState(() => _currentPrice = val);
          }),
          _buildSliderRow('Tickets sold', 180, 0, 2000, '', (val) {}),
          _buildSliderRow('Tickets available', _ticketsAvailable, 0, 2000, '', (val) {
            setState(() => _ticketsAvailable = val);
          }),
          _buildSliderRow('Days until event', _daysUntilEvent, 1, 60, '', (val) {
            setState(() => _daysUntilEvent = val);
          }),
          _buildDropdownRow('Event category', _eventCategory, ['Music', 'Tech', 'Cultural', 'Sports'], (val) {
            setState(() => _eventCategory = val);
          }),
          _buildDropdownRow('Location', _selectedLocation, ['Colombo', 'Galle', 'Jaffna', 'Kandy', 'Negombo'], (val) {
            setState(() => _selectedLocation = val);
          }),
          _buildSliderRow('Organizer Rating', _organizerRating, 1.0, 5.0, '★', (val) {
            setState(() => _organizerRating = val);
          }),
          _buildDropdownRow('Weather Forecast', _weatherForecast, ['Clear', 'Cloudy', 'Rainy'], (val) {
            setState(() => _weatherForecast = val);
          }),
          _buildSliderRow('Past Event Attendance', _pastAttendanceCount.clamp(0, _ticketsAvailable), 0, _ticketsAvailable.clamp(1, 2000), '', (val) {
            setState(() => _pastAttendanceCount = val);
          }),
          _buildToggleRow('Is Weekend', _isWeekend, (val) {
            setState(() => _isWeekend = val);
          }),
          _buildSliderRow('Competitor avg price', 2700, 500, 10000, 'LKR', (val) {}),
          _buildSliderRow('Marketing boost', 25, 0, 100, '%', (val) {}),
          _buildSliderRow('Sales trend (last 30 days)', 2.0, 0, 10, 'x', (val) {}),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, String unit, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '$unit ${value.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.cyanAccent,
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
              overlayColor: Colors.cyanAccent.withOpacity(0.2),
              trackHeight: 2,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> options, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              dropdownColor: const Color(0xFF0A0E27),
              underline: const SizedBox(),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              items: options.map((String opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  onChanged(val);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.cyanAccent,
            activeTrackColor: Colors.cyanAccent.withOpacity(0.3),
          ),
        ],
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
                        value: _formatAnalyticsCount(_analyticsSummary?['total_events'] ?? 0),
                        color: const Color(0xFF00D4FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.trending_up,
                        title: 'Engagement',
                        value: '${_getAnalyticsCount('revenue_optimization_generate') > 0 ? ((_getAnalyticsCount('revenue_optimization_result') / _getAnalyticsCount('revenue_optimization_generate')) * 100).toStringAsFixed(1) : '0'}%',
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
                        title: 'Active events',
                        value: _analyticsSummary?['total_events']?.toString() ?? '0',
                        color: const Color(0xFF764BA2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.language,
                        title: 'Languages',
                        value: '3', // This could be dynamic if we track language usage
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
                    const Icon(
                      Icons.language,
                      size: 32,
                      color: Color(0xFFFFD93D),
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
                  tabs: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Tab(text: '🇬🇧 English'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Tab(text: '🇱🇰 Sinhala'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
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
