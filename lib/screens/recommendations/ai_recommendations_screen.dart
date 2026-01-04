import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/recommendation_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/event_provider.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/services/ai/advanced_recommendation_engine.dart';
import '../../core/models/user_model.dart';
import '../../widgets/ai_chatbot_widget.dart';
import '../profile/user_preferences_form_screen.dart';
import '../events/modern_event_detail_screen.dart';

class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({Key? key}) : super(key: key);

  @override
  State<AIRecommendationsScreen> createState() =>
      _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  bool _showExplanations = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final recommendationProvider =
        Provider.of<RecommendationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    if (authProvider.user != null) {
      await recommendationProvider.loadAdvancedRecommendations(
        user: authProvider.user!,
        allEvents: eventProvider.events,
        userBookings: bookingProvider.bookings,
        allUserBookings: {},
        maxRecommendations: 20,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(
          'AI Recommendations',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
                _showExplanations ? Icons.visibility : Icons.visibility_off),
            tooltip: 'Toggle Explanations',
            onPressed: () {
              setState(() {
                _showExplanations = !_showExplanations;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Preferences',
            onPressed: () {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final recommendationProvider =
                  Provider.of<RecommendationProvider>(context, listen: false);

              if (authProvider.user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPreferencesFormScreen(
                      userId: authProvider.user!.id,
                      existingPreferences:
                          recommendationProvider.userPreferences,
                    ),
                  ),
                ).then((_) => _loadRecommendations());
              }
            },
          ),
        ],
      ),
      body: Consumer<RecommendationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Personalizing recommendations...',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.recommendations.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: _loadRecommendations,
            color: Colors.purple,
            child: CustomScrollView(
              slivers: [
                // Header with stats
                SliverToBoxAdapter(
                  child: _buildHeader(provider),
                ),

                // Recommendations list
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final scoredEvent = provider.recommendations[index];
                        return _buildRecommendationCard(scoredEvent, context);
                      },
                      childCount: provider.recommendations.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openChatbot,
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('AI Assistant'),
      ),
    );
  }

  Widget _buildHeader(RecommendationProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Personalized for You',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                  'Found', '${provider.recommendations.length}', Icons.event),
              _buildStat(
                'High Match',
                '${provider.getHighConfidenceRecommendations(threshold: 0.7).length}',
                Icons.stars,
              ),
              _buildStat(
                'Preferences',
                provider.hasCompletedPreferences() ? 'Complete' : 'Pending',
                Icons.check_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
      ScoredEvent scoredEvent, BuildContext context) {
    final event = scoredEvent.event;
    final scorePercentage = (scoredEvent.score * 100).toInt();
    final confidencePercentage = (scoredEvent.confidenceLevel * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scorePercentage >= 70
              ? Colors.purple.withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Track click
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          final recommendationProvider =
              Provider.of<RecommendationProvider>(context, listen: false);

          if (authProvider.user != null) {
            recommendationProvider.trackEventClick(
                authProvider.user!.id, event);
          }

          // Navigate to event details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModernEventDetailScreen(
                title: event.title,
                date: event.startDate.toString(),
                location: event.location,
                imageUrl: event.imageUrl ?? '',
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with score badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: event.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: event.imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 180,
                            color: Colors.grey[800],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 180,
                            color: Colors.grey[800],
                            child: const Icon(Icons.event,
                                size: 50, color: Colors.white54),
                          ),
                        )
                      : Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade900,
                                Colors.blue.shade900
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.event,
                                size: 50, color: Colors.white54),
                          ),
                        ),
                ),
                // Score badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor(scorePercentage),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$scorePercentage%',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // High match indicator
                if (scorePercentage >= 85)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.whatshot,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'BEST MATCH',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Event details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Location and date
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.purple, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: GoogleFonts.outfit(
                              color: Colors.white70, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.purple, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(event.startDate),
                        style: GoogleFonts.outfit(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),

                  // Category
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(event.category),
                        backgroundColor: Colors.purple.withOpacity(0.3),
                        labelStyle:
                            const TextStyle(color: Colors.white, fontSize: 12),
                        padding: EdgeInsets.zero,
                      ),
                      if (event.ticketPrice != null && event.ticketPrice! > 0)
                        Chip(
                          label: Text(
                              'LKR ${event.ticketPrice!.toStringAsFixed(0)}'),
                          backgroundColor: Colors.green.withOpacity(0.3),
                          labelStyle: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          padding: EdgeInsets.zero,
                        )
                      else
                        const Chip(
                          label: Text('FREE'),
                          backgroundColor: Colors.green,
                          labelStyle:
                              TextStyle(color: Colors.white, fontSize: 12),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),

                  // Explanation
                  if (_showExplanations) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: Colors.purple, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              scoredEvent.getExplanation(),
                              style: GoogleFonts.outfit(
                                color: Colors.purple.shade200,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Confidence indicator
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Confidence:',
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: scoredEvent.confidenceLevel,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getScoreColor(confidencePercentage),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$confidencePercentage%',
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recommendationProvider = Provider.of<RecommendationProvider>(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 100,
              color: Colors.purple.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Recommendations Yet',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              recommendationProvider.hasCompletedPreferences()
                  ? 'Browse some events to help us understand your preferences better!'
                  : 'Complete your preferences to get personalized recommendations!',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!recommendationProvider.hasCompletedPreferences())
              ElevatedButton.icon(
                onPressed: () {
                  if (authProvider.user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserPreferencesFormScreen(
                          userId: authProvider.user!.id,
                        ),
                      ),
                    ).then((_) => _loadRecommendations());
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Set Preferences'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 85) return Colors.green;
    if (percentage >= 70) return Colors.lightGreen;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _openChatbot() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final recommendationProvider =
        Provider.of<RecommendationProvider>(context, listen: false);

    // Support guest chat when Firebase is disabled
    final isGuest = authProvider.user == null;
    final user = isGuest
        ? UserModel(
            id: 'guest',
            email: 'guest@festio.lk',
            displayName: 'Guest',
            createdAt: DateTime.now(),
            preferredLanguage: 'en',
          )
        : authProvider.user!;

    // Only load Firebase-backed data when signed-in and Firebase enabled
    if (!isGuest) {
      await recommendationProvider.loadUserPreferences(user.id);
      await recommendationProvider.loadUserBehavior(user.id);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return AIChatbotWidget(
            user: user,
            allEvents: eventProvider.events,
            userBookings: isGuest ? [] : bookingProvider.bookings,
            allUserBookings: const {},
            userPreferences: recommendationProvider.userPreferences,
            userBehavior: recommendationProvider.userBehavior,
          );
        },
      ),
    );
  }
}
