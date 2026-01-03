import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JuiceRating extends StatelessWidget {
  final double rating; // 0.0 to 5.0
  final String label;
  final bool showLabel;
  final double size;

  const JuiceRating({
    Key? key,
    required this.rating,
    this.label = 'Juice',
    this.showLabel = true,
    this.size = 24,
  }) : super(key: key);

  Color _getJuiceColor(double value) {
    // Gradient from cool to hot colors based on rating
    if (value < 1) return Colors.blue;
    if (value < 2) return Colors.cyan;
    if (value < 3) return Colors.green;
    if (value < 4) return Colors.orange;
    return Colors.red;
  }

  String _getJuiceLabel(double value) {
    if (value < 1) return 'Chill';
    if (value < 2) return 'Cool';
    if (value < 3) return 'Hot';
    if (value < 4) return 'Spicy';
    return 'Blazing';
  }

  @override
  Widget build(BuildContext context) {
    final clampedRating = rating.clamp(0.0, 5.0);
    final juiceColor = _getJuiceColor(clampedRating);
    final filledCount = clampedRating.toInt();
    final partialFill = clampedRating - filledCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Juice glasses
            for (int i = 0; i < 5; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildJuiceGlass(
                  isFilled: i < filledCount,
                  isPartial: i == filledCount && partialFill > 0,
                  partialFill: partialFill,
                  color: juiceColor,
                ),
              ),
            const SizedBox(width: 12),
            // Rating text
            Text(
              '${clampedRating.toStringAsFixed(1)}/5',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: juiceColor,
              ),
            ),
          ],
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            _getJuiceLabel(clampedRating),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildJuiceGlass({
    required bool isFilled,
    required bool isPartial,
    required double partialFill,
    required Color color,
  }) {
    return SizedBox(
      width: size,
      height: size * 1.2,
      child: Stack(
        children: [
          // Glass outline
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.2),
              border: Border.all(
                color: color.withOpacity(0.4),
                width: 1.5,
              ),
            ),
          ),
          // Juice fill (from bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(size * 0.2),
                bottomRight: Radius.circular(size * 0.2),
              ),
              child: Container(
                height: size * 1.2 * (isFilled ? 1 : (isPartial ? partialFill : 0)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withOpacity(0.6),
                      color.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Glass shine effect
          if (isFilled || isPartial)
            Positioned(
              top: size * 0.1,
              left: size * 0.15,
              child: Container(
                width: size * 0.3,
                height: size * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.15),
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class JuiceRatingCompact extends StatelessWidget {
  final double rating; // 0.0 to 5.0

  const JuiceRatingCompact({
    Key? key,
    required this.rating,
  }) : super(key: key);

  Color _getJuiceColor(double value) {
    if (value < 1) return Colors.blue;
    if (value < 2) return Colors.cyan;
    if (value < 3) return Colors.green;
    if (value < 4) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final clampedRating = rating.clamp(0.0, 5.0);
    final juiceColor = _getJuiceColor(clampedRating);
    final percentage = (clampedRating / 5 * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            juiceColor.withOpacity(0.2),
            juiceColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: juiceColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_drink, size: 14, color: juiceColor),
          const SizedBox(width: 6),
          Text(
            '$percentage%',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: juiceColor,
            ),
          ),
        ],
      ),
    );
  }
}
