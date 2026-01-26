import '../../models/event_model.dart';
import 'nlp_parser.dart';

/// Extract & Translate Event System
/// Extracts event information from text and translates between languages
class EventExtractor {
  final MultiLanguageNLPParser _nlpParser = MultiLanguageNLPParser();

  /// Extract event from multilingual text
  EventModel? extractEventFromText(
    String text,
    String sourceLanguage,
    String organizerId,
    String organizerName,
  ) {
    try {
      final eventInfo = _nlpParser.extractEventInfo(text, sourceLanguage);
      final spamScore = _nlpParser.detectSpamScore(text, sourceLanguage);
      final tags = _nlpParser.autoTag(text, sourceLanguage);
      
      // Determine title and description based on language
      String title = eventInfo['title'] ?? '';
      String description = eventInfo['description'] ?? text;
      String? titleSi, titleTa, descriptionSi, descriptionTa;
      
      if (sourceLanguage == 'si') {
        titleSi = title;
        descriptionSi = description;
      } else if (sourceLanguage == 'ta') {
        titleTa = title;
        descriptionTa = description;
      } else {
        // English is default
      }
      
      return EventModel(
        id: '',
        title: title,
        description: description,
        titleSi: titleSi,
        titleTa: titleTa,
        descriptionSi: descriptionSi,
        descriptionTa: descriptionTa,
        startDate: eventInfo['date'] as DateTime? ?? DateTime.now().add(const Duration(days: 7)),
        endDate: eventInfo['date'] as DateTime? ?? DateTime.now().add(const Duration(days: 7)),
        location: eventInfo['location'] ?? 'Sri Lanka',
        category: eventInfo['category'] ?? 'Other',
        tags: tags,
        organizerId: organizerId,
        organizerName: organizerName,
        submittedAt: DateTime.now(),
        isApproved: false,
        spamScore: spamScore,
        trustScore: 0,
      );
    } catch (e) {
      return null;
    }
  }

  /// Translate event to other languages (placeholder - would use translation API)
  EventModel translateEvent(EventModel event, List<String> targetLanguages) {
    // In a real implementation, this would call a translation service
    // For now, return the event as-is
    return event;
  }

  /// Extract events from public API responses
  List<EventModel> extractFromAPIResponse(Map<String, dynamic> apiData) {
    final events = <EventModel>[];
    
    // Parse API response format (adapt based on actual API)
    if (apiData.containsKey('events')) {
      final eventsList = apiData['events'] as List?;
      if (eventsList != null) {
        for (final eventData in eventsList) {
          try {
            final event = EventModel(
              id: eventData['id']?.toString() ?? '',
              title: eventData['title'] ?? '',
              description: eventData['description'] ?? '',
              startDate: _parseDate(eventData['start_date']),
              endDate: _parseDate(eventData['end_date']),
              location: eventData['location'] ?? '',
              category: eventData['category'] ?? 'Other',
              organizerId: 'api_import',
              organizerName: eventData['organizer'] ?? 'External Source',
              submittedAt: DateTime.now(),
              isApproved: true, // Pre-approved from trusted APIs
              trustScore: 80,
            );
            events.add(event);
          } catch (e) {
            // Skip invalid events
          }
        }
      }
    }
    
    return events;
  }

  DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}

