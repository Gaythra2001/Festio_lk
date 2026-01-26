import 'package:cloud_firestore/cloud_firestore.dart';

/// Comprehensive User Preferences Model for Research-Grade Recommendations
/// Captures demographic, behavioral, and preference data for advanced ML algorithms
class UserPreferencesModel {
  // Personal Demographics
  final int? age;
  final String? gender; // 'male', 'female', 'other', 'prefer_not_to_say'
  final String? religion; // 'buddhism', 'hinduism', 'islam', 'christianity', 'other', 'none'
  final String? occupation;
  final String? educationLevel;
  
  // Location & Budget Preferences
  final String? primaryArea; // User's primary location/district
  final List<String> preferredAreas; // Areas they're willing to travel to
  final double? maxTravelDistance; // in kilometers
  final double? minBudget;
  final double? maxBudget;
  final String? budgetFlexibility; // 'strict', 'flexible', 'very_flexible'
  
  // Event Preferences
  final List<String> favoriteEventTypes; // 'music', 'religious', 'cultural', 'sports', etc.
  final List<String> favoriteGenres; // 'rock', 'classical', 'hip-hop', etc.
  final List<String> favoriteArtists;
  final List<String> favoriteVenues;
  final List<String> dislikedEventTypes;
  
  // Behavioral Preferences
  final String? preferredEventTime; // 'morning', 'afternoon', 'evening', 'night', 'weekend'
  final List<String> preferredDays; // 'monday', 'tuesday', etc.
  final int? groupSize; // Typical number of people they attend with
  final bool prefersFamilyFriendly;
  final bool prefersOutdoor;
  final bool prefersIndoor;
  
  // Cultural & Religious Preferences
  final bool observesPoyaDays;
  final bool observesReligiousHolidays;
  final List<String> culturalInterests; // 'traditional', 'modern', 'fusion', etc.
  final String? languagePreference; // 'en', 'si', 'ta', 'multi'
  
  // Social & Engagement Preferences
  final String? socialStyle; // 'introverted', 'extroverted', 'ambivert'
  final bool likesNewExperiences;
  final bool prefersFamiliarEvents;
  final int adventureLevel; // 1-5 scale
  
  // Notification & Communication Preferences
  final bool allowsPersonalizedNotifications;
  final bool allowsLocationBasedRecommendations;
  final bool sharesDataForResearch;
  final int notificationFrequency; // How often they want recommendations
  
  // Metadata
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isComplete; // Whether user completed full preferences survey
  final double completionPercentage;

  UserPreferencesModel({
    this.age,
    this.gender,
    this.religion,
    this.occupation,
    this.educationLevel,
    this.primaryArea,
    this.preferredAreas = const [],
    this.maxTravelDistance,
    this.minBudget,
    this.maxBudget,
    this.budgetFlexibility,
    this.favoriteEventTypes = const [],
    this.favoriteGenres = const [],
    this.favoriteArtists = const [],
    this.favoriteVenues = const [],
    this.dislikedEventTypes = const [],
    this.preferredEventTime,
    this.preferredDays = const [],
    this.groupSize,
    this.prefersFamilyFriendly = false,
    this.prefersOutdoor = false,
    this.prefersIndoor = false,
    this.observesPoyaDays = false,
    this.observesReligiousHolidays = false,
    this.culturalInterests = const [],
    this.languagePreference,
    this.socialStyle,
    this.likesNewExperiences = true,
    this.prefersFamiliarEvents = false,
    this.adventureLevel = 3,
    this.allowsPersonalizedNotifications = true,
    this.allowsLocationBasedRecommendations = true,
    this.sharesDataForResearch = false,
    this.notificationFrequency = 3,
    required this.createdAt,
    this.updatedAt,
    this.isComplete = false,
    this.completionPercentage = 0.0,
  });

  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      age: map['age'],
      gender: map['gender'],
      religion: map['religion'],
      occupation: map['occupation'],
      educationLevel: map['educationLevel'],
      primaryArea: map['primaryArea'],
      preferredAreas: List<String>.from(map['preferredAreas'] ?? []),
      maxTravelDistance: (map['maxTravelDistance'] as num?)?.toDouble(),
      minBudget: (map['minBudget'] as num?)?.toDouble(),
      maxBudget: (map['maxBudget'] as num?)?.toDouble(),
      budgetFlexibility: map['budgetFlexibility'],
      favoriteEventTypes: List<String>.from(map['favoriteEventTypes'] ?? []),
      favoriteGenres: List<String>.from(map['favoriteGenres'] ?? []),
      favoriteArtists: List<String>.from(map['favoriteArtists'] ?? []),
      favoriteVenues: List<String>.from(map['favoriteVenues'] ?? []),
      dislikedEventTypes: List<String>.from(map['dislikedEventTypes'] ?? []),
      preferredEventTime: map['preferredEventTime'],
      preferredDays: List<String>.from(map['preferredDays'] ?? []),
      groupSize: map['groupSize'],
      prefersFamilyFriendly: map['prefersFamilyFriendly'] ?? false,
      prefersOutdoor: map['prefersOutdoor'] ?? false,
      prefersIndoor: map['prefersIndoor'] ?? false,
      observesPoyaDays: map['observesPoyaDays'] ?? false,
      observesReligiousHolidays: map['observesReligiousHolidays'] ?? false,
      culturalInterests: List<String>.from(map['culturalInterests'] ?? []),
      languagePreference: map['languagePreference'],
      socialStyle: map['socialStyle'],
      likesNewExperiences: map['likesNewExperiences'] ?? true,
      prefersFamiliarEvents: map['prefersFamiliarEvents'] ?? false,
      adventureLevel: map['adventureLevel'] ?? 3,
      allowsPersonalizedNotifications: map['allowsPersonalizedNotifications'] ?? true,
      allowsLocationBasedRecommendations: map['allowsLocationBasedRecommendations'] ?? true,
      sharesDataForResearch: map['sharesDataForResearch'] ?? false,
      notificationFrequency: map['notificationFrequency'] ?? 3,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      isComplete: map['isComplete'] ?? false,
      completionPercentage: (map['completionPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'gender': gender,
      'religion': religion,
      'occupation': occupation,
      'educationLevel': educationLevel,
      'primaryArea': primaryArea,
      'preferredAreas': preferredAreas,
      'maxTravelDistance': maxTravelDistance,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'budgetFlexibility': budgetFlexibility,
      'favoriteEventTypes': favoriteEventTypes,
      'favoriteGenres': favoriteGenres,
      'favoriteArtists': favoriteArtists,
      'favoriteVenues': favoriteVenues,
      'dislikedEventTypes': dislikedEventTypes,
      'preferredEventTime': preferredEventTime,
      'preferredDays': preferredDays,
      'groupSize': groupSize,
      'prefersFamilyFriendly': prefersFamilyFriendly,
      'prefersOutdoor': prefersOutdoor,
      'prefersIndoor': prefersIndoor,
      'observesPoyaDays': observesPoyaDays,
      'observesReligiousHolidays': observesReligiousHolidays,
      'culturalInterests': culturalInterests,
      'languagePreference': languagePreference,
      'socialStyle': socialStyle,
      'likesNewExperiences': likesNewExperiences,
      'prefersFamiliarEvents': prefersFamiliarEvents,
      'adventureLevel': adventureLevel,
      'allowsPersonalizedNotifications': allowsPersonalizedNotifications,
      'allowsLocationBasedRecommendations': allowsLocationBasedRecommendations,
      'sharesDataForResearch': sharesDataForResearch,
      'notificationFrequency': notificationFrequency,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isComplete': isComplete,
      'completionPercentage': completionPercentage,
    };
  }

  UserPreferencesModel copyWith({
    int? age,
    String? gender,
    String? religion,
    String? occupation,
    String? educationLevel,
    String? primaryArea,
    List<String>? preferredAreas,
    double? maxTravelDistance,
    double? minBudget,
    double? maxBudget,
    String? budgetFlexibility,
    List<String>? favoriteEventTypes,
    List<String>? favoriteGenres,
    List<String>? favoriteArtists,
    List<String>? favoriteVenues,
    List<String>? dislikedEventTypes,
    String? preferredEventTime,
    List<String>? preferredDays,
    int? groupSize,
    bool? prefersFamilyFriendly,
    bool? prefersOutdoor,
    bool? prefersIndoor,
    bool? observesPoyaDays,
    bool? observesReligiousHolidays,
    List<String>? culturalInterests,
    String? languagePreference,
    String? socialStyle,
    bool? likesNewExperiences,
    bool? prefersFamiliarEvents,
    int? adventureLevel,
    bool? allowsPersonalizedNotifications,
    bool? allowsLocationBasedRecommendations,
    bool? sharesDataForResearch,
    int? notificationFrequency,
    DateTime? updatedAt,
    bool? isComplete,
    double? completionPercentage,
  }) {
    return UserPreferencesModel(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      religion: religion ?? this.religion,
      occupation: occupation ?? this.occupation,
      educationLevel: educationLevel ?? this.educationLevel,
      primaryArea: primaryArea ?? this.primaryArea,
      preferredAreas: preferredAreas ?? this.preferredAreas,
      maxTravelDistance: maxTravelDistance ?? this.maxTravelDistance,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      budgetFlexibility: budgetFlexibility ?? this.budgetFlexibility,
      favoriteEventTypes: favoriteEventTypes ?? this.favoriteEventTypes,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      favoriteArtists: favoriteArtists ?? this.favoriteArtists,
      favoriteVenues: favoriteVenues ?? this.favoriteVenues,
      dislikedEventTypes: dislikedEventTypes ?? this.dislikedEventTypes,
      preferredEventTime: preferredEventTime ?? this.preferredEventTime,
      preferredDays: preferredDays ?? this.preferredDays,
      groupSize: groupSize ?? this.groupSize,
      prefersFamilyFriendly: prefersFamilyFriendly ?? this.prefersFamilyFriendly,
      prefersOutdoor: prefersOutdoor ?? this.prefersOutdoor,
      prefersIndoor: prefersIndoor ?? this.prefersIndoor,
      observesPoyaDays: observesPoyaDays ?? this.observesPoyaDays,
      observesReligiousHolidays: observesReligiousHolidays ?? this.observesReligiousHolidays,
      culturalInterests: culturalInterests ?? this.culturalInterests,
      languagePreference: languagePreference ?? this.languagePreference,
      socialStyle: socialStyle ?? this.socialStyle,
      likesNewExperiences: likesNewExperiences ?? this.likesNewExperiences,
      prefersFamiliarEvents: prefersFamiliarEvents ?? this.prefersFamiliarEvents,
      adventureLevel: adventureLevel ?? this.adventureLevel,
      allowsPersonalizedNotifications: allowsPersonalizedNotifications ?? this.allowsPersonalizedNotifications,
      allowsLocationBasedRecommendations: allowsLocationBasedRecommendations ?? this.allowsLocationBasedRecommendations,
      sharesDataForResearch: sharesDataForResearch ?? this.sharesDataForResearch,
      notificationFrequency: notificationFrequency ?? this.notificationFrequency,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isComplete: isComplete ?? this.isComplete,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}
