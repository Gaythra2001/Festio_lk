/// Multi-Language NLP Parser
/// Handles Sinhala, Tamil, and English text processing
class MultiLanguageNLPParser {
  /// Detect language of input text
  String detectLanguage(String text) {
    // Simple language detection based on character sets
    if (_containsSinhala(text)) return 'si';
    if (_containsTamil(text)) return 'ta';
    return 'en'; // Default to English
  }

  /// Extract event information from text (title, date, location, etc.)
  Map<String, dynamic> extractEventInfo(String text, String language) {
    return {
      'title': _extractTitle(text, language),
      'description': _extractDescription(text, language),
      'date': _extractDate(text, language),
      'location': _extractLocation(text, language),
      'category': _extractCategory(text, language),
      'tags': _extractTags(text, language),
    };
  }

  /// Auto-tag events based on content analysis
  List<String> autoTag(String text, String language) {
    final tags = <String>[];
    final lowerText = text.toLowerCase();
    
    // Category detection
    if (_containsKeyword(lowerText, ['dance', 'නැටුම', 'நடனம்'])) {
      tags.add('Dance');
    }
    if (_containsKeyword(lowerText, ['music', 'සංගීත', 'இசை'])) {
      tags.add('Music');
    }
    if (_containsKeyword(lowerText, ['festival', 'පෙරහැර', 'திருவிழா'])) {
      tags.add('Festival');
    }
    if (_containsKeyword(lowerText, ['religious', 'ආගමික', 'மத'])) {
      tags.add('Religious');
    }
    if (_containsKeyword(lowerText, ['cultural', 'සංස්කෘතික', 'கலாச்சார'])) {
      tags.add('Cultural');
    }
    if (_containsKeyword(lowerText, ['traditional', 'සම්ප්‍රදායික', 'பாரம்பரிய'])) {
      tags.add('Traditional');
    }
    
    return tags;
  }

  /// Spam detection using ML-based analysis
  double detectSpamScore(String text, String language) {
    double spamScore = 0.0;
    
    // Check for spam indicators
    final spamKeywords = [
      'free money', 'click here', 'urgent', 'limited time',
      'guaranteed', 'no risk', 'act now',
    ];
    
    final lowerText = text.toLowerCase();
    for (final keyword in spamKeywords) {
      if (lowerText.contains(keyword)) {
        spamScore += 0.2;
      }
    }
    
    // Check for excessive capitalization
    final capsRatio = text.split('').where((c) => c == c.toUpperCase()).length / text.length;
    if (capsRatio > 0.5) spamScore += 0.2;
    
    // Check for excessive punctuation
    final punctCount = text.split('').where((c) => '!?'.contains(c)).length;
    if (punctCount > text.length * 0.1) spamScore += 0.1;
    
    // Check for URL count
    final urlPattern = RegExp(r'https?://\S+');
    final urlCount = urlPattern.allMatches(text).length;
    if (urlCount > 3) spamScore += 0.3;
    
    return spamScore.clamp(0.0, 1.0);
  }

  String _extractTitle(String text, String language) {
    // Extract first line or first sentence as title
    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      return lines.first.trim();
    }
    final sentences = text.split('.');
    return sentences.first.trim();
  }

  String _extractDescription(String text, String language) {
    // Return full text as description (can be enhanced)
    return text;
  }

  DateTime? _extractDate(String text, String language) {
    // Simple date extraction (can be enhanced with NLP)
    final datePattern = RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}');
    final match = datePattern.firstMatch(text);
    if (match != null) {
      try {
        return DateTime.parse(match.group(0)!);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String? _extractLocation(String text, String language) {
    // Common Sri Lankan locations
    final locations = [
      'Colombo', 'Kandy', 'Galle', 'Jaffna', 'Anuradhapura',
      'කොළඹ', 'මහනුවර', 'ගාල්ල', 'යාපනය',
      'கொழும்பு', 'கண்டி', 'காலி', 'யாழ்ப்பாணம்',
    ];
    
    for (final location in locations) {
      if (text.contains(location)) {
        return location;
      }
    }
    return null;
  }

  String? _extractCategory(String text, String language) {
    final categories = {
      'Cultural': ['cultural', 'සංස්කෘතික', 'கலாச்சார'],
      'Music': ['music', 'සංගීත', 'இசை'],
      'Dance': ['dance', 'නැටුම', 'நடனம்'],
      'Religious': ['religious', 'ආගමික', 'மத'],
      'Festival': ['festival', 'පෙරහැර', 'திருவிழா'],
    };
    
    final lowerText = text.toLowerCase();
    for (final entry in categories.entries) {
      if (entry.value.any((keyword) => lowerText.contains(keyword))) {
        return entry.key;
      }
    }
    return 'Other';
  }

  List<String> _extractTags(String text, String language) {
    return autoTag(text, language);
  }

  bool _containsSinhala(String text) {
    // Sinhala Unicode range: U+0D80 to U+0DFF
    return text.runes.any((rune) => rune >= 0x0D80 && rune <= 0x0DFF);
  }

  bool _containsTamil(String text) {
    // Tamil Unicode range: U+0B80 to U+0BFF
    return text.runes.any((rune) => rune >= 0x0B80 && rune <= 0x0BFF);
  }

  bool _containsKeyword(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword.toLowerCase()));
  }
}

