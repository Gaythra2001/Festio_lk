import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Organizer verification badge widget
class OrganizerVerificationBadge extends StatelessWidget {
  final bool isVerified;
  final bool isPhoneVerified;
  final double rating;
  final int totalEvents;
  final String? verificationStatus;

  const OrganizerVerificationBadge({
    super.key,
    required this.isVerified,
    this.isPhoneVerified = false,
    required this.rating,
    required this.totalEvents,
    this.verificationStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified && rating < 4.0 && totalEvents < 5) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isVerified) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Verified',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (rating >= 4.5) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFC107), Color(0xFFFFB300)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Top Rated',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (totalEvents >= 10) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Trusted',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// Trust score indicator
class TrustScoreIndicator extends StatelessWidget {
  final double trustScore;
  final int maxScore;
  final bool showLabel;

  const TrustScoreIndicator({
    super.key,
    required this.trustScore,
    this.maxScore = 100,
    this.showLabel = true,
  });

  Color get _scoreColor {
    final percentage = (trustScore / maxScore) * 100;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.amber;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  String get _scoreLabel {
    final percentage = (trustScore / maxScore) * 100;
    if (percentage >= 80) return 'Highly Trustworthy';
    if (percentage >= 60) return 'Trustworthy';
    if (percentage >= 40) return 'Fair';
    return 'Low Trust';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: trustScore / maxScore,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _scoreLabel,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _scoreColor,
                ),
              ),
              Text(
                '${trustScore.toStringAsFixed(0)}/$maxScore',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }
}

// Rating display widget
class RatingDisplay extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final bool compact;

  const RatingDisplay({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < rating.floor() ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: compact ? 12 : 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$rating',
          style: GoogleFonts.poppins(
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount)',
          style: GoogleFonts.poppins(
            fontSize: compact ? 11 : 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

// Organizer trust card - simplified profile card for event listings
class OrganizerTrustCard extends StatelessWidget {
  final String organizerName;
  final double rating;
  final int totalEvents;
  final bool isVerified;
  final int reviewCount;
  final VoidCallback onTap;

  const OrganizerTrustCard({
    super.key,
    required this.organizerName,
    required this.rating,
    required this.totalEvents,
    required this.isVerified,
    required this.reviewCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF667eea),
                  child: Text(
                    organizerName.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organizerName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      RatingDisplay(
                        rating: rating,
                        reviewCount: reviewCount,
                        compact: true,
                      ),
                    ],
                  ),
                ),
                if (isVerified)
                  Icon(
                    Icons.verified,
                    color: Colors.blue[400],
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 14,
                  color: Colors.white54,
                ),
                const SizedBox(width: 4),
                Text(
                  '$totalEvents events',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// New organizer badge
class NewOrganizerBadge extends StatelessWidget {
  final DateTime createdAt;
  final int daysToShowBadge;

  const NewOrganizerBadge({
    super.key,
    required this.createdAt,
    this.daysToShowBadge = 30,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;

    if (difference > daysToShowBadge) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.new_releases,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'New Organizer',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Trust info tooltip/info box
class TrustInfoBox extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const TrustInfoBox({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
