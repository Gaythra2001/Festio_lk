import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event_model.dart';
import 'ai/event_extractor.dart';

/// Public API Service
/// Integrates with Eventbrite, city guides, and other event sources
class PublicAPIService {
  final EventExtractor _eventExtractor = EventExtractor();
  final http.Client _client = http.Client();

  /// Fetch events from Eventbrite API
  Future<List<EventModel>> fetchEventbriteEvents({
    String? location,
    String? category,
  }) async {
    try {
      // Eventbrite API endpoint (requires API key)
      final url = Uri.parse('https://www.eventbriteapi.com/v3/events/search/');
      final queryParams = <String, String>{
        'token': 'YOUR_EVENTBRITE_API_KEY', // Should be in environment variables
        'expand': 'venue',
      };
      
      if (location != null) {
        queryParams['location.address'] = location;
      }
      if (category != null) {
        queryParams['categories'] = category;
      }
      
      final response = await _client.get(url.replace(queryParameters: queryParams));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _eventExtractor.extractFromAPIResponse(data);
      }
    } catch (e) {
      debugPrint('Error fetching Eventbrite events: $e');
    }
    
    return [];
  }

  /// Fetch events from city guides/local APIs
  Future<List<EventModel>> fetchCityGuideEvents({
    String? city,
  }) async {
    try {
      // Example: Local city guide API
      // This would be replaced with actual city guide API endpoints
      final url = Uri.parse('https://api.example-city-guide.com/events');
      final queryParams = <String, String>{};
      
      if (city != null) {
        queryParams['city'] = city;
      }
      
      final response = await _client.get(url.replace(queryParameters: queryParams));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _eventExtractor.extractFromAPIResponse(data);
      }
    } catch (e) {
      debugPrint('Error fetching city guide events: $e');
    }
    
    return [];
  }

  /// Aggregate events from all public sources
  Future<List<EventModel>> aggregatePublicEvents({
    String? location,
    String? category,
  }) async {
    final allEvents = <EventModel>[];
    
    // Fetch from multiple sources in parallel
    final results = await Future.wait([
      fetchEventbriteEvents(location: location, category: category),
      fetchCityGuideEvents(city: location),
    ]);
    
    for (final events in results) {
      allEvents.addAll(events);
    }
    
    // Remove duplicates based on title and date
    final uniqueEvents = <String, EventModel>{};
    for (final event in allEvents) {
      final key = '${event.title}_${event.startDate}';
      if (!uniqueEvents.containsKey(key)) {
        uniqueEvents[key] = event;
      }
    }
    
    return uniqueEvents.values.toList();
  }
}

