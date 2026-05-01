import 'package:festio_lk/core/services/EventR_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final TextEditingController _cityController = TextEditingController();

  // Event categories
  final List<String> categories = ["Music", "Festival", "Dance", "Theater"];
  List<String> selectedCategories = [];

  // Venue types
  final List<Map<String, dynamic>> venueOptions = [
    {"name": "Outdoor", "icon": Icons.park},
    {"name": "Indoor", "icon": Icons.meeting_room},
  ];
  String? selectedVenue;

  // Time of day
  final List<Map<String, dynamic>> timeOptions = [
    {"name": "Morning", "icon": Icons.wb_sunny},
    {"name": "Evening", 'icon': Icons.nights_stay},
    {"name": "Night", "icon": Icons.nightlight_round},
  ];
  String? selectedTime;

  // Sri Lanka Districts
  final List<String> districts = [
    "Colombo",
    "Gampaha",
    "Kalutara",
    "Kandy",
    "Matale",
    "Nuwara Eliya",
    "Galle",
    "Matara",
    "Hambantota",
    "Jaffna",
    "Kilinochchi",
    "Mannar",
    "Vavuniya",
    "Mullaitivu",
    "Batticaloa",
    "Ampara",
    "Trincomalee",
    "Kurunegala",
    "Puttalam",
    "Anuradhapura",
    "Polonnaruwa",
    "Badulla",
    "Monaragala",
    "Ratnapura",
    "Kegalle",
  ];
  String? selectedDistrict;

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141A3D),
        title: const Text("Tell Us About You"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
           
              // District Dropdown
              Text("Your District", style: GoogleFonts.poppins(color: Colors.white)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedDistrict,
                hint: const Text("Select district"),
                dropdownColor: const Color(0xFF141A3D),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1A203D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                items: districts.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text(d, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedDistrict = val),
              ),
              const SizedBox(height: 24),

               Text("Your City", style: GoogleFonts.poppins(color: Colors.white)),
              const SizedBox(height: 8),
              TextField(controller: _cityController),
              const SizedBox(height: 20),

              // Categories
              Text("What events do you like?", style: GoogleFonts.poppins(color: Colors.white)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: categories.map((category) {
                  final selected = selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          selectedCategories.add(category);
                        } else {
                          selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Venue chips
              Text("Preferred Venue Type", style: GoogleFonts.poppins(color: Colors.white)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: venueOptions.map((option) {
                  final isSelected = selectedVenue == option['name'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(option['icon'], color: isSelected ? Colors.white : Colors.grey[300]),
                        const SizedBox(width: 5),
                        Text(option['name']),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: Colors.blueAccent,
                    onSelected: (_) {
                      setState(() => selectedVenue = option['name']);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Time chips
              Text("Preferred Time of Day", style: GoogleFonts.poppins(color: Colors.white)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: timeOptions.map((option) {
                  final isSelected = selectedTime == option['name'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(option['icon'], color: isSelected ? Colors.white : Colors.grey[300]),
                        const SizedBox(width: 5),
                        Text(option['name']),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: Colors.blueAccent,
                    onSelected: (_) {
                      setState(() => selectedTime = option['name']);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    final city = _cityController.text.trim();

    if (
        city.isEmpty ||
        selectedDistrict == null ||
        selectedCategories.isEmpty ||
        selectedVenue == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select all options.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseService().saveUserPreferences(
        city: city,
        district: selectedDistrict!,
        preferredCategories: selectedCategories,
        venueType: selectedVenue!,
        timeOfDay: selectedTime!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Preferences saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

     
    } catch (e) {
      print('❌ Error saving preferences: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save preferences: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}