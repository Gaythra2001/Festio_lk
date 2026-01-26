import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/rating_provider.dart';
import '../../core/models/rating_model.dart';

/// Rating Analytics Dashboard for Event Organizers
class RatingAnalyticsScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const RatingAnalyticsScreen({
    Key? key,
    required this.eventId,
    required this.eventName,
  }) : super(key: key);

  @override
  State<RatingAnalyticsScreen> createState() => _RatingAnalyticsScreenState();
}

class _RatingAnalyticsScreenState extends State<RatingAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RatingProvider>(context, listen: false)
          .loadEventRatings(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rating Analytics',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<RatingProvider>(
        builder: (context, ratingProvider, child) {
          if (ratingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = ratingProvider.eventStats;
          final ratings = ratingProvider.eventRatings;

          if (stats == null || ratings.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(stats),

                // Key Metrics
                _buildKeyMetrics(stats),

                // Rating Breakdown
                _buildRatingBreakdown(stats),

                // Sentiment Analysis
                _buildSentimentAnalysis(stats, ratings),

                // Recent Reviews
                _buildRecentReviews(ratings),

                // Response Rate
                _buildResponseRate(ratings),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(RatingStats stats) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            widget.eventName,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeaderStat(
                stats.averageRating.toStringAsFixed(2),
                'Average Rating',
                Icons.star,
              ),
              _buildHeaderStat(
                '${stats.totalRatings}',
                'Total Reviews',
                Icons.rate_review,
              ),
              _buildHeaderStat(
                '${stats.recommendationScore.toStringAsFixed(0)}%',
                'Would Recommend',
                Icons.thumb_up,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildKeyMetrics(RatingStats stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Metrics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Verified Reviews',
                  '${stats.verifiedRatings}',
                  Icons.verified_user,
                  Colors.blue,
                  '${((stats.verifiedRatings / stats.totalRatings) * 100).toStringAsFixed(0)}% of total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Detailed Reviews',
                  '${stats.reviewsWithText}',
                  Icons.comment,
                  Colors.green,
                  '${((stats.reviewsWithText / stats.totalRatings) * 100).toStringAsFixed(0)}% of total',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'With Images',
                  '${stats.reviewsWithImages}',
                  Icons.image,
                  Colors.orange,
                  '${((stats.reviewsWithImages / stats.totalRatings) * 100).toStringAsFixed(0)}% of total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Quality Score',
                  stats.qualityIndicator,
                  Icons.trending_up,
                  Colors.purple,
                  'Based on ratings',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBreakdown(RatingStats stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rating Breakdown',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              for (int i = 5; i >= 1; i--) _buildBreakdownRow(i, stats),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(int stars, RatingStats stats) {
    final count = stats.ratingDistribution[stars] ?? 0;
    final percentage = stats.getPercentage(stars);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Row(
              children: [
                Text(
                  '$stars',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star, size: 18, color: Colors.amber),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.purple.shade300],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 50,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '($count)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentAnalysis(RatingStats stats, List<RatingModel> ratings) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sentiment Analysis',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Top Tags
              if (stats.topTags.isNotEmpty) ...[
                Text(
                  'Most Mentioned Topics:',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: stats.topTags.map((tag) {
                    final count = _getTagCount(tag, ratings);
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      label: Text(tag),
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _getTagCount(String tag, List<RatingModel> ratings) {
    return ratings.where((r) => r.tags.contains(tag)).length;
  }

  Widget _buildRecentReviews(List<RatingModel> ratings) {
    final recentReviews = ratings.take(5).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Reviews',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...recentReviews.map((review) => _buildReviewItem(review)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(RatingModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.userName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          if (review.review != null) ...[
            const SizedBox(height: 8),
            Text(
              review.review!,
              style: GoogleFonts.poppins(fontSize: 12, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.formattedDate,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              if (review.organizerResponse == null)
                TextButton(
                  onPressed: () => _showResponseDialog(review),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 0),
                  ),
                  child: Text(
                    'Respond',
                    style: GoogleFonts.poppins(fontSize: 11),
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Responded',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponseRate(List<RatingModel> ratings) {
    final totalReviews = ratings.length;
    final respondedReviews =
        ratings.where((r) => r.organizerResponse != null).length;
    final responseRate =
        totalReviews > 0 ? (respondedReviews / totalReviews * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Response Rate',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${responseRate.toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        Text(
                          '$respondedReviews of $totalReviews reviews responded',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: responseRate / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.purple,
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.reply,
                            size: 32,
                            color: Colors.purple.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No rating data available',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ratings will appear here once users start reviewing',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showResponseDialog(RatingModel review) {
    final responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Respond to Review',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (review.review != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      review.review!,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: responseController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your response...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.trim().isNotEmpty) {
                final success = await Provider.of<RatingProvider>(
                  context,
                  listen: false,
                ).addOrganizerResponse(
                  review.id,
                  responseController.text.trim(),
                );

                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Response added successfully!'),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
