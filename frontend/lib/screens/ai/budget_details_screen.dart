import 'package:flutter/material.dart';
import 'budget_calculator.dart';

class BudgetDetailsScreen extends StatefulWidget {
  const BudgetDetailsScreen({super.key});

  @override
  State<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends State<BudgetDetailsScreen> {
  int step = 0;

  String eventType = '';
  String district = '';
  String city = '';
  String size = '';
  int audience = 50;
  int duration = 4;
  String venueType = 'indoor';
  int budgetMin = 100000;
  int budgetMax = 500000;

  BudgetPlan? plan;

  String cateringLevel = 'none';
String decorationLevel = 'minimal';
String entertainmentLevel = 'none';




  late TextEditingController minBudgetController;
late TextEditingController maxBudgetController;

  final districts = [
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Galle',
    'Matara',
    'Jaffna',
    'Anuradhapura'
  ];


  @override
void initState() {
  super.initState();

  minBudgetController =
      TextEditingController(text: budgetMin.toString());

  maxBudgetController =
      TextEditingController(text: budgetMax.toString());
}

@override
void dispose() {
  minBudgetController.dispose();
  maxBudgetController.dispose();
  super.dispose();
}

  
 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF0A0E27),
    body: SafeArea(
      child: Row(
        children: [
          /// LEFT SIDE: Text + Form Steps
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER TEXT
                  const Text(
                    "Plan Your",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Sri Lankan Cultural Event",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "From Vesak celebrations to Kandyan performances — get accurate budget estimates and smart cost-saving suggestions in Sri Lankan Rupees.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// FORM STEPS (centered / scrollable)
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          width: 600,
                          padding: const EdgeInsets.all(20),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: step == 0
                                ? buildEventTypeStep()
                                : step == 1
                                    ? buildLocationStep()
                                    : step == 2
                                        ? buildSizeAudienceStep()
                                        : step == 3
                                            ? buildDurationVenueStep()
                                            : step == 4
                                                ? buildBudgetStep()
                                                : buildSummaryStep(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// RIGHT SIDE: IMAGE
       /// RIGHT SIDE: IMAGE WITH TOP-TO-BOTTOM DARK GRADIENT
Expanded(
  flex: 1,
  child: Padding(
    padding: const EdgeInsets.all(32),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/poya/hero-cultural.jpg',
            fit: BoxFit.cover,
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.85),
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
          ),

          // Main Text (bottom-left)
          Positioned(
            left: 24,
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Plan Your",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Sri Lankan Cultural Event",
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Additional Text (top-right or anywhere)
          Positioned(
            top: 40,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Budget Friendly • Accurate Estimates • Smart Planning",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),
        ],
      ),
    ),
  );
}

  Widget sectionCard({required Widget child}) {
    return Card(
      color: const Color(0xFF1A1F3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  Widget navigationButtons({
    required VoidCallback? onNext,
    bool showBack = true,
    String nextText = "Next",
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (showBack)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
            ),
            onPressed:
                step == 0 ? null : () => setState(() => step--),
            child: const Text("Back"),
          ),
        ElevatedButton(
          onPressed: onNext,
          child: Text(nextText),
        ),
      ],
    );
  }

  // STEP 1
  Widget buildEventTypeStep() {
  final types = ['cultural', 'religious', 'musical', 'community'];

  final labels = [
    'Cultural Festival',
    'Religious Ceremony',
    'Musical Concert',
    'Community Gathering'
  ];

  final icons = [
    Icons.theater_comedy,
    Icons.temple_buddhist,
    Icons.music_note,
    Icons.groups,
  ];

  // Base icon colors
  final iconColors = [
    Colors.orangeAccent,  // Cultural
    Colors.lightBlueAccent, // Religious
    Colors.pinkAccent,    // Musical
    Colors.greenAccent,   // Community
  ];

  return sectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "What type of event are you planning?",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Select the category that best describes your event.",
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: types.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.8,
          ),
          itemBuilder: (context, index) {
            final selected = eventType == types[index];

            return GestureDetector(
              onTap: () => setState(() => eventType = types[index]),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: selected
                      ? const Color(0xFF6C63FF)
                      : Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF6C63FF)
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icons[index],
                      size: 20,
                      color: selected
                          ? Colors.white
                          : iconColors[index], // dynamic color
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        navigationButtons(
          showBack: false,
          onNext: eventType.isEmpty
              ? null
              : () => setState(() => step++),
        ),
      ],
    ),
  );
}

  // STEP 2
Widget buildLocationStep() {
  return sectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Professional Header
        const Text(
          "Where will your event take place?",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Select the district and enter the city/venue location.",
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 20),

        /// District Dropdown with Label
        const Text(
          "District",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          dropdownColor: const Color(0xFF1A1F3A),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2A2F45), // highlighted input
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          ),
          value: district.isEmpty ? null : district,
          onChanged: (v) => setState(() => district = v!),
          isDense: true,
          isExpanded: true,
          hint: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select District',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          selectedItemBuilder: (context) {
            return districts.map((d) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  d,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList();
          },
          items: districts
              .map((d) => DropdownMenuItem(
                    value: d,
                    child: Text(d),
                  ))
              .toList(),
        ),

        const SizedBox(height: 16),

        /// City / Venue Input with Label
        const Text(
          "City / Venue Name (Optional)",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2A2F45),
            hintText: 'e.g., Matara Town Hall',
            hintStyle: const TextStyle(color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
          onChanged: (v) => setState(() => city = v),
        ),

        const SizedBox(height: 20),

        /// Navigation Buttons
        navigationButtons(
          onNext: district.isEmpty ? null : () => setState(() => step++),
        ),
      ],
    ),
  );
}
  // STEP 3
  Widget buildSizeAudienceStep() {
  final sizes = ['small', 'medium', 'large'];
  final labels = [
    'Small\n50-200',
    'Medium\n200-1000',
    'Large\n1000+'
  ];

  return sectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Professional Header
        const Text(
          "How big is your event?",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Select the event size and expected audience count.",
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 20),

        /// Event Size Options
        Row(
          children: List.generate(sizes.length, (index) {
            final selected = size == sizes[index];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => size = sizes[index]),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: selected
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFF2A2F45),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF6C63FF)
                          : Colors.white24,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        /// Audience Slider Label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Audience',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$audience',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        /// Audience Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF6C63FF),
            inactiveTrackColor: Colors.white24,
            thumbColor: const Color(0xFF6C63FF),
            overlayColor: const Color(0x296C63FF),
            valueIndicatorColor: const Color(0xFF6C63FF),
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(
            value: audience.toDouble(),
            min: 50,
            max: 5000,
            divisions: 4950,
            label: '$audience',
            onChanged: (v) => setState(() => audience = v.round()),
          ),
        ),

        const SizedBox(height: 20),

        /// Navigation Buttons
        navigationButtons(
          onNext: size.isEmpty ? null : () => setState(() => step++),
        ),
      ],
    ),
  );
}

//summery display 

Widget buildSelectedSummaryHeader() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFF6C63FF).withOpacity(0.5),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Event Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Configure duration, venue, and services for your event.",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),

        buildDetailRow("Event Type", getEventTypeLabel()),
        buildDetailRow("Guests", audience.toString()),
        buildDetailRow("District", district),
      ],
    ),
  );
}

Widget buildDetailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        Text(
          value.isEmpty ? "-" : value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

String getEventTypeLabel() {
  switch (eventType) {
    case 'cultural':
      return 'Cultural Festival';
    case 'religious':
      return 'Religious Ceremony';
    case 'musical':
      return 'Musical Concert';
    case 'community':
      return 'Community Gathering';
    default:
      return '-';
  }
}

   Widget buildOptionSection({
  required String title,
  required String currentValue,
  required List<Map<String, String>> options,
  required Function(String) onSelected,
  double subtitleFontSize = 12,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),

      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: options.map((option) {
            final selected = currentValue == option["value"];
            return GestureDetector(
              onTap: () => setState(() => onSelected(option["value"]!)),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: selected
                      ? const Color(0xFF6C63FF)
                      : const Color(0xFF2A2F45),
                  border: Border.all(
                    color: selected ? const Color(0xFF6C63FF) : Colors.white24,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option["title"]!,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option["subtitle"]!,
                      style: TextStyle(
                        color: selected ? Colors.white70 : Colors.white54,
                        fontSize: subtitleFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}


  // STEP 4
Widget buildDurationVenueStep() {
  // Venue options
  final List<Map<String, Object>> venues = [
    {"value": "indoor", "title": "Indoor", "icon": Icons.house},
    {"value": "outdoor", "title": "Outdoor", "icon": Icons.park},
    {"value": "both", "title": "Both", "icon": Icons.event},
  ];

  // Catering options
  final List<Map<String, String>> cateringOptions = [
    {"value": "none", "title": "None", "subtitle": "No catering"},
    {"value": "basic", "title": "Basic", "subtitle": "Tea & snacks"},
    {"value": "standard", "title": "Standard", "subtitle": "Full meals"},
    {"value": "premium", "title": "Premium", "subtitle": "Gourmet dining"},
  ];

  // Decoration options
  final List<Map<String, String>> decorationOptions = [
    {"value": "minimal", "title": "Minimal", "subtitle": "Basic setup"},
    {"value": "standard", "title": "Standard", "subtitle": "Traditional decor"},
    {"value": "elaborate", "title": "Elaborate", "subtitle": "Rich decorations"},
    {"value": "luxury", "title": "Luxury", "subtitle": "Premium design"},
  ];

  // Entertainment options
  final List<Map<String, String>> entertainmentOptions = [
    {"value": "none", "title": "None", "subtitle": "No entertainment"},
    {"value": "basic", "title": "Basic", "subtitle": "Background music"},
    {"value": "moderate", "title": "Moderate", "subtitle": "Live performers"},
    {"value": "full", "title": "Full", "subtitle": "Full production"},
  ];

  // Horizontal card builder
  Widget buildHorizontalOptions({
    required String title,
    required List<Map<String, String>> options,
    required String currentValue,
    required Function(String) onSelected,
    double cardWidth = 140,
    double cardHeight = 100,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final option = options[index];
              final selected = currentValue == option["value"];
              return GestureDetector(
                onTap: () => onSelected(option["value"]!),
                child: Container(
                  width: cardWidth,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF6C63FF) : const Color(0xFF2A2F45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? const Color(0xFF6C63FF) : Colors.white24,
                      width: 1.3,
                    ),
                    boxShadow: [
                      if (selected)
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white70,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? Colors.white70 : Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  return sectionCard(
    child: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSelectedSummaryHeader(),
          const SizedBox(height: 12),

          // Duration Slider
          const Text(
            "Duration (hours)",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF6C63FF),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFF6C63FF),
                    overlayColor: const Color(0x296C63FF),
                    valueIndicatorColor: const Color(0xFF6C63FF),
                    valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: duration.toDouble(),
                    min: 1,
                    max: 12,
                    divisions: 11,
                    label: '$duration h',
                    onChanged: (v) => setState(() => duration = v.round()),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "$duration h",
                style: const TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Venue Type
          const Text(
            "Venue Type",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Row(
            children: venues.map((venue) {
              final selected = venueType == (venue["value"] as String);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => venueType = venue["value"] as String),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: selected ? const Color(0xFF6C63FF) : const Color(0xFF2A2F45),
                      border: Border.all(
                          color: selected ? const Color(0xFF6C63FF) : Colors.white24,
                          width: 1.3),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          venue["icon"] as IconData,
                          color: selected ? Colors.white : Colors.white70,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          venue["title"] as String,
                          style: TextStyle(
                              fontSize: 12,
                              color: selected ? Colors.white : Colors.white70,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Horizontal Option Cards
          buildHorizontalOptions(
              title: "Catering",
              options: cateringOptions,
              currentValue: cateringLevel,
              onSelected: (val) => setState(() => cateringLevel = val),
              cardWidth: 160,
              cardHeight: 80),
          buildHorizontalOptions(
              title: "Decoration Level",
              options: decorationOptions,
              currentValue: decorationLevel,
              onSelected: (val) => setState(() => decorationLevel = val),
              cardWidth: 160,
              cardHeight: 80),
          buildHorizontalOptions(
              title: "Entertainment",
              options: entertainmentOptions,
              currentValue: entertainmentLevel,
              onSelected: (val) => setState(() => entertainmentLevel = val),
              cardWidth: 160,
              cardHeight: 80),

          // Navigation buttons
          navigationButtons(onNext: () => setState(() => step++)),
        ],
      ),
    ),
  );
}

  // STEP 5
 Widget buildBudgetStep() {
  return sectionCard(
    child: SingleChildScrollView(  // Make scrollable in case of small screens
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Professional header ---
          const Text(
            "What's your budget range?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Set your preferred budget range in Sri Lankan Rupees (LKR).",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),

          // Budget range display
          Text(
            "LKR ${budgetMin.toStringAsFixed(0)} - LKR ${budgetMax.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 20),

          // Minimum budget input
          TextField(
            controller: minBudgetController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minimum Budget(LKR)',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF6C63FF)),
              ),
            ),
            onChanged: (v) {
              setState(() {
                budgetMin = int.tryParse(v) ?? budgetMin;
              });
            },
          ),
          const SizedBox(height: 16),

          // Maximum budget input
          TextField(
            controller: maxBudgetController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Maximum Budget(LKR)',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF6C63FF)),
              ),
            ),
            onChanged: (v) {
              setState(() {
                budgetMax = int.tryParse(v) ?? budgetMax;
              });
            },
          ),
          const SizedBox(height: 24),

          // Navigation button
          navigationButtons(
            nextText: "Generate Budget",
            onNext: () {
              plan = calculateBudget(EventDetails(
                eventType: eventType,
                district: district,
                size: size,
                audienceCount: audience,
                duration: duration,
                venueType: venueType,
                budgetMin: budgetMin,
                budgetMax: budgetMax,
              ));
              setState(() => step++);
            },
          ),
        ],
      ),
    ),
  );
}

  // STEP 6
 Widget buildSummaryStep() {
  if (plan == null) {
    return const Center(
      child: Text(
        'No plan generated.',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  final isOverBudget = plan!.totalEstimated > budgetMax;

  // Helper function for icons based on category
  Icon getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'venue':
        return const Icon(Icons.house, color: Color(0xFF6C63FF), size: 28);
      case 'catering':
        return const Icon(Icons.restaurant, color: Color(0xFF6C63FF), size: 28);
      case 'decoration':
        return const Icon(Icons.emoji_events, color: Color(0xFF6C63FF), size: 28);
      case 'entertainment':
        return const Icon(Icons.music_note, color: Color(0xFF6C63FF), size: 28);
      default:
        return const Icon(Icons.attach_money, color: Color(0xFF6C63FF), size: 28);
    }
  }

  return sectionCard(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER with Icon
          Row(
            children: [
              const Icon(Icons.event, color: Color(0xFF6C63FF), size: 28),
              const SizedBox(width: 8),
              Text(
                "${getEventTypeLabel()} in $district",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "For $audience guests • $duration hours • $venueType venue",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),

          /// TOTAL ESTIMATED BOX
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6C63FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Estimated Total",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  formatLKR(plan!.totalEstimated),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  "Range: ${formatLKR(plan!.totalMin)} - ${formatLKR(plan!.totalMax)}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  isOverBudget ? "⚠️ Over Budget" : "✅ Within Budget",
                  style: TextStyle(
                    color: isOverBudget ? Colors.redAccent : Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          /// BUDGET BREAKDOWN with icons
          const Text(
            "📊 Budget Breakdown",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),

          ...plan!.items.map(
            (item) => Card(
              color: const Color(0xFF1A1F3A),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        getIconForCategory(item.category), // icon for category
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.category,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white),
                          ),
                        ),
                        Text(
                          formatLKR(item.estimatedCost),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Range: ${formatLKR(item.minCost)} - ${formatLKR(item.maxCost)}",
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            "💡 AI-Powered Suggestions",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),

          /// AI suggestions with lightbulb icons
          ...plan!.suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.yellowAccent, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white24),

          const SizedBox(height: 12),
          const Text(
            "⚠️ Disclaimer: All budget figures are estimates. Confirm prices with local vendors before finalizing your plans.",
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 24),

          /// ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF)),
                  onPressed: () => setState(() => step = 0),
                  child: const Text("Plan Another Event"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50)),
                  onPressed: () {
                    // TODO: Add PDF generation
                  },
                  child: const Text("Download PDF"),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}