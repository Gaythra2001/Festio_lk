import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:ui';

import '../../core/providers/promotion_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/organizer_chatbot_provider.dart';
import '../../core/services/ai/revenue_optimization_service.dart';
import '../../core/services/analytics_api_service.dart';
import '../../core/routes/app_routes.dart';
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
  String _selectedEventId = '';
  String _selectedLanguage = 'en';
  bool _isRevenueLoading = false;
  String? _revenueError;
  String? _revenueNotice;
  Map<String, dynamic>? _revenueOptimization;
  Map<String, dynamic>? _analyticsSummary;
  double _currentPrice = 2500;
  double _ticketsSold = 180;
  double _ticketsAvailable = 400;
  double _daysUntilEvent = 10;
  double _competitorAvgPrice = 2700;
  double _marketingBoost = 0.35;
  double _demandGrowthRate = 0.2;
  String _eventCategory = 'Festival';
  String _abExperimentId = 'rev_opt_v1';
  String _abVariant = 'A';
  bool _abReady = false;

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
      await _initExperiment();
      _trackDashboardView();
      _loadAnalyticsSummary();
    });
  }

  Future<void> _initExperiment() async {
    if (_abReady) return;
    final authProvider = context.read<AuthProvider>();
    final organizerId = authProvider.user?.id ?? 'unknown';
    final prefs = await SharedPreferences.getInstance();
    final key = 'ab_${_abExperimentId}_$organizerId';
    final stored = prefs.getString(key);
    if (stored == null || (stored != 'A' && stored != 'B')) {
      final variant = _pickVariant();
      await prefs.setString(key, variant);
      _abVariant = variant;
    } else {
      _abVariant = stored;
    }
    if (mounted) {
      setState(() {
        _abReady = true;
      });
    }
  }

  String _pickVariant() {
    return Random().nextBool() ? 'A' : 'B';
  }

  Future<void> _ensureExperimentReady() async {
    if (!_abReady) {
      await _initExperiment();
    }
  }

  Map<String, dynamic> _experimentMetadata() {
    return {
      'experiment_id': _abExperimentId,
      'variant': _abVariant,
      'panel': 'revenue_optimization',
    };
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
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.adminEventApprovals);
          },
          icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
          tooltip: 'Admin Panel',
        ),
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

    await _ensureExperimentReady();

    try {
      await _analyticsApiService.trackEvent(
        organizerId: organizerId,
        eventId: eventId,
        eventType: 'revenue_optimization_generate',
        metadata: {
          'source': 'dashboard_button',
          ..._experimentMetadata(),
          'event_category': _eventCategory,
          'tickets_sold': _ticketsSold.toInt(),
          'tickets_available': _ticketsAvailable.toInt(),
          'days_until_event': _daysUntilEvent.toInt(),
          'competitor_avg_price': _competitorAvgPrice,
          'marketing_boost': _marketingBoost,
          'sales_trend': _demandGrowthRate,
        },
      );
    } catch (_) {}

    try {
      final result = await _revenueOptimizationService.optimizeRevenue(
        organizerId: organizerId,
        eventId: eventId,
        eventCategory: _eventCategory,
        currentPrice: _currentPrice,
        ticketsSold: _ticketsSold.toInt(),
        ticketsAvailable: _ticketsAvailable.toInt(),
        venueCapacity: _ticketsAvailable.toInt(),
        daysUntilEvent: _daysUntilEvent.toInt(),
        salesTrend: _demandGrowthRate,
        competitorAvgPrice: _competitorAvgPrice,
        marketingBoost: _marketingBoost,
        demandGrowthRate: _demandGrowthRate,
      );

      setState(() {
        _revenueOptimization = result;
      });
      await _trackRevenueResult(result, isFallback: false);
      _loadAnalyticsSummary();
    } catch (e) {
      setState(() {
        _revenueNotice = 'Preview data shown (backend unreachable).';
        _revenueOptimization = _buildRevenuePreview();
      });
      await _trackRevenueResult(_revenueOptimization ?? {}, isFallback: true);
    } finally {
      if (mounted) {
        setState(() {
          _isRevenueLoading = false;
        });
      }
    }
  }

  Future<void> _trackRevenueResult(
    Map<String, dynamic> data, {
    required bool isFallback,
  }) async {
    final authProvider = context.read<AuthProvider>();
    final organizerId = authProvider.user?.id ?? 'unknown';
    final eventId = _selectedEventId.isNotEmpty ? _selectedEventId : 'default';
    final modelUsed = data['model_used'] ?? (isFallback ? 'preview' : null);
    try {
      await _analyticsApiService.trackEvent(
        organizerId: organizerId,
        eventId: eventId,
        eventType: 'revenue_optimization_result',
        metadata: {
          ..._experimentMetadata(),
          'model_used': modelUsed,
          'is_fallback': isFallback,
          'recommended_price': data['recommended_price'],
          'revenue_uplift': data['revenue_uplift'],
          'price_change_pct': data['price_change_pct'],
        },
      );
    } catch (_) {}
  }

  Map<String, dynamic> _buildRevenuePreview() {
    final sellThrough = _ticketsAvailable > 0
        ? (_ticketsSold / _ticketsAvailable).clamp(0.0, 1.0)
        : 0.0;
    final demandIndex = (1 + _demandGrowthRate + (sellThrough - 0.5) * 0.6)
        .clamp(0.6, 1.6);
    final recommended = _currentPrice * demandIndex;
    final optimalLow = recommended * 0.92;
    final optimalHigh = recommended * 1.08;
    final revenueCurrent = (_currentPrice * _ticketsAvailable).toStringAsFixed(0);
    final revenueOptimized = (recommended * _ticketsAvailable).toStringAsFixed(0);
    final uplift = (double.parse(revenueOptimized) - double.parse(revenueCurrent)).toStringAsFixed(0);
    return {
      'event_category': _eventCategory,
      'model_used': 'preview',
      'recommended_price': recommended.toStringAsFixed(0),
      'optimal_price_low': optimalLow.toStringAsFixed(0),
      'optimal_price_high': optimalHigh.toStringAsFixed(0),
      'expected_revenue_current': revenueCurrent,
      'expected_revenue_optimized': revenueOptimized,
      'revenue_uplift': uplift,
      'price_change_pct':
          (((recommended - _currentPrice) / _currentPrice) * 100)
              .toStringAsFixed(2),
      'demand_index': demandIndex.toStringAsFixed(2),
      'reasons': [
        'Strong demand momentum detected',
        'Marketing lift is increasing conversion',
        'Event is approaching; adjust price for conversion'
      ]
    };
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '-';
    if (value is num) return value.toStringAsFixed(0);
    return value.toString();
  }

  String _formatPercent(dynamic value) {
    if (value == null) return '-';
    if (value is num) return value.toStringAsFixed(2);
    return value.toString();
  }

  double _sellThroughRate() {
    if (_ticketsAvailable <= 0) return 0;
    return (_ticketsSold / _ticketsAvailable).clamp(0.0, 1.0);
  }

  double _demandPulse() {
    final sellThrough = _sellThroughRate();
    return (1 + _demandGrowthRate + (sellThrough - 0.5) * 0.6 + _marketingBoost * 0.4)
        .clamp(0.6, 1.8);
  }

  Color _demandColor(double value) {
    if (value >= 1.2) return const Color(0xFF00E5FF);
    if (value >= 1.0) return const Color(0xFF00D4FF);
    if (value >= 0.85) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _demandLabel(double value) {
    if (value >= 1.2) return 'Surging';
    if (value >= 1.0) return 'Healthy';
    if (value >= 0.85) return 'Soft';
    return 'Weak';
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
                const SizedBox(height: 16),
                _buildRevenueSignals(),
                const SizedBox(height: 12),
                _buildMiniTrendChart(),
                const SizedBox(height: 16),
                _buildRevenueInputs(),
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
                      if (data['model_used'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(Icons.psychology,
                                  size: 16,
                                  color: const Color(0xFF00D4FF)),
                              const SizedBox(width: 8),
                              Text(
                                'Model: ${data['model_used']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.price_change,
                              title: 'Recommended Price',
                              value: '₨${_formatCurrency(data['recommended_price'])}',
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.tune,
                              title: 'Optimal Range',
                              value:
                                  '₨${_formatCurrency(data['optimal_price_low'])}-₨${_formatCurrency(data['optimal_price_high'])}',
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
                              icon: Icons.trending_up,
                              title: 'Revenue Uplift',
                              value: '₨${_formatCurrency(data['revenue_uplift'])}',
                              color: const Color(0xFF00D4FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.insights,
                              title: 'Demand Index',
                              value: _formatPercent(data['demand_index']),
                              color: const Color(0xFF00D9FF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (data['expected_revenue_optimized'] != null)
                        Container(
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
                              Icon(Icons.show_chart,
                                  size: 16,
                                  color: const Color(0xFF00D4FF)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Expected revenue: ₨${_formatCurrency(data['expected_revenue_optimized'])}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                              if (data['suggested_price_adjustment'] != null)
                                Text(
                                  data['suggested_price_adjustment'].toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
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

  Widget _buildRevenueSignals() {
    final sellThrough = _sellThroughRate();
    final pulse = _demandPulse();
    final demandColor = _demandColor(pulse);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: demandColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.bolt, size: 18, color: demandColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Demand Signals',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildSignalChip(
                      label: 'Demand Pulse',
                      value: '${pulse.toStringAsFixed(2)} · ${_demandLabel(pulse)}',
                      color: demandColor,
                    ),
                    _buildSignalChip(
                      label: 'Sell-through',
                      value: '${(sellThrough * 100).toStringAsFixed(0)}%',
                      color: const Color(0xFF00D4FF),
                    ),
                    _buildSignalChip(
                      label: 'Marketing Lift',
                      value: '+${(_marketingBoost * 100).toStringAsFixed(0)}%',
                      color: const Color(0xFF764BA2),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSignalChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
          children: [
            TextSpan(
              text: value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueInputs() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time inputs',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          _buildSliderRow(
            label: 'Current ticket price',
            valueLabel: '₨${_currentPrice.toStringAsFixed(0)}',
            value: _currentPrice,
            min: 500,
            max: 8000,
            divisions: 75,
            onChanged: (v) => setState(() => _currentPrice = v),
          ),
          _buildSliderRow(
            label: 'Tickets sold',
            valueLabel: _ticketsSold.toStringAsFixed(0),
            value: _ticketsSold,
            min: 0,
            max: _ticketsAvailable < 50 ? 50 : _ticketsAvailable,
            divisions: 50,
            onChanged: (v) => setState(() => _ticketsSold = v),
          ),
          _buildSliderRow(
            label: 'Tickets available',
            valueLabel: _ticketsAvailable.toStringAsFixed(0),
            value: _ticketsAvailable,
            min: 50,
            max: 2000,
            divisions: 39,
            onChanged: (v) => setState(() {
              _ticketsAvailable = v;
              if (_ticketsSold > v) _ticketsSold = v;
            }),
          ),
          _buildSliderRow(
            label: 'Days until event',
            valueLabel: _daysUntilEvent.toStringAsFixed(0),
            value: _daysUntilEvent,
            min: 1,
            max: 60,
            divisions: 59,
            onChanged: (v) => setState(() => _daysUntilEvent = v),
          ),
          _buildCategoryRow(),
          _buildSliderRow(
            label: 'Competitor avg price',
            valueLabel: '₨${_competitorAvgPrice.toStringAsFixed(0)}',
            value: _competitorAvgPrice,
            min: 500,
            max: 8000,
            divisions: 75,
            onChanged: (v) => setState(() => _competitorAvgPrice = v),
          ),
          _buildSliderRow(
            label: 'Marketing boost',
            valueLabel: '+${(_marketingBoost * 100).toStringAsFixed(0)}%',
            value: _marketingBoost,
            min: 0,
            max: 1,
            divisions: 20,
            onChanged: (v) => setState(() => _marketingBoost = v),
          ),
          _buildSliderRow(
            label: 'Sales trend (last 30 days)',
            valueLabel: '+${(_demandGrowthRate * 100).toStringAsFixed(0)}%',
            value: _demandGrowthRate,
            min: -0.2,
            max: 0.6,
            divisions: 40,
            onChanged: (v) => setState(() => _demandGrowthRate = v),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    final categories = [
      'Festival',
      'Music',
      'Dance',
      'Theater',
      'Art',
      'Food',
      'Religious',
      'Other',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Event category',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _eventCategory,
                dropdownColor: const Color(0xFF1A1F3A),
                icon: const Icon(Icons.expand_more, color: Colors.white70),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                ),
                items: categories
                    .map((category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _eventCategory = value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTrendChart() {
    final pulse = _demandPulse();
    final trend = List<double>.generate(10, (index) {
      final drift = (index - 5) * 0.03;
      final marketingShift = (_marketingBoost - 0.3) * 0.25;
      final value = (pulse + drift + marketingShift).clamp(0.6, 1.8);
      return value.toDouble();
    });

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Demand trend (next 10 days)',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _demandColor(pulse).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _demandLabel(pulse),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _demandColor(pulse),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: CustomPaint(
              painter: _MiniTrendPainter(
                values: trend,
                color: const Color(0xFF00D4FF),
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              trend.length,
              (index) => Text(
                'D${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    int divisions = 10,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
              Text(
                valueLabel,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00D4FF),
              inactiveTrackColor: Colors.white.withOpacity(0.15),
              thumbColor: const Color(0xFF00D4FF),
              overlayColor: const Color(0xFF00D4FF).withOpacity(0.2),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
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

class _MiniTrendPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _MiniTrendPainter({
    required this.values,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).abs();
    final safeRange = range < 0.0001 ? 1 : range;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final normalized = (values[i] - minVal) / safeRange;
      final y = size.height - (normalized * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniTrendPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
