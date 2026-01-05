import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// conditional import to safely disable right-click on web only
import '../utils/context_menu_blocker_stub.dart'
    if (dart.library.html) '../utils/context_menu_blocker_web.dart';

const String kGoogleApiKey = '<PUT_YOUR_API_KEY_HERE>'; // replace with real key
const String kGoogleSearchEngineId =
    '<PUT_YOUR_CX_HERE>'; // replace with real CX

class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({Key? key}) : super(key: key);

  @override
  State<AIRecommendationsScreen> createState() =>
      _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  String currentView = 'landing'; // landing, preferences, results
  int step = 1;

  // Preferences data (fields used by "add event" form)
  Map<String, dynamic> preferences = {
    'age': '',
    'preferredArea': '',
    'budget': '',
    'favoriteArtist': '',
    'eventTypes': <String, bool>{
      'concert': false,
      'festival': false,
      'sport': false,
      'cultural': false,
      'religious': false,
      'comedy': false,
    }
  };

  // results
  List<Map<String, dynamic>> localResults = [];
  List<Map<String, dynamic>> monitoredResults = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    disableContextMenu(); // disable right-click on web
  }

  // Generate results: local (Firestore) + monitored (Google Custom Search)
  Future<void> _generateResults() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await _queryLocalEvents();
      await _queryMonitoredEvents();
      if (mounted) {
        setState(() {
          currentView = 'results';
        });
      }
    } on FirebaseException catch (fe) {
      debugPrint('Firestore error: ${fe.code} ${fe.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firestore error: ${fe.message ?? fe.code}')),
        );
      }
    } catch (e) {
      debugPrint('Error generating results: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Could not fetch events.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Local events from Firestore using fields from add-event form
  Future<void> _queryLocalEvents() async {
    localResults = [];
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('events').withConverter(
              fromFirestore: (snap, _) =>
                  Map<String, dynamic>.from(snap.data() ?? {}),
              toFirestore: (map, _) => map,
            );

    final area = (preferences['preferredArea'] as String).trim();
    final budgetStr = (preferences['budget'] as String).trim();
    final favArtist = (preferences['favoriteArtist'] as String).trim();
    final selectedTypes = (preferences['eventTypes'] as Map<String, bool>)
        .entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (area.isNotEmpty) {
      query = query.where('location', isEqualTo: area);
    }

    final budget = int.tryParse(budgetStr) ?? 0;
    if (budget > 0) {
      query = query.where('ticketPrice', isLessThanOrEqualTo: budget);
    }

    if (selectedTypes.isNotEmpty) {
      if (selectedTypes.length == 1) {
        query = query.where('eventType', isEqualTo: selectedTypes.first);
      } else {
        // Firestore whereIn supports up to 10 values
        query = query.where('eventType', whereIn: selectedTypes);
      }
    }

    // if favorite artist provided, match against 'artists' array (array-contains)
    if (favArtist.isNotEmpty) {
      query = query.where('artists', arrayContains: favArtist);
    }

    final snapshot = await query.get();
    localResults = snapshot.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'title': data['title'] ?? '',
        'type': data['eventType'] ?? '',
        'location': data['location'] ?? '',
        'date': data['date'] ?? '',
        'ticketPrice': data['ticketPrice'] ?? 0,
        'image': data['image'] ?? '',
        'description': data['description'] ?? '',
        'link': data['link'] ?? '',
        'artists': data['artists'] ?? [],
      };
    }).toList();
  }

  // Monitored results using Google Custom Search API (parsed into app view)
  Future<void> _queryMonitoredEvents() async {
    monitoredResults = [];
    // require valid API key & CX
    final hasApi = kGoogleApiKey.isNotEmpty &&
        kGoogleApiKey != '<PUT_YOUR_API_KEY_HERE>' &&
        kGoogleSearchEngineId.isNotEmpty &&
        kGoogleSearchEngineId != '<PUT_YOUR_CX_HERE>';

    if (!hasApi) return;

    final area = (preferences['preferredArea'] as String).trim();
    final favArtist = (preferences['favoriteArtist'] as String).trim();
    final budget = (preferences['budget'] as String).trim();
    final selectedTypes = (preferences['eventTypes'] as Map<String, bool>)
        .entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    String query = 'events';
    if (area.isNotEmpty) query += ' in $area';
    if (favArtist.isNotEmpty) query += ' $favArtist';
    if (selectedTypes.isNotEmpty) query += ' ${selectedTypes.join(' ')}';
    if (budget.isNotEmpty) query += ' budget $budget';
    query += ' Sri Lanka';

    monitoredResults = await _googleSearch(query);
  }

  Future<List<Map<String, dynamic>>> _googleSearch(String query) async {
    try {
      final encoded = Uri.encodeQueryComponent(query);
      final url =
          'https://www.googleapis.com/customsearch/v1?q=$encoded&key=$kGoogleApiKey&cx=$kGoogleSearchEngineId&num=10';
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) {
        debugPrint('Google search failed: ${resp.statusCode} ${resp.body}');
        return [];
      }
      final jsonBody = json.decode(resp.body) as Map<String, dynamic>;
      final items = (jsonBody['items'] as List?) ?? [];
      final List<Map<String, dynamic>> results = [];
      for (var item in items) {
        results.add({
          'id': item['cacheId'] ?? '',
          'title': item['title'] ?? '',
          'description': item['snippet'] ?? '',
          'link': item['link'] ?? '',
          'image': item['pagemap']?['cse_image']?[0]?['src'] ?? '',
          'type': _extractEventType(item['title'] ?? item['snippet'] ?? ''),
          'location': preferences['preferredArea'] ?? '',
          'date': _extractDate(item['snippet'] ?? '') ?? '',
          'ticketPrice': _extractPrice(item['snippet'] ?? ''),
        });
      }
      return results;
    } catch (e) {
      debugPrint('Google Search Error: $e');
      return [];
    }
  }

  String _extractEventType(String text) {
    final eventTypes = [
      'concert',
      'festival',
      'sport',
      'cultural',
      'religious',
      'comedy'
    ];
    final low = text.toLowerCase();
    for (var t in eventTypes) {
      if (low.contains(t)) return t[0].toUpperCase() + t.substring(1);
    }
    return 'Event';
  }

  String? _extractDate(String text) {
    final datePattern = RegExp(
        r'\b(\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|\d{4}[-/]\d{1,2}[-/]\d{1,2})\b');
    final m = datePattern.firstMatch(text);
    return m?.group(0);
  }

  int _extractPrice(String text) {
    final pricePattern = RegExp(r'(?:LKR|Rs\.?|Rs)\s*([\d,]+)');
    final m = pricePattern.firstMatch(text);
    if (m != null) return int.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
    return 0;
  }

  // UI: tabbed results view (Local / Monitored)
  Widget _buildResultsPage() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text('Recommendations Monitor'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                currentView = 'preferences';
                step = 1;
              });
            },
          ),
          bottom: TabBar(
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFa855f7),
            ),
            tabs: const [
              Tab(text: 'Local'),
              Tab(text: 'Monitored'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
            ),
          ),
          child: SafeArea(
            child: TabBarView(
              children: [
                _resultsListView(localResults,
                    emptyLabel: 'No local events found'),
                _resultsListView(monitoredResults,
                    emptyLabel: 'No monitored results (check API key)'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultsListView(List<Map<String, dynamic>> results,
      {required String emptyLabel}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (results.isEmpty) {
      return Center(
          child:
              Text(emptyLabel, style: const TextStyle(color: Colors.white70)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildResultCard(results[index]),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFa855f7), Color(0xFFec4899)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (result['type'] ?? 'Event'),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              result['title'] ?? 'Untitled',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Text(
          result['description'] ?? result['date'] ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF94a3b8)),
        ),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.calendar_today, size: 14, color: Color(0xFF94a3b8)),
          const SizedBox(width: 6),
          Text(result['date'] ?? 'TBD',
              style: const TextStyle(color: Color(0xFF94a3b8))),
          const SizedBox(width: 12),
          const Icon(Icons.location_on, size: 14, color: Color(0xFF94a3b8)),
          const SizedBox(width: 6),
          Text(result['location'] ?? 'TBD',
              style: const TextStyle(color: Color(0xFF94a3b8))),
          const Spacer(),
          const Icon(Icons.attach_money, size: 14, color: Color(0xFF94a3b8)),
          const SizedBox(width: 6),
          Text('LKR ${result['ticketPrice'] ?? 0}',
              style: const TextStyle(color: Color(0xFF94a3b8))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          ElevatedButton(
            onPressed: () {
              final link = result['link'] ?? '';
              if (link.isNotEmpty) {
                // open externally — use debugPrint here, integrate url_launcher if needed
                debugPrint('Open link: $link');
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFa855f7)),
            child: const Text('View'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              // track or save action
              debugPrint('Save/Monitor: ${result['id']}');
            },
            child: const Text('Monitor'),
          ),
        ])
      ]),
    );
  }

  // basic landing/preferences/result coordinator
  @override
  Widget build(BuildContext context) {
    if (currentView == 'results') return _buildResultsPage();

    // minimal landing/preferences UI - keep existing form and call _generateResults on "Get Recommendations"
    return Scaffold(
      appBar: AppBar(title: const Text('AI Recommendations')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // simple inputs to set preferences (expand as needed)
            TextField(
              decoration: const InputDecoration(labelText: 'Preferred Area'),
              onChanged: (v) => preferences['preferredArea'] = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Budget (LKR)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => preferences['budget'] = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Favorite Artist'),
              onChanged: (v) => preferences['favoriteArtist'] = v,
            ),
            const SizedBox(height: 12),
            // simple event type toggles
            Wrap(
              spacing: 8,
              children: (preferences['eventTypes'] as Map<String, bool>)
                  .keys
                  .map<Widget>((k) {
                final isSel =
                    (preferences['eventTypes'] as Map<String, bool>)[k] ??
                        false;
                return FilterChip(
                  label: Text(k),
                  selected: isSel,
                  onSelected: (v) => setState(() =>
                      (preferences['eventTypes'] as Map<String, bool>)[k] = v),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateResults,
              child: Text(_isLoading ? 'Loading...' : 'Get Recommendations'),
            ),
          ]),
        ),
      ),
    );
  }
}
