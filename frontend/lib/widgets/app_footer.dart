import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 40,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1635), // Dark navy blue background
      ),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Section - Branding
        Expanded(
          flex: 2,
          child: _buildBrandingSection(),
        ),
        const SizedBox(width: 60),

        // Helpful Links
        Expanded(
          child: _buildHelpfulLinks(),
        ),
        const SizedBox(width: 40),

        // About Us
        Expanded(
          child: _buildAboutUs(),
        ),
        const SizedBox(width: 40),

        // Contact
        Expanded(
          child: _buildContact(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandingSection(),
        const SizedBox(height: 40),
        _buildHelpfulLinks(),
        const SizedBox(height: 30),
        _buildAboutUs(),
        const SizedBox(height: 30),
        _buildContact(),
      ],
      ),
    );
  }

  Widget _buildBrandingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and Brand Name
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.celebration,
                color: Color(0xFF667eea),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Festio',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '.LK',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF667eea),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          "Festio.LK, Sri Lanka's premier and most trusted online event platform, "
          "serves as the official marketplace providing a secure and safe platform for "
          "discovering and booking all entertainment events in Sri Lanka.",
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),

        // Social Media Icons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSocialIcon(Icons.facebook, 'https://facebook.com'),
            _buildSocialIcon(Icons.camera_alt, 'https://instagram.com'),
            _buildSocialIcon(Icons.close, 'https://twitter.com'), // Twitter/X
            _buildSocialIconCustom('in', 'https://linkedin.com'), // LinkedIn
            _buildSocialIconCustom('♪', 'https://tiktok.com'), // TikTok
            _buildSocialIconCustom('▶', 'https://youtube.com'), // YouTube
            _buildSocialIconCustom('W', 'https://wa.me/94391112322'), // WhatsApp
          ],
        ),
        const SizedBox(height: 24),

        // Payment Methods
        Row(
          children: [
            _buildPaymentLogo('VISA', const Color(0xFF1A1F71)),
            const SizedBox(width: 8),
            _buildPaymentLogo('MC', const Color(0xFFEB001B)),
            const SizedBox(width: 8),
            _buildPaymentLogo('LOKO', const Color(0xFF4CAF50)),
          ],
        ),
      ],
    );
  }

  Widget _buildHelpfulLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Helpful Links',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink('Events', '/events'),
        _buildFooterLink('Festio Deals', '/deals'),
        _buildFooterLink('My Account', '/profile'),
        _buildFooterLink('Refund Policy', '/refund-policy'),
      ],
    );
  }

  Widget _buildAboutUs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Us',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink('Who We Are', '/about'),
        _buildFooterLink('FAQ', '/faq'),
        _buildFooterLink('Contact Us', '/contact'),
      ],
    );
  }

  Widget _buildContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        // WhatsApp
        GestureDetector(
          onTap: () => _launchWhatsApp('94391112322'),
          child: Row(
            children: [
              const Icon(
                Icons.message,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'WhatsApp(Text-only service)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Email
        GestureDetector(
          onTap: () => _launchEmail('support@festio.lk'),
          child: Row(
            children: [
              const Icon(
                Icons.email_outlined,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'support@festio.lk',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2449),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white70,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildSocialIconCustom(String text, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2449),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentLogo(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          // Navigation will be handled in the implementation
          // Navigator.pushNamed(context, route);
        },
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
