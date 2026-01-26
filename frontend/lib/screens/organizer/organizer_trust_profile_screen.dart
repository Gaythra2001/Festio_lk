import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/organizer_profile_model.dart';

class OrganizerTrustProfileScreen extends StatefulWidget {
  final String organizerId;
  final String organizerName;

  const OrganizerTrustProfileScreen({
    super.key,
    required this.organizerId,
    required this.organizerName,
  });

  @override
  State<OrganizerTrustProfileScreen> createState() =>
      _OrganizerTrustProfileScreenState();
}

class _OrganizerTrustProfileScreenState
    extends State<OrganizerTrustProfileScreen> {
  // Mock organizer profile - replace with actual data from provider
  late OrganizerProfileModel organizerProfile;

  @override
  void initState() {
    super.initState();
    // This should be loaded from a provider based on organizerId
    organizerProfile = OrganizerProfileModel(
      userId: widget.organizerId,
      organizerName: widget.organizerName,
      profileDescription:
          'Professional event organizer with 5+ years of experience',
      businessAddress: 'Colombo, Sri Lanka',
      isVerified: true,
      isPhoneVerified: true,
      verificationStatus: 'verified',
      verificationDate: DateTime.now().subtract(const Duration(days: 60)),
      averageRating: 4.7,
      totalReviews: 48,
      totalEventsHosted: 24,
      totalAttendees: 1250,
      totalTicketsSold: 1250,
      totalRevenue: 2500000,
      upcomingEvents: 3,
      responseRating: 4.8,
      responseTime: 15,
      cancellationRate: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with profile
          SliverAppBar(
            expandedHeight: 280,
            backgroundColor: const Color(0xFF0A0E27),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF667eea).withOpacity(0.8),
                      const Color(0xFF764ba2).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF667eea),
                                  Color(0xFF764ba2)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.business,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        organizerProfile.organizerName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (organizerProfile.isVerified)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[400],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.verified,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Verified',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildTrustIndicator(
                                  organizerProfile.averageRating,
                                  organizerProfile.totalReviews,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTrustBadge(organizerProfile),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (organizerProfile.profileDescription != null) ...[
                    Text(
                      'About',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      organizerProfile.profileDescription!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Trust & Credibility Section
                  _buildSection(
                    title: 'Trust & Credibility',
                    children: [
                      _buildTrustMetric(
                        icon: Icons.star,
                        label: 'Average Rating',
                        value: '${organizerProfile.averageRating}/5.0',
                        color: Colors.amber,
                        subtitle:
                            '${organizerProfile.totalReviews} reviews',
                      ),
                      _buildTrustMetric(
                        icon: Icons.event,
                        label: 'Events Hosted',
                        value: organizerProfile.totalEventsHosted.toString(),
                        color: const Color(0xFF667eea),
                      ),
                      _buildTrustMetric(
                        icon: Icons.people,
                        label: 'Total Attendees',
                        value: organizerProfile.totalAttendees.toString(),
                        color: Colors.green,
                      ),
                      _buildTrustMetric(
                        icon: Icons.verified_user,
                        label: 'Verification Status',
                        value: organizerProfile.verificationStatus
                            .toUpperCase(),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Business Performance
                  _buildSection(
                    title: 'Business Performance',
                    children: [
                      _buildTrustMetric(
                        icon: Icons.attach_money,
                        label: 'Total Revenue',
                        value:
                            'LKR ${organizerProfile.totalRevenue.toStringAsFixed(0)}',
                        color: Colors.teal,
                      ),
                      _buildTrustMetric(
                        icon: Icons.phone,
                        label: 'Response Time',
                        value: '${organizerProfile.responseTime} mins avg',
                        color: Colors.orange,
                      ),
                      _buildTrustMetric(
                        icon: Icons.trending_up,
                        label: 'Response Rating',
                        value: '${organizerProfile.responseRating}/5.0',
                        color: Colors.purple,
                      ),
                      _buildTrustMetric(
                        icon: Icons.warning,
                        label: 'Cancellation Rate',
                        value: '${organizerProfile.cancellationRate}%',
                        color: organizerProfile.cancellationRate < 5
                            ? Colors.green
                            : organizerProfile.cancellationRate < 10
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Contact & Location
                  _buildSection(
                    title: 'Contact Information',
                    children: [
                      _buildContactItem(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: organizerProfile.businessAddress,
                      ),
                      if (organizerProfile.phoneNumber != null)
                        _buildContactItem(
                          icon: Icons.phone,
                          label: 'Phone',
                          value: organizerProfile.phoneNumber!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Verification Info
                  if (organizerProfile.isVerified) ...[
                    _buildSection(
                      title: 'Verification Details',
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green[400],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Identity Verified',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Verified on ${_formatDate(organizerProfile.verificationDate!)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to event booking or details
                      },
                      child: Text(
                        'View Events by ${organizerProfile.organizerName}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0A0E27),
    );
  }

  Widget _buildTrustIndicator(double rating, int reviews) {
    return Row(
      children: [
        ...List.generate(
          5,
          (index) => Icon(
            index < rating.toInt() ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$rating ($reviews)',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadge(OrganizerProfileModel profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            profile.isTrustworthy
                ? Icons.verified
                : Icons.info_outline,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            profile.getTrustBadgeText(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...children.map(
          (child) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF667eea), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
