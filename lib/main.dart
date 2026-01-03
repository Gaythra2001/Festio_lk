import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:festio_lk/core/theme/modern_theme.dart';
import 'package:festio_lk/screens/auth/modern_login_screen.dart';
import 'package:festio_lk/core/providers/auth_provider.dart';
import 'package:festio_lk/core/providers/event_provider.dart';
import 'package:festio_lk/core/providers/booking_provider.dart';
import 'package:festio_lk/core/providers/notification_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Festio LK',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const ModernLoginScreen(),
      ),
    );
  }
}