

import 'package:festio_lk/screens/Erecommendation/event_registration_screen.dart';
import 'package:festio_lk/screens/Erecommendation/event_suggestion_screen.dart';
import 'package:flutter/material.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages =  [
   const EventRegistrationScreen(),
   const EventSuggestionScreen(),
  
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF141A3D),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Register"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Suggestions"),
 
        ],
      ),
    );
  }
}