import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/providers/notification_provider.dart';

class PromotionNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onDismiss;

  const PromotionNotificationCard({
    Key? key,
    required this.notification,
    this.onDismiss,
  }) : super(key: key);

  Color _getBackgroundColor() {
    if (notification.metadata?['isPaid'] == true) {
      final tier = notification.metadata?['tier'] ?? 'basic';
      switch (tier) {
        case 'standard':
          return const Color(0xFF2196F3);
        case 'premium':
          return const Color(0xFFFF9800);
        case 'basic':
        default:
          return const Color(0xFF4CAF50);
      }
    }
    return const Color(0xFF667eea);
  }

  IconData _getIconData() {
    final iconName = notification.iconData ?? 'campaign';
    switch (iconName) {
      case 'save':
        return Icons.save;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'payment':
        return Icons.payment;
      case 'event_available':
        return Icons.event_available;
      case 'trending_up':
        return Icons.trending_up;
      case 'campaign':
      default:
        return Icons.campaign;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final isPaid = notification.metadata?['isPaid'] == true;
    final amount = notification.metadata?['amount'] as double?;
    final views = notification.metadata?['views'] as int?;
    final clicks = notification.metadata?['clicks'] as int?;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle notification tap
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and title
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconData(),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            if (isPaid)
                              Text(
                                notification.metadata?['tier']?.toUpperCase() ??
                                    'PREMIUM',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (onDismiss != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: onDismiss,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Message
                  Text(
                    notification.message,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Additional details based on notification type
                  if (isPaid && amount != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount Paid',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Rs ${amount.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (views != null && clicks != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Views',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '$views',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clicks',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '$clicks',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Timestamp
                  const SizedBox(height: 10),
                  Text(
                    _formatTimestamp(notification.timestamp),
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
