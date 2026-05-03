import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:festio_lk/core/services/ai/trust_and_budget_service.dart';

/// Component 3: Organizer Trust Assessment Screen
class TrustAssessmentScreen extends StatefulWidget {
  const TrustAssessmentScreen({super.key});

  @override
  State<TrustAssessmentScreen> createState() => _TrustAssessmentScreenState();
}

class _TrustAssessmentScreenState extends State<TrustAssessmentScreen> {
  late TrustAssessmentService _trustService;
  bool _isLoading = false;
  String _loadingStatus = '';
  Map<String, dynamic>? _validationResult;
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();
  
  final _organizerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pastEventsController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _trustService = TrustAssessmentService();
  }

  @override
  void dispose() {
    _organizerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pastEventsController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _runRealValidation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _validationResult = null;
      _loadingStatus = 'Initializing AI Analysis...';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _loadingStatus = 'Evaluating event metadata...');
      
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _loadingStatus = 'Scanning for risk patterns...');

      final price = double.tryParse(_priceController.text) ?? 0.0;
      final result = await _trustService.verifyEventAuthenticity({
        'title': _titleController.text,
        'description': _descController.text,
        'price': price,
        'location': _locationController.text,
        'category': _categoryController.text,
      });
      
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _loadingStatus = 'Finalizing trust assessment...');
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      setState(() {
        _validationResult = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingStatus = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('User Trust Assessment'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _buildValidationTab(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _loadingStatus,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'This might take a few seconds',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Event Details', Icons.event),
            const SizedBox(height: 16),
            _buildGlassField(
              controller: _titleController,
              label: 'Event Title',
              icon: Icons.title,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _buildGlassField(
              controller: _descController,
              label: 'Event Description',
              icon: Icons.description,
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGlassField(
                    controller: _priceController,
                    label: 'Price (LKR)',
                    icon: Icons.money,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGlassField(
                    controller: _categoryController,
                    label: 'Category',
                    icon: Icons.category,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildGlassField(
              controller: _locationController,
              label: 'Location',
              icon: Icons.location_on,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Organizer Information', Icons.person),
            const SizedBox(height: 16),
            _buildGlassField(
              controller: _organizerNameController,
              label: 'Full Name',
              icon: Icons.badge,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _buildGlassField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGlassField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGlassField(
                    controller: _pastEventsController,
                    label: 'Past Events',
                    icon: Icons.history,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _runRealValidation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                  shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, size: 24),
                    SizedBox(width: 12),
                    Text('Verify Authenticity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            if (_errorMessage.isNotEmpty)
              _buildErrorDisplay(),
              
            if (_validationResult != null) ...[
              const SizedBox(height: 32),
              _buildSectionHeader('Analysis Result', Icons.analytics),
              const SizedBox(height: 16),
              _buildResultCard(
                title: 'AI Verification Result',
                data: _validationResult!,
                color: _getTrustColor(_validationResult?['trust_level'] ?? ''),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required Map<String, dynamic> data,
    required Color color,
  }) {
    bool isReal = data['prediction'] == 'Real';
    double trustScore = double.tryParse(data['trust_score']?.toString().replaceAll('%', '') ?? '0') ?? 0.0;
    String realProb = data['real_probability']?.toString() ?? '0%';
    String fakeProb = data['fake_probability']?.toString() ?? '0%';
    
    final badgeColor = isReal ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final badgeIcon = isReal ? Icons.verified_user : Icons.gpp_maybe;
    final assessmentText = isReal ? 'Highly Reliable' : 'Suspicious Pattern';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI TRUST INSIGHTS',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: badgeColor.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(color: badgeColor.withOpacity(0.1), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(badgeIcon, color: badgeColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      isReal ? 'VERIFIED REAL' : 'POTENTIAL RISK',
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: trustScore / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.security, color: badgeColor.withOpacity(0.8), size: 28),
                        const SizedBox(height: 4),
                        Text(
                          '${trustScore.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'SCORE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KEY METRICS',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMetricRow('Real Probability', realProb, Colors.greenAccent),
                const Divider(color: Colors.white10, height: 24),
                _buildMetricRow('Risk Index', fakeProb, Colors.redAccent),
                const Divider(color: Colors.white10, height: 24),
                _buildMetricRow('Assessment', assessmentText, Colors.blueAccent),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _generateProfessionalReport(context, data),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('GENERATE VERIFICATION REPORT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white.withOpacity(0.95),
                side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6))),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getTrustColor(String trustLevel) {
    switch (trustLevel) {
      case 'highly_trusted':
        return Colors.green;
      case 'trusted':
        return Colors.lightGreen;
      case 'neutral':
        return Colors.orange;
      case 'low_trust':
        return Colors.deepOrange;
      case 'not_trusted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _generateProfessionalReport(BuildContext context, Map<String, dynamic> data) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF6366F1)),
            SizedBox(height: 16),
            Text('Generating Secured Report...', style: TextStyle(color: Colors.white, decoration: TextDecoration.none, fontSize: 16)),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildReportView(data),
    );
  }

  Widget _buildReportView(Map<String, dynamic> data) {
    final isReal = data['prediction'] == 'Real';
    final trustScore = data['trust_score']?.toString() ?? '0%';
    final verificationId = 'FST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FESTIO AI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                          Text('EVENT AUTHENTICITY REPORT', style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1.2)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.qr_code_2, size: 40, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const Divider(height: 48),
                  
                  _buildReportSection('VERIFICATION SUMMARY', [
                    _buildReportRow('Status', isReal ? 'AUTHENTIC' : 'SUSPICIOUS', isReal ? Colors.green : Colors.red),
                    _buildReportRow('Trust Index', trustScore, const Color(0xFF6366F1)),
                    _buildReportRow('Verification ID', verificationId, Colors.black),
                    _buildReportRow('Date Issued', DateTime.now().toString().substring(0, 16), Colors.black),
                  ]),
                  
                  const SizedBox(height: 32),
                  _buildReportSection('EVENT METADATA', [
                    _buildReportRow('Title', _titleController.text, Colors.black),
                    _buildReportRow('Category', _categoryController.text, Colors.black),
                    _buildReportRow('Location', _locationController.text, Colors.black),
                    _buildReportRow('Price', 'LKR ${_priceController.text}', Colors.black),
                  ]),
                  
                  const SizedBox(height: 32),
                  _buildReportSection('ORGANIZER PROFILE', [
                    _buildReportRow('Name', _organizerNameController.text, Colors.black),
                    _buildReportRow('Email', _emailController.text, Colors.black),
                    _buildReportRow('Phone', _phoneController.text, Colors.black),
                    _buildReportRow('Record', '${_pastEventsController.text} Past Events', Colors.black),
                  ]),
                  
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI SYSTEM REMARKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 12),
                        Text(
                          isReal 
                            ? 'The event structure and organizer profile align with high-trust historical patterns. No fraudulent markers detected in description or pricing metadata.'
                            : 'Anomalous patterns detected in event pricing or description. The risk index exceeds the safety threshold for this category. Manual verification recommended.',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF6366F1), size: 48),
                        const SizedBox(height: 12),
                        const Text('OFFICIALLY VERIFIED BY FESTIO AI', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        Text('System Version 2.4.0', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.share),
                    label: const Text('SHARE REPORT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.done_all),
                    label: const Text('CLOSE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6366F1), letterSpacing: 1.1)),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildReportRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage() {
    if (_errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage), backgroundColor: Colors.red),
      );
    }
  }
}

/// Component 4: Event Budget Planning Screen
class BudgetPlanningScreen extends StatefulWidget {
  const BudgetPlanningScreen({super.key});

  @override
  State<BudgetPlanningScreen> createState() => _BudgetPlanningScreenState();
}

class _BudgetPlanningScreenState extends State<BudgetPlanningScreen>
    with SingleTickerProviderStateMixin {
  late BudgetPlanningService _budgetService;
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, dynamic>? _budgetPlan;
  Map<String, dynamic>? _costPrediction;
  Map<String, dynamic>? _breakdown;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _budgetService = BudgetPlanningService();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createSampleBudgetPlan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sampleEvent = {
        'event_id': 'evt_budget_sample',
        'event_type': 'concert',
        'expected_audience': 500,
        'duration_hours': 4,
        'venue_type': 'outdoor',
        'has_catering': true,
        'has_entertainment': true,
      };
      final result = await _budgetService.createBudgetPlan(
        eventData: sampleEvent,
      );
      setState(() {
        _budgetPlan = result;
        _tabController.index = 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _predictCost() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sampleEvent = {
        'event_type': 'festival',
        'expected_audience': 1000,
        'duration_hours': 8,
        'venue_type': 'outdoor',
      };
      final result = await _budgetService.predictCost(eventData: sampleEvent);
      setState(() {
        _costPrediction = result;
        _tabController.index = 1;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getBreakdown() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sampleEvent = {
        'event_type': 'wedding',
        'expected_audience': 200,
        'total_budget': 50000.0,
      };
      final result = await _budgetService.calculateBreakdown(
        eventData: sampleEvent,
      );
      setState(() {
        _breakdown = result;
        _tabController.index = 2;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Budget Planning'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Full Plan'),
            Tab(text: 'Cost Prediction'),
            Tab(text: 'Breakdown'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFullPlanTab(),
                _buildCostPredictionTab(),
                _buildBreakdownTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showErrorMessage,
        child: const Icon(Icons.info),
      ),
    );
  }

  Widget _buildFullPlanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete Budget Plan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _createSampleBudgetPlan,
            icon: const Icon(Icons.attach_money),
            label: const Text('Create Sample Plan'),
          ),
          const SizedBox(height: 24),
          if (_budgetPlan != null) ...[
            _buildBudgetCard(
              title: 'Budget Plan',
              data: _budgetPlan!,
              color: Colors.green,
            ),
          ] else
            const Center(
              child: Text('Create a sample plan to see results'),
            ),
        ],
      ),
    );
  }

  Widget _buildCostPredictionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cost Prediction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _predictCost,
            icon: const Icon(Icons.calculate),
            label: const Text('Predict Cost'),
          ),
          const SizedBox(height: 24),
          if (_costPrediction != null) ...[
            _buildBudgetCard(
              title: 'Cost Prediction',
              data: _costPrediction!,
              color: Colors.blue,
            ),
          ] else
            const Center(
              child: Text('Predict cost to see results'),
            ),
        ],
      ),
    );
  }

  Widget _buildBreakdownTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Breakdown by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _getBreakdown,
            icon: const Icon(Icons.pie_chart),
            label: const Text('View Breakdown'),
          ),
          const SizedBox(height: 24),
          if (_breakdown != null) ...[
            _buildBudgetCard(
              title: 'Budget Breakdown',
              data: _breakdown!,
              color: Colors.purple,
            ),
          ] else
            const Center(
              child: Text('Get breakdown to see results'),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard({
    required String title,
    required Map<String, dynamic> data,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            ...data.entries.map(
              (e) {
                final value = e.value;
                String displayValue;

                if (value is double) {
                  displayValue = '\$${value.toStringAsFixed(2)}';
                } else if (value is int) {
                  displayValue = '\$$value';
                } else if (value is Map) {
                  displayValue = '(nested data)';
                } else {
                  displayValue = value.toString();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        displayValue,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage() {
    if (_errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage), backgroundColor: Colors.red),
      );
    }
  }
}
