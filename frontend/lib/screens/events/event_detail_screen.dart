import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/event_model.dart';
import '../../core/models/booking_model.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl != null
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.event, size: 64),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.event, size: 64),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('MMM dd, yyyy').format(event.startDate)} - ${DateFormat('MMM dd, yyyy').format(event.endDate)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    label: Text(event.category),
                    backgroundColor: Colors.deepPurple[100],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(event.description),
                  const SizedBox(height: 24),
                  if (event.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: event.tags
                          .map((tag) => Chip(
                                label: Text(tag),
                                labelStyle: const TextStyle(fontSize: 12),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (!authProvider.isAuthenticated) {
                        return const SizedBox.shrink();
                      }
                      return ElevatedButton(
                        onPressed: () => _bookEvent(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Book Event'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bookEvent(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    if (authProvider.user == null) return;

    final booking = BookingModel(
      id: '',
      eventId: event.id,
      userId: authProvider.user!.id,
      eventTitle: event.title,
      eventDate: event.startDate,
      eventLocation: event.location,
      eventImageUrl: event.imageUrl,
      status: BookingStatus.upcoming,
      bookedAt: DateTime.now(),
      numberOfTickets: 1,
      totalPrice: event.ticketPrice,
    );

    final success = await bookingProvider.createBooking(booking);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event booked successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to book event. Please try again.')),
        );
      }
    }
  }
}

