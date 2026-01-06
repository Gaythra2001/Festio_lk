import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/rating_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/rating_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// Main Rating Tab Widget with Event and Platform Rating options
class RatingTab extends StatefulWidget {
  final String? eventId;
  final String? eventName;
  final bool isPlatformRating;

  const RatingTab({
    Key? key,
    this.eventId,
    this.eventName,
    this.isPlatformRating = false,
  }) : super(key: key);

  @override
  State<RatingTab> createState() => _RatingTabState();
}

class _RatingTabState extends State<RatingTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Schedule loading for after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRatings();
    });
  }

  void _loadRatings() {
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    if (widget.isPlatformRating) {
      ratingProvider.loadPlatformRatings();
    } else if (widget.eventId != null) {
      ratingProvider.loadEventRatings(widget.eventId!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.purple,
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'All Reviews'),
            ],
          ),
        ),

        // Tab View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildAllReviewsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<RatingProvider>(
      builder: (context, ratingProvider, child) {
        if (ratingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = widget.isPlatformRating
            ? ratingProvider.platformStats
            : ratingProvider.eventStats;

        if (stats == null) {
          return Center(
            child: Text(
              'No ratings yet',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Summary Card
              _buildRatingSummaryCard(stats),
              const SizedBox(height: 20),

              // Rating Distribution
              _buildRatingDistribution(stats),
              const SizedBox(height: 20),

              // Top Tags
              if (stats.topTags.isNotEmpty) ...[
                _buildTopTags(stats),
                const SizedBox(height: 20),
              ],

              // Add Rating Button
              _buildAddRatingButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingSummaryCard(RatingStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Average Rating
            Column(
              children: [
                Text(
                  stats.averageRating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                _buildStarRating(stats.averageRating),
                const SizedBox(height: 8),
                Text(
                  stats.qualityIndicator,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.totalRatings} reviews',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 32),

            // Statistics
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(
                    Icons.verified_user,
                    'Verified Reviews',
                    '${stats.verifiedRatings}',
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    Icons.comment,
                    'With Comments',
                    '${stats.reviewsWithText}',
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    Icons.image,
                    'With Images',
                    '${stats.reviewsWithImages}',
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    Icons.thumb_up,
                    'Recommendation',
                    '${stats.recommendationScore.toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.purple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingDistribution(RatingStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating Distribution',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 5; i >= 1; i--) _buildDistributionBar(i, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionBar(int stars, RatingStats stats) {
    final percentage = stats.getPercentage(stars);
    final count = stats.ratingDistribution[stars] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$stars',
            style:
                GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 50,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTags(RatingStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Mentioned',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.topTags.map((tag) {
                return Chip(
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
        ),
      ),
    );
  }

  Widget _buildAllReviewsTab() {
    return Consumer<RatingProvider>(
      builder: (context, ratingProvider, child) {
        if (ratingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final ratings = widget.isPlatformRating
            ? ratingProvider.platformRatings
            : ratingProvider.eventRatings;

        if (ratings.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ratings.length,
          itemBuilder: (context, index) {
            return _buildReviewCard(ratings[index]);
          },
        );
      },
    );
  }

  Widget _buildReviewCard(RatingModel rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: rating.userPhotoUrl != null
                      ? NetworkImage(rating.userPhotoUrl!)
                      : null,
                  child: rating.userPhotoUrl == null
                      ? Text(rating.userName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            rating.userName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (rating.isVerifiedBooking) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        rating.formattedDate,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStarRating(rating.rating, size: 16),
              ],
            ),

            // Review Text
            if (rating.review != null && rating.review!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                rating.review!,
                style: GoogleFonts.poppins(fontSize: 13, height: 1.5),
              ),
            ],

            // Tags
            if (rating.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: rating.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Helpful Button
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    Provider.of<RatingProvider>(context, listen: false)
                        .markHelpful(rating.id);
                  },
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text('Helpful (${rating.helpfulCount})'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),

            // Organizer Response
            if (rating.organizerResponse != null) ...[
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.business,
                            size: 16, color: Colors.purple),
                        const SizedBox(width: 6),
                        Text(
                          'Organizer Response',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rating.organizerResponse!,
                      style: GoogleFonts.poppins(fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddRatingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showRatingDialog(),
        icon: const Icon(Icons.rate_review),
        label: const Text('Write a Review'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to write a review!',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showRatingDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Write a Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating, {double size = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : index < rating
                  ? Icons.star_half
                  : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }

  void _showRatingDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Use demo user if not logged in
    final userId = authProvider.user?.id ??
        'demo_user_${DateTime.now().millisecondsSinceEpoch}';
    final userName = authProvider.user?.displayName ?? 'Guest User';
    final userPhotoUrl = authProvider.user?.photoUrl;

    showDialog(
      context: context,
      builder: (context) => _RatingDialog(
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        eventId: widget.eventId,
        eventName: widget.eventName,
      ),
    );
  }
}

// Rating Dialog Widget
class _RatingDialog extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String? eventId;
  final String? eventName;

  const _RatingDialog({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.eventId,
    this.eventName,
  });

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  double _rating = 5;
  final _reviewController = TextEditingController();
  final List<String> _selectedTags = [];

  final List<String> _availableTags = [
    'Great venue',
    'Well organized',
    'Good entertainment',
    'Great atmosphere',
    'Value for money',
    'Friendly staff',
    'Poor organization',
    'Parking issues',
    'Too crowded',
    'Sound quality',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Write a Review',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Star Rating
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _rating = (index + 1).toDouble();
                        });
                      },
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // Review Text
              TextField(
                controller: _reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tags
              Text(
                'Add tags:',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: Colors.purple.withOpacity(0.2),
                    labelStyle: GoogleFonts.poppins(fontSize: 11),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitRating() async {
    final rating = RatingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.userId,
      userName: widget.userName,
      userPhotoUrl: widget.userPhotoUrl,
      eventId: widget.eventId,
      eventName: widget.eventName,
      rating: _rating,
      review: _reviewController.text.trim().isEmpty
          ? null
          : _reviewController.text.trim(),
      tags: _selectedTags,
      createdAt: DateTime.now(),
      isVerifiedBooking: false, // This should be checked against bookings
    );

    final success = await Provider.of<RatingProvider>(context, listen: false)
        .submitRating(rating);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
