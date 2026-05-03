import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/event_model.dart';
import '../../core/models/booking_model.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int _selectedTicketIndex = 0;
  int _selectedQuantity = 1;

  Widget _buildHeroImage() {
    final String? imageUrl = widget.event.imageUrl;

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.event, size: 64),
      );
    }

    final uri = Uri.tryParse(imageUrl);
    final bool isNetworkImage = uri != null && uri.hasScheme;

    if (isNetworkImage) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.event, size: 64),
          );
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.event, size: 64),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroImage(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('MMM dd, yyyy').format(widget.event.startDate)} - ${DateFormat('MMM dd, yyyy').format(widget.event.endDate)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.event.location,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    label: Text(widget.event.category),
                    backgroundColor: Colors.deepPurple[100],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.event.description),
                  const SizedBox(height: 24),
                  if (widget.event.tickets.isNotEmpty) ...[
                    Text(
                      'Tickets',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          value: _selectedTicketIndex.clamp(0, widget.event.tickets.length - 1),
                          decoration: const InputDecoration(border: InputBorder.none),
                          dropdownColor: const Color(0xFF1A1F3A),
                          style: TextStyle(color: Colors.white),
                          items: List.generate(widget.event.tickets.length, (i) {
                            final t = widget.event.tickets[i];
                            final price = (t['price'] as num?)?.toDouble() ?? 0.0;
                            final label = price == 0 ? 'Free' : 'LKR ${price.toStringAsFixed(0)}';
                            return DropdownMenuItem<int>(
                              value: i,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(t['ticket_type']?.toString() ?? 'Ticket', style: TextStyle(color: Colors.white)),
                                  Text(label, style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                            );
                          }),
                          onChanged: (idx) {
                            if (idx == null) return;
                            setState(() {
                              _selectedTicketIndex = idx;
                              _selectedQuantity = 1;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Quantity', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (_selectedQuantity > 1) _selectedQuantity--;
                                });
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('$_selectedQuantity', style: Theme.of(context).textTheme.bodyMedium),
                            IconButton(
                              onPressed: () {
                                final available = (widget.event.tickets[_selectedTicketIndex]['quantity'] is num)
                                    ? (widget.event.tickets[_selectedTicketIndex]['quantity'] as num).toInt()
                                    : int.tryParse(widget.event.tickets[_selectedTicketIndex]['quantity']?.toString() ?? '0') ?? 0;
                                setState(() {
                                  if (_selectedQuantity < available) _selectedQuantity++;
                                });
                              },
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Builder(builder: (ctx) {
                                  final p = (widget.event.tickets[_selectedTicketIndex]['price'] as num?)?.toDouble() ?? widget.event.ticketPrice ?? 0.0;
                                  final total = p * _selectedQuantity;
                                  return Text('Total: ${p == 0 ? 'Free' : 'LKR ${total.toStringAsFixed(0)}'}', style: TextStyle(fontWeight: FontWeight.w600));
                                }),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    const SizedBox.shrink(),
                  ],
                  if (widget.event.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.event.tags
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
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    if (authProvider.user == null) return;

    int ticketsToBook = 1;
    double total = 0.0;

    if (widget.event.tickets.isNotEmpty) {
      ticketsToBook = _selectedQuantity;
      final dynamic p = widget.event.tickets[_selectedTicketIndex]['price'];
      final double unitPrice = p is num ? p.toDouble() : (widget.event.ticketPrice ?? 0.0);
      total = unitPrice * ticketsToBook;
    } else {
      ticketsToBook = 1;
      total = widget.event.ticketPrice ?? 0.0;
    }

    final booking = BookingModel(
      id: '',
      eventId: widget.event.id,
      userId: authProvider.user!.id,
      eventTitle: widget.event.title,
      eventDate: widget.event.startDate,
      eventLocation: widget.event.location,
      eventImageUrl: widget.event.imageUrl,
      status: BookingStatus.upcoming,
      bookedAt: DateTime.now(),
      numberOfTickets: ticketsToBook,
      totalPrice: total,
    );

    final success = await bookingProvider.createBooking(booking);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event booked successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to book event. Please try again.')),
        );
      }
    }
  }
}
