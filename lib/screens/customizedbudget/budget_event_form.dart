import 'package:flutter/material.dart';

class BudgetEventForm extends StatefulWidget {
  const BudgetEventForm({super.key});

  @override
  State<BudgetEventForm> createState() => _BudgetEventFormState();
}

class _BudgetEventFormState extends State<BudgetEventForm> {
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String category = '';
  String location = '';
  String date = '';
  String budget = '';
  String guests = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF302B63),
              Color(0xFF24243E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildCard('Event Details', [
                          _buildField('Event Title', Icons.event,
                              (v) => title = v!),
                          _buildField('Category (Music, Drama, Dance)',
                              Icons.category, (v) => category = v!),
                          _buildField('Location', Icons.location_on,
                              (v) => location = v!),
                          _buildField('Event Date', Icons.calendar_today,
                              (v) => date = v!),
                        ]),
                        _buildCard('Budget Planning', [
                          _buildField('Maximum Budget (LKR)',
                              Icons.attach_money, (v) => budget = v!,
                              keyboard: TextInputType.number),
                          _buildField('Expected Guests', Icons.people,
                              (v) => guests = v!,
                              keyboard: TextInputType.number),
                        ]),
                        _buildCard('Description', [
                          _buildField(
                              'Describe your event requirements',
                              Icons.description,
                              (v) => description = v!,
                              maxLines: 4),
                        ]),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A5AE0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _submitForm,
                            child: const Text(
                              'Submit Event',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Header
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Text(
            'Create Budget Event',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Card Section
  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  // 🔹 Input Field
  Widget _buildField(
    String label,
    IconData icon,
    Function(String?) onSaved, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  // 🔹 Submit
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Event Created'),
          content: Text(
            'Your event has been customized within your budget.\n\n'
            'Title: $title\n'
            'Category: $category\n'
            'Location: $location\n'
            'Date: $date\n'
            'Budget: LKR $budget\n'
            'Guests: $guests',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
