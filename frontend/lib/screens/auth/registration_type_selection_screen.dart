import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_registration_screen.dart';
import 'organizer_registration_screen.dart';
import 'modern_login_screen.dart';

class RegistrationTypeSelectionScreen extends StatelessWidget {
  const RegistrationTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          ),
          // Decorative accent blobs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667eea).withOpacity(0.15),
                    const Color(0xFF764ba2).withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF764ba2).withOpacity(0.12),
                    const Color(0xFF667eea).withOpacity(0.06),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Professional Logo/Branding
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.event_available,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Brand name
                  Text(
                    'Festio LK',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Join as',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // User Registration Card
                  _buildRegistrationCard(
                    context: context,
                    icon: Icons.event_seat,
                    title: 'Event Attendee',
                    description: 'Discover, explore, and book events easily. '
                        'Get event recommendations personalized for you.',
                    features: [
                      '✓ Browse events',
                      '✓ Book tickets',
                      '✓ Quick Google registration',
                    ],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UserRegistrationScreen(),
                        ),
                      );
                    },
                    isPrimary: true,
                  ),

                  const SizedBox(height: 20),

                  // Organizer Registration Card
                  _buildRegistrationCard(
                    context: context,
                    icon: Icons.business_center,
                    title: 'Event Organizer',
                    description: 'Create and manage events professionally. '
                        'Build your reputation and reach thousands of attendees.',
                    features: [
                      '✓ Create events',
                      '✓ Manage bookings',
                      '✓ Build trust profile',
                    ],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrganizerRegistrationScreen(),
                        ),
                      );
                    },
                    isPrimary: false,
                  ),

                  const SizedBox(height: 40),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const ModernLoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Login here',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF667eea),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                )
              : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPrimary
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFF667eea).withOpacity(0.2),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isPrimary ? Colors.white : const Color(0xFF667eea),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isPrimary ? Colors.white70 : Colors.white60,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            // Features
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  feature,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPrimary ? Colors.white70 : Colors.white60,
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPrimary
                      ? Colors.white
                      : const Color(0xFF667eea),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Register as ${title.split(' ').first}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isPrimary
                        ? const Color(0xFF667eea)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
