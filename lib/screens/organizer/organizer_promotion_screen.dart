import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/promotion_provider.dart';
import '../../core/providers/event_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/models/promotion_model.dart';
import '../../core/models/event_model.dart';

class OrganizerPromotionScreen extends StatefulWidget {
  final String? initialEventId;
  const OrganizerPromotionScreen({super.key, this.initialEventId});

  @override
  State<OrganizerPromotionScreen> createState() =>
      _OrganizerPromotionScreenState();
}

class _OrganizerPromotionScreenState extends State<OrganizerPromotionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _langController;
  String _selectedEventId = '';
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 7));
  final _title = {'en': '', 'si': '', 'ta': ''};
  final _message = {'en': '', 'si': '', 'ta': ''};
  String? _imageUrl;
  String _iconKey = 'campaign';
  bool _isPaidPromotion = false;
  String _selectedTier = 'basic';
  final Map<String, Map<String, dynamic>> _promotionTiers = {
    'basic': {
      'name': 'Basic',
      'price': 1500.0,
      'duration': 3,
      'features': [
        '3 days promotion',
        'Standard visibility',
        'Email notification'
      ],
      'color': Color(0xFF4CAF50),
    },
    'standard': {
      'name': 'Standard',
      'price': 3500.0,
      'duration': 7,
      'features': [
        '7 days promotion',
        'Enhanced visibility',
        'Email + Push notifications',
        'Featured badge'
      ],
      'color': Color(0xFF2196F3),
    },
    'premium': {
      'name': 'Premium',
      'price': 7000.0,
      'duration': 14,
      'features': [
        '14 days promotion',
        'Maximum visibility',
        'All notification channels',
        'Featured badge',
        'Homepage spotlight',
        'Priority support'
      ],
      'color': Color(0xFFFF9800),
    },
  };

  @override
  void initState() {
    super.initState();
    _langController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      context.read<PromotionProvider>().load();
      if (widget.initialEventId != null && widget.initialEventId!.isNotEmpty) {
        setState(() {
          _selectedEventId = widget.initialEventId!;
        });
      }
    });
  }

  @override
  void dispose() {
    _langController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final events = eventProvider.upcomingEvents;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Promote Event',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Promotion Type'),
            const SizedBox(height: 8),
            _buildPromotionTypeSelector(),
            const SizedBox(height: 16),
            if (_isPaidPromotion) ...[
              _buildSectionTitle('Select Promotion Package'),
              const SizedBox(height: 8),
              _buildPromotionTiers(),
              const SizedBox(height: 16),
            ],
            _buildSectionTitle('Choose Event'),
            const SizedBox(height: 8),
            _buildEventDropdown(events),
            const SizedBox(height: 12),
            if (events.isNotEmpty) _buildSuggestions(events),
            const SizedBox(height: 16),
            _buildSectionTitle('Languages'),
            const SizedBox(height: 8),
            _buildLanguageTabs(),
            const SizedBox(height: 16),
            _buildSectionTitle('Schedule'),
            const SizedBox(height: 8),
            _buildSchedule(),
            const SizedBox(height: 16),
            _buildSectionTitle('Image URL (optional)'),
            const SizedBox(height: 8),
            _buildImageField(),
            const SizedBox(height: 16),
            _buildSectionTitle('Promotion Icon'),
            const SizedBox(height: 8),
            _buildIconSelector(),
            const SizedBox(height: 16),
            _buildSectionTitle('Notification Preview'),
            const SizedBox(height: 8),
            _buildNotificationPreview(events),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveDraft,
                    style: _btnStyle(Colors.white, const Color(0xFF667eea)),
                    child: Text('Save Draft',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _publish,
                    style: _btnStyle(const Color(0xFF667eea), Colors.white),
                    child: Text('Publish',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _btnStyle(Color bg, Color fg) => ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      );

  Widget _buildPromotionTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _isPaidPromotion = false;
            }),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: !_isPaidPromotion
                    ? const Color(0xFF667eea)
                    : const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !_isPaidPromotion
                      ? const Color(0xFF667eea)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    color: !_isPaidPromotion ? Colors.white : Colors.white70,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Free Promotion',
                    style: GoogleFonts.poppins(
                      color: !_isPaidPromotion ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Standard reach',
                    style: GoogleFonts.poppins(
                      color:
                          !_isPaidPromotion ? Colors.white70 : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _isPaidPromotion = true;
            }),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: _isPaidPromotion
                    ? const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
                      )
                    : null,
                color: !_isPaidPromotion ? const Color(0xFF1A1F3A) : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPaidPromotion
                      ? const Color(0xFFFF9800)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    color: _isPaidPromotion ? Colors.white : Colors.white70,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paid Promotion',
                    style: GoogleFonts.poppins(
                      color: _isPaidPromotion ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Maximum visibility',
                    style: GoogleFonts.poppins(
                      color: _isPaidPromotion ? Colors.white70 : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionTiers() {
    return Column(
      children: _promotionTiers.entries.map((entry) {
        final tier = entry.key;
        final data = entry.value;
        final isSelected = _selectedTier == tier;

        return GestureDetector(
          onTap: () => setState(() {
            _selectedTier = tier;
            _end = _start.add(Duration(days: data['duration'] as int));
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? (data['color'] as Color).withOpacity(0.15)
                  : const Color(0xFF1A1F3A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (data['color'] as Color)
                    : Colors.white.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: data['color'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        tier == 'basic'
                            ? Icons.star_border
                            : tier == 'standard'
                                ? Icons.star_half
                                : Icons.star,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] as String,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${data['duration']} days promotion',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rs ${(data['price'] as double).toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        color: data['color'] as Color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (data['features'] as List<String>).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: data['color'] as Color,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            feature,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEventDropdown(List<EventModel> events) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEventId.isEmpty && events.isNotEmpty
              ? events.first.id
              : (_selectedEventId.isEmpty ? null : _selectedEventId),
          hint: const Text('Select event'),
          dropdownColor: const Color(0xFF1A1F3A),
          style: GoogleFonts.poppins(color: Colors.white),
          onChanged: (v) {
            setState(() => _selectedEventId = v ?? '');
          },
          items: events
              .map((e) => DropdownMenuItem(value: e.id, child: Text(e.title)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSuggestions(List<EventModel> allEvents) {
    final auth = context.read<AuthProvider>();
    final myId = auth.user?.id ?? 'demo_user';
    final myEvents = allEvents.where((e) => e.organizerId == myId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    if (myEvents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Suggested (your recent events)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: myEvents.length.clamp(0, 10),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final ev = myEvents[i];
              final selected = _selectedEventId == ev.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedEventId = ev.id),
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF667eea).withOpacity(0.15)
                        : const Color(0xFF1A1F3A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF667eea)
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF0F1530),
                          image: ev.imageUrl != null && ev.imageUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(ev.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (ev.imageUrl == null || ev.imageUrl!.isEmpty)
                            ? const Icon(Icons.event, color: Colors.white54)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ev.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ev.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        selected ? Icons.check_circle : Icons.outlined_flag,
                        size: 18,
                        color:
                            selected ? const Color(0xFF667eea) : Colors.white54,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageTabs() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _langController,
            labelColor: const Color(0xFF667eea),
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'English'),
              Tab(text: 'සිංහල'),
              Tab(text: 'தமிழ்'),
            ],
          ),
          SizedBox(
            height: 220,
            child: TabBarView(
              controller: _langController,
              children: [
                _langEditor('en'),
                _langEditor('si'),
                _langEditor('ta'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _langEditor(String code) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextFormField(
            initialValue: _title[code],
            onChanged: (v) => _title[code] = v,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: _inputDecoration('Title'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _message[code],
            onChanged: (v) => _message[code] = v,
            maxLines: 3,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: _inputDecoration('Message'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white54),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: const Color(0xFF0F1530),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );

  Widget _buildSchedule() {
    return Row(
      children: [
        Expanded(
            child: _dateTile('Start', _start, () async {
          final d = await showDatePicker(
              context: context,
              initialDate: _start,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)));
          if (d != null) setState(() => _start = d);
        })),
        const SizedBox(width: 12),
        Expanded(
            child: _dateTile('End', _end, () async {
          final d = await showDatePicker(
              context: context,
              initialDate: _end,
              firstDate: _start,
              lastDate: DateTime.now().add(const Duration(days: 730)));
          if (d != null) setState(() => _end = d);
        })),
      ],
    );
  }

  Widget _dateTile(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Expanded(
                child: Text('$label: ${date.year}-${date.month}-${date.day}',
                    style: GoogleFonts.poppins(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  Widget _buildImageField() {
    return TextFormField(
      initialValue: _imageUrl,
      onChanged: (v) => _imageUrl = v,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: _inputDecoration('https://... (optional)'),
    );
  }

  Widget _buildNotificationPreview(List<EventModel> events) {
    final ev = events.firstWhere((e) => e.id == _selectedEventId,
        orElse: () => events.isNotEmpty
            ? events.first
            : EventModel(
                id: '',
                title: 'No event',
                description: '',
                startDate: DateTime.now(),
                endDate: DateTime.now(),
                location: '-',
                category: '-',
                organizerId: '-',
                organizerName: '-',
                submittedAt: DateTime.now(),
                isApproved: true));
    final langIdx = _langController.index;
    final lang = langIdx == 0
        ? 'en'
        : langIdx == 1
            ? 'si'
            : 'ta';
    final title = _title[lang]?.isNotEmpty == true
        ? _title[lang]!
        : 'Promotion: ${ev.title}';
    final message = _message[lang]?.isNotEmpty == true
        ? _message[lang]!
        : 'Don\'t miss this event at ${ev.location}!';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconFromKey(_iconKey), color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(message,
                    style: GoogleFonts.poppins(color: Colors.white70)),
              ],
            ),
          ),
          if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(_imageUrl!,
                  width: 48, height: 48, fit: BoxFit.cover),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
    final items = const [
      {'key': 'campaign', 'label': 'Campaign', 'icon': Icons.campaign},
      {'key': 'local_offer', 'label': 'Offer', 'icon': Icons.local_offer},
      {'key': 'star', 'label': 'Highlight', 'icon': Icons.star},
    ];
    return Row(
      children: items.map((e) {
        final selected = _iconKey == e['key'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _iconKey = e['key'] as String),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF667eea).withOpacity(0.15)
                    : const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: selected
                        ? const Color(0xFF667eea)
                        : Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Icon(e['icon'] as IconData,
                      color:
                          selected ? const Color(0xFF667eea) : Colors.white70),
                  const SizedBox(height: 6),
                  Text(e['label'] as String,
                      style: GoogleFonts.poppins(color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconFromKey(String key) {
    switch (key) {
      case 'local_offer':
        return Icons.local_offer;
      case 'star':
        return Icons.star;
      case 'campaign':
      default:
        return Icons.campaign;
    }
  }

  Future<void> _saveDraft() async {
    if (_selectedEventId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select an event')));
      return;
    }

    // Get event title for notification
    final eventProvider = context.read<EventProvider>();
    final events = eventProvider.upcomingEvents;
    final event = events.firstWhere((e) => e.id == _selectedEventId,
        orElse: () => EventModel(
              id: _selectedEventId,
              title: 'Unknown Event',
              description: '',
              startDate: DateTime.now(),
              endDate: DateTime.now(),
              location: '',
              category: 'Other',
              organizerId: '',
              organizerName: 'Unknown',
              submittedAt: DateTime.now(),
            ));

    final tierData = _isPaidPromotion ? _promotionTiers[_selectedTier] : null;
    final p = PromotionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventId: _selectedEventId,
      localizedTitle: Map<String, String>.from(_title),
      localizedMessage: Map<String, String>.from(_message),
      languages: const ['en', 'si', 'ta'],
      imageUrl: _imageUrl,
      startDate: _start,
      endDate: _end,
      createdAt: DateTime.now(),
      status: 'draft',
      isPaid: _isPaidPromotion,
      promotionTier: _isPaidPromotion ? _selectedTier : null,
      paidAmount: _isPaidPromotion ? (tierData?['price'] as double?) : null,
      paymentStatus: _isPaidPromotion ? 'pending' : null,
      paymentDate: null,
    );

    final ok = await context.read<PromotionProvider>().save(p);
    if (ok) {
      // Add notification
      context.read<NotificationProvider>().addPromotionDraftSaved(event.title);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Draft saved')));
      }
    }
  }

  Future<void> _publish() async {
    if (_selectedEventId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select an event')));
      return;
    }

    // Get event title for notification
    final eventProvider = context.read<EventProvider>();
    final events = eventProvider.upcomingEvents;
    final event = events.firstWhere((e) => e.id == _selectedEventId,
        orElse: () => EventModel(
              id: _selectedEventId,
              title: 'Unknown Event',
              description: '',
              startDate: DateTime.now(),
              endDate: DateTime.now(),
              location: '',
              category: 'Other',
              organizerId: '',
              organizerName: 'Unknown',
              submittedAt: DateTime.now(),
            ));

    // Show payment dialog for paid promotions
    if (_isPaidPromotion) {
      final tierData = _promotionTiers[_selectedTier]!;
      final confirmed = await _showPaymentDialog(tierData);
      if (confirmed != true) return;
    }

    final tierData = _isPaidPromotion ? _promotionTiers[_selectedTier] : null;
    final p = PromotionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventId: _selectedEventId,
      localizedTitle: Map<String, String>.from(_title),
      localizedMessage: Map<String, String>.from(_message),
      languages: const ['en', 'si', 'ta'],
      imageUrl: _imageUrl,
      startDate: _start,
      endDate: _end,
      createdAt: DateTime.now(),
      status: 'active',
      isPaid: _isPaidPromotion,
      promotionTier: _isPaidPromotion ? _selectedTier : null,
      paidAmount: _isPaidPromotion ? (tierData?['price'] as double?) : null,
      paymentStatus: _isPaidPromotion ? 'completed' : null,
      paymentDate: _isPaidPromotion ? DateTime.now() : null,
    );
    final ok = await context.read<PromotionProvider>().save(p);
    if (ok) {
      context.read<PromotionProvider>().publish(p, iconData: _iconKey);

      // Add notification
      context.read<NotificationProvider>().addPromotionPublished(
            event.title,
            _isPaidPromotion,
            tier: _isPaidPromotion ? _selectedTier : null,
            amount: _isPaidPromotion ? (tierData?['price'] as double?) : null,
          );

      if (mounted) {
        // Show success modal
        await _showPromotionSuccessModal(
          context,
          event.title,
          _isPaidPromotion,
          tier: _selectedTier,
          amount: _isPaidPromotion ? (tierData?['price'] as double?) : null,
        );

        // Navigate to home page
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<void> _showPromotionSuccessModal(
    BuildContext context,
    String eventTitle,
    bool isPaid, {
    String? tier,
    double? amount,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Success icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPaid
                            ? [const Color(0xFFFF9800), const Color(0xFFFF6F00)]
                            : [
                                const Color(0xFF667eea),
                                const Color(0xFF764ba2)
                              ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPaid ? Icons.workspace_premium : Icons.check_circle,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    isPaid
                        ? '✨ Premium Promotion Live!'
                        : 'Promotion Published!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Event title
                  Text(
                    eventTitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Details card
                  if (isPaid)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF667eea),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Package',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tier?.toUpperCase() ?? 'PREMIUM',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Amount Paid',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Rs ${amount?.toStringAsFixed(0) ?? '0'}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF667eea),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Features list
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What Happens Next',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem(
                          Icons.notifications_active,
                          'Users notified',
                          'Event followers will receive notifications',
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.trending_up,
                          'Live on platform',
                          'Your promotion is now visible to target users',
                        ),
                        if (isPaid) ...[
                          const SizedBox(height: 10),
                          _buildFeatureItem(
                            Icons.star,
                            'Featured badge',
                            'Your event gets priority visibility',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Great! Got it',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF667eea), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool?> _showPaymentDialog(Map<String, dynamic> tierData) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.payment, color: tierData['color'] as Color),
            const SizedBox(width: 12),
            Text(
              'Confirm Payment',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Promotion Package',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${tierData['name']} - ${tierData['duration']} days',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (tierData['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tierData['color'] as Color),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Rs ${(tierData['price'] as double).toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: tierData['color'] as Color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Method: Demo Mode (Auto-approved)',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: tierData['color'] as Color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Confirm Payment',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
