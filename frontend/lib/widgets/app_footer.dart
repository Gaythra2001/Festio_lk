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

    final footerContent = isMobile
        ? _buildMobileLayout()
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: _buildDesktopLayout(),
            ),
          );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E27),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: footerContent,
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Section - Branding
            Expanded(
              flex: 3,
              child: _buildBrandingSection(),
            ),
            const SizedBox(width: 50),

            // Helpful Links
            Expanded(
              flex: 2,
              child: _buildHelpfulLinks(),
            ),
            const SizedBox(width: 40),

            // About Us
            Expanded(
              flex: 2,
              child: _buildAboutUs(),
            ),
            const SizedBox(width: 40),

            // Contact
            Expanded(
              flex: 2,
              child: _buildContact(),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Container(
          padding: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© ${DateTime.now().year} Festio.LK. All rights reserved.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
              Row(
                children: [
                  _buildBottomLink('Privacy Policy'),
                  const SizedBox(width: 24),
                  _buildBottomLink('Terms of Service'),
                  const SizedBox(width: 24),
                  _buildBottomLink('Cookie Policy'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandingSection(),
        const SizedBox(height: 32),
        _buildHelpfulLinks(),
        const SizedBox(height: 24),
        _buildAboutUs(),
        const SizedBox(height: 24),
        _buildContact(),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '© ${DateTime.now().year} Festio.LK. All rights reserved.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildBottomLink('Privacy Policy'),
                  _buildBottomLink('Terms of Service'),
                  _buildBottomLink('Cookie Policy'),
                ],
              ),
            ],
          ),
        ),
      ],
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
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7CCFB2), Color(0xFFFFD7A3)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.celebration,
                color: Color(0xFF0A0E27),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Festio',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              '.LK',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7CCFB2),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Description
        Text(
          'Sri Lanka\'s premier online event platform for '
          'discovering and booking entertainment events.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white60,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),

        // Social Media Icons
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
        const SizedBox(height: 18),

        // Payment Methods
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPaymentLogo('VISA', const Color(0xFF1A1F71)),
            _buildPaymentLogo('MC', const Color(0xFFEB001B)),
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
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
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
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
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
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
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
                color: Colors.white60,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'WhatsApp (Text-only)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white60,
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
                color: Colors.white60,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'support@festio.lk',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white60,
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
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white70,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildSocialIconCustom(String text, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
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
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBottomLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.white60,
          decoration: TextDecoration.none,
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
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white60,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
