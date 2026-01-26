import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:festio_lk/core/theme/modern_theme.dart';
import 'package:festio_lk/screens/auth/modern_login_screen.dart';

import 'package:festio_lk/core/providers/auth_provider.dart';
import 'package:festio_lk/core/providers/event_provider.dart';
import 'package:festio_lk/core/providers/booking_provider.dart';
import 'package:festio_lk/core/providers/notification_provider.dart';
import 'package:festio_lk/core/providers/user_data_provider.dart';
import 'package:festio_lk/core/providers/recommendation_provider.dart';
import 'package:festio_lk/core/providers/rating_provider.dart';
import 'package:festio_lk/core/providers/promotion_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('si'), Locale('ta')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
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
        ChangeNotifierProxyProvider<NotificationProvider, PromotionProvider>(
          create: (context) => PromotionProvider(
            Provider.of<NotificationProvider>(context, listen: false),
          ),
          update: (context, notif, previous) =>
              previous ?? PromotionProvider(notif),
        ),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
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
