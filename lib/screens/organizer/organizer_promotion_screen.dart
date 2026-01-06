import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/promotion_provider.dart';
import '../../core/providers/event_provider.dart';
import '../../core/models/promotion_model.dart';
import '../../core/models/event_model.dart';

class OrganizerPromotionScreen extends StatefulWidget {
  const OrganizerPromotionScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _langController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      context.read<PromotionProvider>().load();
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
            _buildSectionTitle('Choose Event'),
            const SizedBox(height: 8),
            _buildEventDropdown(events),
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
    );
    final ok = await context.read<PromotionProvider>().save(p);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Draft saved')));
    }
  }

  Future<void> _publish() async {
    if (_selectedEventId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select an event')));
      return;
    }
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
    );
    final ok = await context.read<PromotionProvider>().save(p);
    if (ok) {
      context.read<PromotionProvider>().publish(p, iconData: _iconKey);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Promotion published')));
    }
  }
}
