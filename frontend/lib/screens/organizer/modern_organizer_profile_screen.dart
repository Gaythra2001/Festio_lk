import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../core/providers/auth_provider.dart';

class ModernOrganizerProfileScreen extends StatefulWidget {
  const ModernOrganizerProfileScreen({super.key});

  @override
  State<ModernOrganizerProfileScreen> createState() =>
      _ModernOrganizerProfileScreenState();
}

class _ModernOrganizerProfileScreenState
    extends State<ModernOrganizerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  File? _selectedImage;
  String? _uploadedImageUrl;

  // Form controllers
  late TextEditingController _businessNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _businessRegController;
  late TextEditingController _taxIdController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _emailController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;

  String _businessType = 'solo';
  String _country = 'Sri Lanka';
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _imagePicker = ImagePicker();

  // Track profile completion
  double _profileCompletion = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _businessNameController.dispose();
    _descriptionController.dispose();
    _businessRegController.dispose();
    _taxIdController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    _businessNameController =
        TextEditingController(text: user?.businessName ?? user?.displayName ?? '');
    _descriptionController = TextEditingController(text: '');
    _businessRegController =
        TextEditingController(text: user?.businessRegistration ?? '');
    _taxIdController = TextEditingController();
    _addressController =
        TextEditingController(text: user?.businessAddress ?? '');
    _cityController = TextEditingController();
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _websiteController = TextEditingController();
    _emailController = TextEditingController(text: user?.email ?? '');
    _facebookController = TextEditingController();
    _instagramController = TextEditingController();
    _twitterController = TextEditingController();
    _uploadedImageUrl = user?.photoUrl;

    _calculateProfileCompletion();
  }

  void _calculateProfileCompletion() {
    int completedFields = 0;
    int totalFields = 10;

    if (_businessNameController.text.isNotEmpty) completedFields++;
    if (_descriptionController.text.isNotEmpty) completedFields++;
    if (_businessRegController.text.isNotEmpty) completedFields++;
    if (_addressController.text.isNotEmpty) completedFields++;
    if (_cityController.text.isNotEmpty) completedFields++;
    if (_phoneController.text.isNotEmpty) completedFields++;
    if (_emailController.text.isNotEmpty) completedFields++;
    if (_uploadedImageUrl != null) completedFields++;
    if (_websiteController.text.isNotEmpty) completedFields++;
    if (_facebookController.text.isNotEmpty ||
        _instagramController.text.isNotEmpty ||
        _twitterController.text.isNotEmpty) completedFields++;

    setState(() {
      _profileCompletion = completedFields / totalFields;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _calculateProfileCompletion();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _uploadedImageUrl;

    setState(() => _isUploadingImage = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id;
      if (userId == null) return null;

      final ref = _storage.ref().child('organizer_profiles/$userId.jpg');
      await ref.putFile(_selectedImage!);
      final url = await ref.getDownloadURL();

      setState(() => _uploadedImageUrl = url);
      return url;
    } catch (e) {
      _showError('Failed to upload image: $e');
      return null;
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Please fill in all required fields');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Upload image if selected
      final photoUrl = await _uploadImage();

      // Prepare social media JSON
      final socialMediaUrls = {
        if (_facebookController.text.isNotEmpty)
          'facebook': _facebookController.text,
        if (_instagramController.text.isNotEmpty)
          'instagram': _instagramController.text,
        if (_twitterController.text.isNotEmpty)
          'twitter': _twitterController.text,
      };

      // Prepare update data
      final updateData = <String, dynamic>{
        'displayName': _businessNameController.text.trim(),
        'businessName': _businessNameController.text.trim(),
        'profileDescription': _descriptionController.text.trim(),
        'businessType': _businessType,
        'businessRegistration': _businessRegController.text.trim(),
        'taxId': _taxIdController.text.trim(),
        'businessAddress': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _country,
        'phoneNumber': _phoneController.text.trim(),
        'websiteUrl': _websiteController.text.trim(),
        'socialMediaUrls': socialMediaUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      // Save to Firestore
      await _firestore.collection('users').doc(userId).update(updateData);

      if (mounted) {
        _showSuccess('Profile updated successfully!');
        setState(() {
          _isEditing = false;
          _selectedImage = null;
        });
        _calculateProfileCompletion();
      }
    } catch (e) {
      _showError('Failed to update profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _uploadDocument(String documentType) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (file != null) {
        setState(() => _isSaving = true);

        final authProvider = context.read<AuthProvider>();
        final userId = authProvider.user?.id;

        if (userId == null) throw Exception('User not logged in');

        // Upload to Firebase Storage
        final ref = _storage
            .ref()
            .child('verification_documents/$userId/$documentType.jpg');
        await ref.putFile(File(file.path));
        final url = await ref.getDownloadURL();

        // Update Firestore with document URL
        await _firestore.collection('users').doc(userId).update({
          'verificationDocuments': FieldValue.arrayUnion([
            {'type': documentType, 'url': url}
          ]),
          'verificationStatus': 'pending',
        });

        _showSuccess('Document uploaded successfully! Verification pending.');
      }
    } catch (e) {
      _showError('Failed to upload document: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: GoogleFonts.poppins()),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: GoogleFonts.poppins()),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(
          'Organizer Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A0E27),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            )
          else
            Row(
              children: [
                TextButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save, size: 20),
                  label: Text(
                    'Save',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _selectedImage = null;
                    });
                    _loadUserData();
                  },
                  tooltip: 'Cancel',
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF667eea),
          labelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Business'),
            Tab(text: 'Contact'),
            Tab(text: 'Verify'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Profile Completion Banner
          _buildProfileCompletionBanner(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(user),
                _buildBusinessTab(),
                _buildContactTab(),
                _buildVerificationTab(user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionBanner() {
    final percentage = (_profileCompletion * 100).toInt();
    final isComplete = percentage == 100;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isComplete
            ? const LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
              )
            : LinearGradient(
                colors: [
                  const Color(0xFF667eea).withOpacity(0.3),
                  const Color(0xFF764ba2).withOpacity(0.3),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? Colors.green : const Color(0xFF667eea),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle : Icons.trending_up,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete
                          ? 'Profile Complete! 🎉'
                          : 'Complete Your Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isComplete
                          ? 'You\'re all set to host amazing events!'
                          : 'Fill in all fields to unlock full features',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _profileCompletion,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? Colors.white : const Color(0xFF667eea),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Image
          _buildProfileImageSection(),
          const SizedBox(height: 24),

          // Trust Metrics
          _buildTrustMetricsCard(user),
          const SizedBox(height: 16),

          // Quick Stats
          _buildQuickStatsGrid(user),
          const SizedBox(height: 16),

          // Recent Activity
          _buildRecentActivityCard(user),
        ],
      ),
    );
  }

  Widget _buildBusinessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Basic Information', Icons.business),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _businessNameController,
              label: 'Business Name *',
              icon: Icons.business,
              enabled: _isEditing,
              hint: 'e.g., Colombo Events Co.',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Business name is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Business Description',
              icon: Icons.description,
              enabled: _isEditing,
              maxLines: 4,
              hint:
                  'Describe your business, what makes you unique, and your event expertise...',
            ),
            const SizedBox(height: 16),
            _buildBusinessTypeDropdown(),
            const SizedBox(height: 24),
            _buildSectionHeader('Registration Details', Icons.verified_user),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _businessRegController,
              label: 'Business Registration Number',
              icon: Icons.numbers,
              enabled: _isEditing,
              hint: 'REG123456789',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _taxIdController,
              label: 'Tax ID / VAT Number (Optional)',
              icon: Icons.receipt_long,
              enabled: _isEditing,
              hint: 'TAX987654321',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Having verified registration details builds trust with event attendees and increases bookings.',
              Icons.info_outline,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Address', Icons.location_on),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Business Address *',
            icon: Icons.home_work,
            enabled: _isEditing,
            hint: '123 Main Street, Building 5',
            validator: (value) =>
                value?.isEmpty ?? true ? 'Address is required' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cityController,
            label: 'City *',
            icon: Icons.location_city,
            enabled: _isEditing,
            hint: 'Colombo',
          ),
          const SizedBox(height: 16),
          _buildCountryDropdown(),
          const SizedBox(height: 24),
          _buildSectionHeader('Contact Details', Icons.phone),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number *',
            icon: Icons.phone,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
            hint: '+94 70 123 4567',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                return 'Invalid phone number format';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email,
            enabled: false, // Email shouldn't be editable here
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Online Presence', Icons.language),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _websiteController,
            label: 'Website URL',
            icon: Icons.public,
            enabled: _isEditing,
            keyboardType: TextInputType.url,
            hint: 'https://www.yourwebsite.com',
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              if (!value.startsWith('http://') &&
                  !value.startsWith('https://')) {
                return 'URL must start with http:// or https://';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _facebookController,
            label: 'Facebook Page',
            icon: Icons.facebook,
            enabled: _isEditing,
            hint: 'https://facebook.com/yourpage',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _instagramController,
            label: 'Instagram Profile',
            icon: Icons.camera_alt,
            enabled: _isEditing,
            hint: 'https://instagram.com/yourprofile',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _twitterController,
            label: 'Twitter/X Profile',
            icon: Icons.alternate_email,
            enabled: _isEditing,
            hint: 'https://twitter.com/yourhandle',
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationTab(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVerificationStatusCard(user),
          const SizedBox(height: 24),
          _buildSectionHeader('Verification Checklist', Icons.checklist),
          const SizedBox(height: 16),
          _buildVerificationChecklist(user),
          const SizedBox(height: 24),
          _buildSectionHeader('Upload Documents', Icons.upload_file),
          const SizedBox(height: 16),
          _buildDocumentUploadSection(),
          const SizedBox(height: 24),
          _buildVerificationBenefitsCard(),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: const Color(0xFF667eea),
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!) as ImageProvider
                  : _uploadedImageUrl != null
                      ? NetworkImage(_uploadedImageUrl!)
                      : null,
              child: (_selectedImage == null && _uploadedImageUrl == null)
                  ? Text(
                      context
                              .read<AuthProvider>()
                              .user
                              ?.displayName
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          'O',
                      style: GoogleFonts.poppins(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _isUploadingImage
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.camera_alt,
                          color: Colors.white, size: 22),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrustMetricsCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Performance',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                '${user?.averageRating.toStringAsFixed(1) ?? '0.0'}',
                'Rating',
                Icons.star,
              ),
              _buildDivider(),
              _buildMetricItem(
                '${user?.totalEventsHosted ?? 0}',
                'Events',
                Icons.event,
              ),
              _buildDivider(),
              _buildMetricItem(
                '${user?.totalReviews ?? 0}',
                'Reviews',
                Icons.rate_review,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.white24,
    );
  }

  Widget _buildQuickStatsGrid(user) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Attendees',
          '${user?.totalAttendees ?? 0}',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Upcoming Events',
          '${user?.upcomingEvents ?? 0}',
          Icons.upcoming,
          Colors.orange,
        ),
        _buildStatCard(
          'Tickets Sold',
          '${user?.totalTicketsSold ?? 0}',
          Icons.confirmation_number,
          Colors.green,
        ),
        _buildStatCard(
          'Response Time',
          '${user?.responseTime ?? 0}h',
          Icons.timer,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Color(0xFF667eea)),
              const SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Profile Updated',
            'Last updated on ${DateTime.now().toString().split(' ')[0]}',
            Icons.edit,
          ),
          _buildActivityItem(
            'Events Created',
            '${user?.totalEventsHosted ?? 0} events',
            Icons.add_circle,
          ),
          _buildActivityItem(
            'Member Since',
            user?.createdAt?.toString().split(' ')[0] ?? 'N/A',
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF667eea), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatusCard(user) {
    final isVerified = user?.isVerified ?? false;
    final isPhoneVerified = user?.isPhoneVerified ?? false;
    final verificationStatus = user?.verificationStatus ?? 'unverified';

    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    switch (verificationStatus) {
      case 'verified':
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        statusText = 'Verified Organizer';
        statusDescription =
            'Your account is verified. You have full access to all features.';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Verification Pending';
        statusDescription =
            'We\'re reviewing your documents. This usually takes 2-3 business days.';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Verification Rejected';
        statusDescription =
            'Please review the feedback and resubmit your documents.';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info_outline;
        statusText = 'Not Verified';
        statusDescription =
            'Complete the verification process to gain user trust and unlock features.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      statusDescription,
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
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusBadge(
                'Identity',
                isVerified,
                Icons.badge,
              ),
              _buildStatusBadge(
                'Phone',
                isPhoneVerified,
                Icons.phone,
              ),
              _buildStatusBadge(
                'Email',
                user?.isEmailVerified ?? false,
                Icons.email,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, bool isVerified, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isVerified
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isVerified ? Colors.green : Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
        Text(
          isVerified ? 'Verified' : 'Pending',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: isVerified ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationChecklist(user) {
    final items = [
      {
        'title': 'Upload Business Registration',
        'completed': false,
        'required': true
      },
      {'title': 'Upload ID/Passport', 'completed': false, 'required': true},
      {
        'title': 'Verify Phone Number',
        'completed': user?.isPhoneVerified ?? false,
        'required': true
      },
      {
        'title': 'Verify Email Address',
        'completed': user?.isEmailVerified ?? false,
        'required': true
      },
      {
        'title': 'Add Business Address',
        'completed': _addressController.text.isNotEmpty,
        'required': true
      },
      {
        'title': 'Upload Profile Photo',
        'completed': _uploadedImageUrl != null,
        'required': false
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items.map((item) {
          return _buildChecklistItem(
            item['title'] as String,
            item['completed'] as bool,
            item['required'] as bool,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChecklistItem(String title, bool completed, bool required) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            color: completed ? Colors.green : Colors.white38,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: completed ? Colors.white : Colors.white70,
                decoration:
                    completed ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
          if (required)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Required',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadSection() {
    final documents = [
      {
        'title': 'Business Registration Certificate',
        'icon': Icons.description,
        'type': 'business_reg'
      },
      {
        'title': 'National ID or Passport',
        'icon': Icons.badge,
        'type': 'national_id'
      },
      {'title': 'Proof of Address', 'icon': Icons.home, 'type': 'address_proof'},
      {
        'title': 'Tax Registration (Optional)',
        'icon': Icons.receipt,
        'type': 'tax_cert'
      },
    ];

    return Column(
      children: documents.map((doc) {
        return _buildDocumentUploadCard(
          doc['title'] as String,
          doc['icon'] as IconData,
          doc['type'] as String,
        );
      }).toList(),
    );
  }

  Widget _buildDocumentUploadCard(String title, IconData icon, String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              color: const Color(0xFF667eea).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF667eea), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'PDF, JPG, or PNG (Max 5MB)',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _uploadDocument(type),
            icon: const Icon(Icons.upload_file, size: 16),
            label: Text(
              'Upload',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium,
                  color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Benefits of Verification',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBenefitItem('✓ Verified badge on your profile'),
          _buildBenefitItem('✓ Higher visibility in search results'),
          _buildBenefitItem('✓ Increased trust from event attendees'),
          _buildBenefitItem('✓ Priority customer support'),
          _buildBenefitItem('✓ Access to premium features'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF667eea), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.white),
      validator: validator,
      onChanged: (_) => _calculateProfileCompletion(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
        filled: true,
        fillColor: enabled
            ? const Color(0xFF1A1F3A)
            : const Color(0xFF1A1F3A).withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        hintStyle: GoogleFonts.poppins(color: Colors.white38),
      ),
    );
  }

  Widget _buildBusinessTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _isEditing
            ? const Color(0xFF1A1F3A)
            : const Color(0xFF1A1F3A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.business_center, color: Color(0xFF667eea)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _businessType,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A1F3A),
                style: GoogleFonts.poppins(color: Colors.white),
                onChanged: _isEditing
                    ? (value) {
                        setState(() => _businessType = value!);
                        _calculateProfileCompletion();
                      }
                    : null,
                items: [
                  DropdownMenuItem(
                    value: 'solo',
                    child: Text('Solo Organizer',
                        style: GoogleFonts.poppins()),
                  ),
                  DropdownMenuItem(
                    value: 'company',
                    child: Text('Company', style: GoogleFonts.poppins()),
                  ),
                  DropdownMenuItem(
                    value: 'npo',
                    child: Text('Non-Profit Organization',
                        style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _isEditing
            ? const Color(0xFF1A1F3A)
            : const Color(0xFF1A1F3A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: Color(0xFF667eea)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _country,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A1F3A),
                style: GoogleFonts.poppins(color: Colors.white),
                onChanged: _isEditing
                    ? (value) => setState(() => _country = value!)
                    : null,
                items: [
                  DropdownMenuItem(
                    value: 'Sri Lanka',
                    child: Text('Sri Lanka', style: GoogleFonts.poppins()),
                  ),
                  DropdownMenuItem(
                    value: 'India',
                    child: Text('India', style: GoogleFonts.poppins()),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String message, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
