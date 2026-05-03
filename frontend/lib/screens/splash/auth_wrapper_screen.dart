import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/modern_login_screen.dart';
import '../navigation/main_navigation_screen.dart';

/// Wrapper screen that handles initial auth state checking
/// This ensures the app navigates to the correct screen on startup/refresh
class AuthWrapperScreen extends StatelessWidget {
  const AuthWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // While initializing Firebase session, show a splash screen
        if (authProvider.isInitializing) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F1729),
                    Color(0xFF1A1F3A),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.purple.shade300,
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading Festio LK',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // If user is authenticated, navigate to main navigation screen
        if (authProvider.isAuthenticated) {
          return const MainNavigationScreen();
        }

        // Otherwise, show login screen
        return const ModernLoginScreen();
      },
    );
  }
}
