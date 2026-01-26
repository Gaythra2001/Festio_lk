import 'package:flutter/material.dart';
import 'screens/home/modern_home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Festio LK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ModernHomeScreen(),
    );
  }
}
