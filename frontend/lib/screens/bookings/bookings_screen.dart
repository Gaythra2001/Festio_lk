import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/booking_model.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<BookingProvider>(context, listen: false)
            .loadBookings(authProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
        ),
        body: const Center(
          child: Text('Please login to view your bookings'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BookingsList(status: BookingStatus.upcoming),
          _BookingsList(status: BookingStatus.past),
          _BookingsList(status: BookingStatus.cancelled),
        ],
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final BookingStatus status;

  const _BookingsList({required this.status});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        List<BookingModel> bookings;
        switch (status) {
          case BookingStatus.upcoming:
            bookings = bookingProvider.upcomingBookings;
            break;
          case BookingStatus.past:
            bookings = bookingProvider.pastBookings;
            break;
          case BookingStatus.cancelled:
            bookings = bookingProvider.cancelledBookings;
            break;
        }

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${status.name} bookings',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: booking.eventImageUrl != null
                    ? Image.network(
                        booking.eventImageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.event);
                        },
                      )
                    : const Icon(Icons.event),
                title: Text(booking.eventTitle),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.eventLocation),
                    Text(
                      DateFormat('MMM dd, yyyy').format(booking.eventDate),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: status == BookingStatus.upcoming
                    ? IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => _cancelBooking(context, booking.id),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _cancelBooking(BuildContext context, String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<BookingProvider>(context, listen: false)
          .cancelBooking(bookingId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled')),
        );
      }
    }
  }
}

