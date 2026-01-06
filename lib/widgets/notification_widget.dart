import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/providers/notification_provider.dart';
import '../screens/events/modern_event_detail_screen.dart';

class NotificationBell extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? iconColor;

  const NotificationBell({super.key, this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: iconColor ?? Colors.white,
                size: 22,
              ),
              onPressed: onTap ??
                  () {
                    showNotificationPanel(context);
                  },
            ),
            if (notificationProvider.unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFff9a9e),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      notificationProvider.unreadCount > 9
                          ? '9+'
                          : notificationProvider.unreadCount.toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static void showNotificationPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const NotificationPanel(),
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0E27),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0A0E27),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifications',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (notificationProvider.unreadCount > 0)
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.done_all, size: 18),
                              label: const Text('Mark All Read'),
                              onPressed: () {
                                notificationProvider.markAllAsRead();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF667eea),
                                side: const BorderSide(
                                  color: Color(0xFF667eea),
                                ),
                              ),
                            ),
                          ),
                        if (notificationProvider.unreadCount > 0)
                          const SizedBox(width: 8),
                        if (notificationProvider.notifications.isNotEmpty)
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Clear All'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF1A1F3A),
                                    title: Text(
                                      'Clear All Notifications?',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          notificationProvider
                                              .clearAllNotifications();
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Clear',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notifications List
                  if (notificationProvider.notifications.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.white38,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Notifications',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: notificationProvider.notifications.length,
                        itemBuilder: (context, index) {
                          final notification =
                              notificationProvider.notifications[index];
                          return NotificationItem(
                            notification: notification,
                            onDelete: () {
                              notificationProvider
                                  .deleteNotification(notification.id);
                            },
                            onTap: () {
                              notificationProvider.markAsRead(notification.id);

                              // Navigate to event details if it's an event notification
                              if (notification.type == 'event' &&
                                  notification.metadata != null) {
                                Navigator.pop(
                                    context); // Close notification panel
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ModernEventDetailScreen(
                                      title:
                                          notification.metadata!['title'] ?? '',
                                      date:
                                          notification.metadata!['date'] ?? '',
                                      location:
                                          notification.metadata!['location'] ??
                                              '',
                                      imageUrl: notification
                                              .metadata!['imageUrl'] ??
                                          'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3',
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onDelete?.call();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.transparent
              : const Color(0xFF667eea).withOpacity(0.15),
          border: Border.all(
            color: notification.isRead
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFF667eea),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              notification.iconData != null
                  ? _iconFromString(notification.iconData!)
                  : _getIconForType(notification.type),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            notification.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight:
                  notification.isRead ? FontWeight.w500 : FontWeight.w600,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(notification.timestamp),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          onTap: onTap,
          trailing: !notification.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF667eea),
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  IconData _iconFromString(String key) {
    switch (key) {
      case 'campaign':
        return Icons.campaign;
      case 'local_offer':
        return Icons.local_offer;
      case 'star':
        return Icons.star;
      case 'event':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'booking':
        return Icons.check_circle;
      case 'reminder':
        return Icons.notifications_active;
      case 'event':
        return Icons.event;
      case 'message':
        return Icons.mail;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
