import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:festio_lk/core/theme/modern_theme.dart';
import 'package:festio_lk/screens/auth/modern_login_screen.dart';
import 'package:festio_lk/core/providers/auth_provider.dart';
import 'package:festio_lk/core/providers/event_provider.dart';
import 'package:festio_lk/core/providers/booking_provider.dart';
import 'package:festio_lk/core/providers/notification_provider.dart';
=======
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart'; // your app entry widget
>>>>>>> Stashed changes

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
<<<<<<< Updated upstream

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
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const ModernLoginScreen(),
      ),
    );
  }
}
=======
>>>>>>> Stashed changes
