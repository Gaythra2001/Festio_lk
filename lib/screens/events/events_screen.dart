import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/event_provider.dart';
import '../../core/models/event_model.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.events.isEmpty) {
            return const Center(
              child: Text('No events available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await eventProvider.loadUpcomingEvents();
            },
            child: ListView.builder(
              itemCount: eventProvider.events.length,
              itemBuilder: (context, index) {
                final event = eventProvider.events[index];
                return _EventListItem(event: event);
              },
            ),
          );
        },
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final EventModel event;

  const _EventListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            ),
          );
        },
        child: Row(
          children: [
            if (event.imageUrl != null)
              Image.network(
                event.imageUrl!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.event),
                  );
                },
              )
            else
              Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.event),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

