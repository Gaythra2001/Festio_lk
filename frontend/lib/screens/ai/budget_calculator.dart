// budget_calculator.dart
import 'dart:math';

import 'package:flutter/src/widgets/icon_data.dart';

class BudgetItem {
  final String category;
  final String description;
  final int minCost;
  final int maxCost;
  final int estimatedCost;
  final String icon;

  IconData? iconData;

  BudgetItem({
    required this.category,
    required this.description,
    required this.minCost,
    required this.maxCost,
    required this.estimatedCost,
    required this.icon,
  });
}

class BudgetPlan {
  final List<BudgetItem> items;
  final int totalMin;
  final int totalMax;
  final int totalEstimated;
  final List<String> suggestions;

  BudgetPlan({
    required this.items,
    required this.totalMin,
    required this.totalMax,
    required this.totalEstimated,
    required this.suggestions,
  });
}

class EventDetails {
  String eventType;
  String district;
  String size;
  int audienceCount;
  int duration;
  String venueType;
  int budgetMin;
  int budgetMax;

  EventDetails({
    required this.eventType,
    required this.district,
    required this.size,
    required this.audienceCount,
    required this.duration,
    required this.venueType,
    required this.budgetMin,
    required this.budgetMax,
  });
}

// Urban areas and multiplier
const List<String> URBAN_DISTRICTS = ['Colombo', 'Gampaha', 'Kandy', 'Galle'];
const double URBAN_MULTIPLIER = 1.3;

// Base costs in LKR
const Map<String, Map<String, int>> stageSoundCosts = {
  'small': {'cost': 75000},
  'medium': {'cost': 200000},
  'large': {'cost': 500000},
};

const Map<String, Map<String, int>> venueCosts = {
  'small': {'indoor': 50000, 'outdoor': 30000},
  'medium': {'indoor': 150000, 'outdoor': 80000},
  'large': {'indoor': 400000, 'outdoor': 200000},
};

const Map<String, int> decorationsCosts = {
  'cultural': 80000,
  'religious': 100000,
  'musical': 50000,
  'community': 40000,
};

const Map<String, int> performersCosts = {
  'cultural': 150000,
  'religious': 80000,
  'musical': 300000,
  'community': 50000,
};

const Map<String, int> technicalStaffCosts = {
  'small': 30000,
  'medium': 80000,
  'large': 200000,
};

const Map<String, int> securityCosts = {
  'small': 20000,
  'medium': 60000,
  'large': 150000,
};

const Map<String, int> marketingCosts = {
  'small': 25000,
  'medium': 75000,
  'large': 200000,
};

const Map<String, int> transportCosts = {
  'small': 20000,
  'medium': 50000,
  'large': 120000,
};

const Map<String, int> permitsCosts = {
  'small': 15000,
  'medium': 35000,
  'large': 80000,
};

const int foodPerPerson = 800;

BudgetPlan calculateBudget(EventDetails details) {
  final bool isUrban = URBAN_DISTRICTS.contains(details.district);
  final double locationMultiplier = isUrban ? URBAN_MULTIPLIER : 1.0;
  final double durationMultiplier = details.duration / 4.0; // base 4 hours

  List<BudgetItem> items = [];

  // Venue
  final venueTypeKey = details.venueType == 'both' ? 'indoor' : details.venueType;
  final int venueBase = venueCosts[details.size]![venueTypeKey]!;
  final int venueCost = (venueBase * locationMultiplier * durationMultiplier).round();
  items.add(BudgetItem(
    category: 'Venue/Ground',
    description: details.venueType == 'indoor'
        ? 'Indoor hall'
        : details.venueType == 'outdoor'
            ? 'Outdoor ground'
            : 'Indoor & outdoor space',
    minCost: (venueCost * 0.8).round(),
    maxCost: (venueCost * 1.3).round(),
    estimatedCost: venueCost,
    icon: '🏛️',
  ));

  // Stage & Sound
  final int stageCost = (stageSoundCosts[details.size]!['cost']! * locationMultiplier).round();
  items.add(BudgetItem(
    category: 'Stage, Sound & Lighting',
    description: 'Professional sound system, stage setup, and lighting equipment',
    minCost: (stageCost * 0.7).round(),
    maxCost: (stageCost * 1.4).round(),
    estimatedCost: stageCost,
    icon: '🎤',
  ));

  // Decorations
  final int decorationBase = decorationsCosts[details.eventType]!;
  final int decorationCost =
      (decorationBase * (details.size == 'large' ? 2 : details.size == 'medium' ? 1.3 : 1)).round();
  items.add(BudgetItem(
    category: 'Traditional Decorations',
    description: 'Cultural decorations, flower arrangements, traditional items',
    minCost: (decorationCost * 0.6).round(),
    maxCost: (decorationCost * 1.5).round(),
    estimatedCost: decorationCost,
    icon: '🪷',
  ));

  // Performers
  final int performerBase = performersCosts[details.eventType]!;
  final int performerCost = (performerBase *
          (details.size == 'large' ? 2.5 : details.size == 'medium' ? 1.5 : 1) *
          locationMultiplier)
      .round();
  items.add(BudgetItem(
    category: 'Performers & Artists',
    description: details.eventType == 'musical' ? 'Musicians and artists' : 'Traditional dancers and performers',
    minCost: (performerCost * 0.5).round(),
    maxCost: (performerCost * 2).round(),
    estimatedCost: performerCost,
    icon: '💃',
  ));

  // Technical Staff
  final int techCost = (technicalStaffCosts[details.size]! * durationMultiplier).round();
  items.add(BudgetItem(
    category: 'Technical Staff & Labor',
    description: 'Event coordinators, technicians, and support staff',
    minCost: (techCost * 0.8).round(),
    maxCost: (techCost * 1.3).round(),
    estimatedCost: techCost,
    icon: '👷',
  ));

  // Security
  final int securityCost = (securityCosts[details.size]! * durationMultiplier).round();
  items.add(BudgetItem(
    category: 'Security & Safety',
    description: 'Security personnel and safety equipment',
    minCost: (securityCost * 0.8).round(),
    maxCost: (securityCost * 1.4).round(),
    estimatedCost: securityCost,
    icon: '🛡️',
  ));

  // Food
  final int foodCost = (foodPerPerson * details.audienceCount);
  items.add(BudgetItem(
    category: 'Food & Refreshments',
    description: 'Catering for ${details.audienceCount} guests',
    minCost: (foodCost * 0.7).round(),
    maxCost: (foodCost * 1.5).round(),
    estimatedCost: foodCost,
    icon: '🍚',
  ));

  // Marketing
  final int marketingCost = marketingCosts[details.size]!;
  items.add(BudgetItem(
    category: 'Marketing & Promotions',
    description: 'Posters, social media, and promotional materials',
    minCost: (marketingCost * 0.5).round(),
    maxCost: (marketingCost * 1.5).round(),
    estimatedCost: marketingCost,
    icon: '📢',
  ));

  // Transport
  final int transportCost = (transportCosts[details.size]! * locationMultiplier).round();
  items.add(BudgetItem(
    category: 'Transport & Logistics',
    description: 'Equipment transport and logistics coordination',
    minCost: (transportCost * 0.7).round(),
    maxCost: (transportCost * 1.4).round(),
    estimatedCost: transportCost,
    icon: '🚛',
  ));

  // Permits
  final int permitCost = permitsCosts[details.size]!;
  items.add(BudgetItem(
    category: 'Permits & Approvals',
    description: 'Government permits and necessary approvals',
    minCost: (permitCost * 0.8).round(),
    maxCost: (permitCost * 1.2).round(),
    estimatedCost: permitCost,
    icon: '📋',
  ));

  // Contingency
  final int subtotal = items.fold(0, (sum, item) => sum + item.estimatedCost);
  final int contingency = (subtotal * 0.08).round();
  items.add(BudgetItem(
    category: 'Contingency (8%)',
    description: 'Emergency fund for unexpected expenses',
    minCost: (contingency * 0.6).round(),
    maxCost: (contingency * 1.25).round(),
    estimatedCost: contingency,
    icon: '💰',
  ));

  final int totalMin = items.fold(0, (sum, item) => sum + item.minCost);
  final int totalMax = items.fold(0, (sum, item) => sum + item.maxCost);
  final int totalEstimated = items.fold(0, (sum, item) => sum + item.estimatedCost);

  final suggestions = generateSuggestions(details, isUrban, totalEstimated);

  return BudgetPlan(
      items: items,
      totalMin: totalMin,
      totalMax: totalMax,
      totalEstimated: totalEstimated,
      suggestions: suggestions);
}

List<String> generateSuggestions(EventDetails details, bool isUrban, int total) {
  List<String> suggestions = [];

  if (isUrban) {
    suggestions.add('💡 Consider venues slightly outside the city center to reduce costs by 20-30%');
  }

  if (details.eventType == 'cultural' || details.eventType == 'religious') {
    suggestions.add('🌿 Use local flower vendors and temple suppliers for authentic, affordable decorations');
    suggestions.add('🤝 Seek sponsorship from local businesses for cultural preservation support');
  }

  if (details.audienceCount > 500) {
    suggestions.add('🍽️ Partner with local community kitchens for cost-effective catering');
  }

  suggestions.add('📱 Use social media marketing to reduce promotional costs significantly');
  suggestions.add('👥 Engage local volunteers and community members to reduce labor costs');

  if (total > details.budgetMax) {
    suggestions.add('⚠️ Budget exceeds your range. Consider reducing guest count or duration');
    suggestions.add('🔄 Explore government cultural grants available for traditional events');
  }

  return suggestions;
}

String formatLKR(int amount) {
  return 'LKR ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
}