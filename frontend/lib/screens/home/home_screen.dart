import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/providers/event_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../organizer/organizer_dashboard_screen.dart';
import '../user/user_events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).loadUpcomingEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Route to appropriate dashboard based on user type
    if (user != null) {
      if (user.isOrganizer) {
        return const OrganizerDashboardScreen();
      } else {
        return const UserEventsScreen();
      }
    }

    // Fallback to login if no user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
