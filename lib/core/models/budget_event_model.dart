class BudgetEventModel {
  final String title;
  final String category;
  final String location;
  final String date;
  final double budget;
  final int guests;
  final String description;

  BudgetEventModel({
    required this.title,
    required this.category,
    required this.location,
    required this.date,
    required this.budget,
    required this.guests,
    required this.description,
  });

  // Optional: Convert to Map (useful later for Firebase / API)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'location': location,
      'date': date,
      'budget': budget,
      'guests': guests,
      'description': description,
    };
  }
}
