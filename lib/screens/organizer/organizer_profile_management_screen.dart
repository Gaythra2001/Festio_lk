import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../core/providers/auth_provider.dart';

class OrganizerProfileManagementScreen extends StatefulWidget {
  const OrganizerProfileManagementScreen({super.key});

  @override
  State<OrganizerProfileManagementScreen> createState() =>
      _OrganizerProfileManagementScreenState();
}

class _OrganizerProfileManagementScreenState
    extends State<OrganizerProfileManagementScreen> {
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

  String _businessType = 'solo';
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
    _uploadedImageUrl = user?.photoUrl;
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _businessRegController.dispose();
    _taxIdController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    super.dispose();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id;
      
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Upload image if selected
      final photoUrl = await _uploadImage();

      // Prepare update data
      final updateData = <String, dynamic>{
        'displayName': _businessNameController.text.trim(),
        'businessName': _businessNameController.text.trim(),
        'businessRegistration': _businessRegController.text.trim(),
        'businessAddress': _addressController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
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
      }
    } catch (e) {
      _showError('Failed to update profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _verifyPhone() async {
    // TODO: Implement Firebase Phone Auth
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(
          'Phone Verification',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Phone verification will be sent to: ${_phoneController.text}\n\nThis feature will be fully implemented with Firebase Phone Auth.',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: GoogleFonts.poppins(color: const Color(0xFF667eea)),
            ),
          ),
        ],
      ),
    );
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
        final ref = _storage.ref().child('verification_documents/$userId/$documentType.jpg');
        await ref.putFile(File(file.path));
        final url = await ref.getDownloadURL();

        // Update Firestore with document URL
        await _firestore.collection('users').doc(userId).update({
          'verificationDocumentUrl': url,
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
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
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
          'Manage Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A0E27),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              _buildProfileImageSection(),
              const SizedBox(height: 24),

              // Trust Metrics Overview (Read-only)
              _buildMetricsOverview(user),
              const SizedBox(height: 24),

              // Verification Status
              _buildVerificationStatus(user),
              const SizedBox(height: 24),

              // Business Information Section
              _buildSectionHeader('Business Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _businessNameController,
                label: 'Business Name',
                icon: Icons.business,
                enabled: _isEditing,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Business name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _descriptionController,
                label: 'Profile Description',
                icon: Icons.description,
                enabled: _isEditing,
                maxLines: 3,
                hint: 'Tell users about your business...',
              ),
              const SizedBox(height: 12),
              _buildBusinessTypeDropdown(),
              const SizedBox(height: 24),

              // Registration & Tax
              _buildSectionHeader('Registration & Tax'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _businessRegController,
                label: 'Business Registration Number',
                icon: Icons.verified_user,
                enabled: _isEditing,
                hint: 'REG123456',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _taxIdController,
                label: 'Tax ID (Optional)',
                icon: Icons.receipt_long,
                enabled: _isEditing,
                hint: 'TAX123456',
              ),
              const SizedBox(height: 24),

              // Contact Information
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addressController,
                label: 'Business Address',
                icon: Icons.location_on,
                enabled: _isEditing,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city,
                enabled: _isEditing,
                hint: 'Colombo',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                hint: '+94 70 123 4567',
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                    return 'Invalid phone number format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _websiteController,
                label: 'Website (Optional)',
                icon: Icons.language,
                enabled: _isEditing,
                keyboardType: TextInputType.url,
                hint: 'https://www.example.com',
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return 'Website must start with http:// or https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Verification Documents
              _buildSectionHeader('Verification Documents'),
              const SizedBox(height: 12),
              _buildDocumentUpload(),
              const SizedBox(height: 24),

              // Action Buttons
              if (_isEditing) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF1A1F3A),
                                    title: Text(
                                      'Discard Changes?',
                                      style: GoogleFonts.poppins(color: Colors.white),
                                    ),
                                    content: Text(
                                      'Are you sure you want to cancel? Any unsaved changes will be lost.',
                                      style: GoogleFonts.poppins(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Keep Editing',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF667eea),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() => _isEditing = false);
                                          _selectedImage = null;
                                          _loadUserData();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text(
                                          'Discard',
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF667eea),
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!) as ImageProvider
                : _uploadedImageUrl != null
                    ? NetworkImage(_uploadedImageUrl!)
                    : null,
            child: (_selectedImage == null && _uploadedImageUrl == null)
                ? Text(
                    context.read<AuthProvider>().user?.displayName?.substring(0, 1).toUpperCase() ?? 'O',
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: _isUploadingImage
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricsOverview(user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Your Trust Metrics',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  '${user?.averageRating.toStringAsFixed(1) ?? '0.0'}',
                  'Rating',
                  Icons.star,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  '${user?.totalEventsHosted ?? 0}',
                  'Events',
                  Icons.event,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  '${user?.totalReviews ?? 0}',
                  'Reviews',
                  Icons.rate_review,
                ),
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
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
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
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStatus(user) {
    final isVerified = user?.isVerified ?? false;
    final isPhoneVerified = user?.isPhoneVerified ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isVerified ? Icons.verified : Icons.pending,
                color: isVerified ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                isVerified ? 'Verified Organizer' : 'Verification Pending',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildVerificationItem(
            'Identity Verification',
            isVerified,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildVerificationItem(
                  'Phone Verification',
                  isPhoneVerified,
                ),
              ),
              if (!isPhoneVerified && _phoneController.text.isNotEmpty)
                TextButton(
                  onPressed: _verifyPhone,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF667eea),
                  ),
                  child: Text(
                    'Verify',
                    style: GoogleFonts.poppins(fontSize: 11),
                  ),
                ),
            ],
          ),
          _buildVerificationItem(
            'Email Verification',
            user?.isEmailVerified ?? false,
          ),
          if (!isVerified) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                // Navigate to verification screen
                _showVerificationDialog();
              },
              icon: const Icon(Icons.upload_file, size: 18),
              label: Text(
                'Upload Verification Documents',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF667eea),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationItem(String label, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.circle_outlined,
            color: isVerified ? Colors.green : Colors.white54,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
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
          Icon(Icons.business_center, color: const Color(0xFF667eea)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _businessType,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A1F3A),
                style: GoogleFonts.poppins(color: Colors.white),
                onChanged: _isEditing
                    ? (value) => setState(() => _businessType = value!)
                    : null,
                items: const [
                  DropdownMenuItem(
                    value: 'solo',
                    child: Text('Solo Organizer'),
                  ),
                  DropdownMenuItem(
                    value: 'company',
                    child: Text('Company'),
                  ),
                  DropdownMenuItem(
                    value: 'npo',
                    child: Text('Non-Profit Organization'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUpload() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload documents to verify your identity',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          _buildDocumentItem(
            'Business Registration Certificate',
            Icons.description,
            false,
          ),
          _buildDocumentItem(
            'National ID / Passport',
            Icons.badge,
            false,
          ),
          _buildDocumentItem(
            'Proof of Address',
            Icons.home,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String label, IconData icon, bool uploaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: uploaded ? Colors.green : Colors.white54,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ),
          if (_isEditing)
            TextButton.icon(
              onPressed: () => _uploadDocument(label),
              icon: Icon(
                uploaded ? Icons.check_circle : Icons.upload_file,
                size: 16,
              ),
              label: Text(
                uploaded ? 'Uploaded' : 'Upload',
                style: GoogleFonts.poppins(fontSize: 11),
              ),
              style: TextButton.styleFrom(
                foregroundColor:
                    uploaded ? Colors.green : const Color(0xFF667eea),
              ),
            ),
        ],
      ),
    );
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(
          'Verification Process',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To get verified, you need to:',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _buildDialogStep('1', 'Upload Business Registration'),
            _buildDialogStep('2', 'Upload National ID/Passport'),
            _buildDialogStep('3', 'Verify Phone Number'),
            _buildDialogStep('4', 'Verify Email Address'),
            const SizedBox(height: 12),
            Text(
              'Verification typically takes 2-3 business days.',
              style: GoogleFonts.poppins(
                color: Colors.amber,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: GoogleFonts.poppins(color: const Color(0xFF667eea)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

}
