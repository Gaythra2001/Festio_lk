import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_data_provider.dart';
import '../../core/models/user_model.dart';
import 'modern_login_screen.dart';

class ModernRegistrationScreen extends StatefulWidget {
  const ModernRegistrationScreen({super.key});

  @override
  State<ModernRegistrationScreen> createState() =>
      _ModernRegistrationScreenState();
}

class _ModernRegistrationScreenState extends State<ModernRegistrationScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nicPassportController = TextEditingController();
  final _countryController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  String _verificationMethod = 'Email'; // Email or SMS
  UserType _selectedUserType = UserType.user;

  Future<void> _handleRegistration() async {
    // Validation
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _nicPassportController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('all_fields_required'.tr())),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms and conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Register user in provider
        Provider.of<UserDataProvider>(context, listen: false).registerUser(
          email: _emailController.text,
          fullName: '${_firstNameController.text} ${_lastNameController.text}',
          phone: _phoneController.text,
          location: _countryController.text,
          userType: _selectedUserType,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedUserType == UserType.organizer
                ? 'Organizer account created! Please login.'
                : 'User account created! Please login.'),
          ),
        );

        // Navigate back to login
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ModernLoginScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nicPassportController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
                  const SizedBox(height: 20),
                  // Professional Logo/Branding
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(18),
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
                      size: 35,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Brand name
                  Text(
                    'Festio LK',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Tagline
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // User Type Selection
                  Text(
                    'I am registering as:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildUserTypeCard(
                          type: UserType.user,
                          icon: Icons.event_seat,
                          title: 'Event Attendee',
                          description: 'Discover & attend events',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildUserTypeCard(
                          type: UserType.organizer,
                          icon: Icons.business_center,
                          title: 'Event Organizer',
                          description: 'Create & manage events',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // First Name Field
                  _buildTextField(
                    controller: _firstNameController,
                    hintText: 'John',
                    label: '*First Name',
                    prefixIcon: Icons.person_outline,
                  ),

                  const SizedBox(height: 16),

                  // Last Name Field
                  _buildTextField(
                    controller: _lastNameController,
                    hintText: 'Doe',
                    label: '*Last Name',
                    prefixIcon: Icons.person_outline,
                  ),

                  const SizedBox(height: 16),

                  // Contact Number Field
                  _buildTextField(
                    controller: _phoneController,
                    hintText: '+94 (70) 123 4567',
                    label: '*Contact Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),

                  // NIC/Passport Field
                  _buildTextField(
                    controller: _nicPassportController,
                    hintText: '123456789V or A12345678',
                    label: '*NIC/Passport',
                    prefixIcon: Icons.card_giftcard_outlined,
                  ),

                  const SizedBox(height: 16),

                  // Country Field
                  _buildTextField(
                    controller: _countryController,
                    hintText: 'Sri Lanka',
                    label: '*Country',
                    prefixIcon: Icons.public_outlined,
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'john@example.com',
                    label: '*Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // Verification Method
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '*Verification Method',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<String>(
                            value: _verificationMethod,
                            isExpanded: true,
                            underline: const SizedBox(),
                            dropdownColor: const Color(0xFF1A1F3A),
                            items: ['Email', 'SMS']
                                .map((method) => DropdownMenuItem(
                                      value: method,
                                      child: Text(
                                        method,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _verificationMethod = value ?? 'Email';
                              });
                            },
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    hintText: '••••••••',
                    label: '*Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: '••••••••',
                    label: '*Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Terms and Conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() => _agreeToTerms = value ?? false);
                        },
                        fillColor: MaterialStateProperty.all(
                          _agreeToTerms
                              ? const Color(0xFF667eea)
                              : Colors.white.withOpacity(0.2),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'I agree to Terms & Conditions',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        disabledBackgroundColor:
                            const Color(0xFF667eea).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Create Account',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

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
                                builder: (_) => const ModernLoginScreen()),
                          );
                        },
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF667eea),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 15,
              ),
              prefixIcon: Icon(prefixIcon, color: Colors.white70, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeCard({
    required UserType type,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedUserType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667eea).withOpacity(0.2)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF667eea)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? const Color(0xFF667eea) : Colors.white70,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
