import '../../models/event_model.dart';

/// Multi-Language NLP Service for English, Sinhala, and Tamil
/// Provides text classification, sentiment analysis, and semantic search
class MultiLanguageNLPService {
  // Language detection patterns
  static final Map<String, RegExp> languagePatterns = {
    'si': RegExp(r'[\u0D80-\u0DFF]'), // Sinhala Unicode range
    'ta': RegExp(r'[\u0B80-\u0BFF]'), // Tamil Unicode range
    'en': RegExp(r'^[a-zA-Z\s]+$'), // English only
  };

  // Event category keywords for each language
  static const Map<String, Map<String, List<String>>> categoryKeywords = {
    'music': {
      'en': ['concert', 'music', 'band', 'singer', 'performance', 'live music', 'show', 'DJ', 'orchestra'],
      'si': ['සංගීත', 'ගායනා', 'සංගීතය', 'ප්‍රසංගය', 'සජීවී'],
      'ta': ['இசை', 'பாட்டு', 'நிகழ்ச்சி', 'கச்சேரி'],
    },
    'cultural': {
      'en': ['cultural', 'traditional', 'heritage', 'festival', 'ceremony', 'ritual', 'celebration'],
      'si': ['සංස්කෘතික', 'සාම්ප්‍රදායික', 'උරුමය', 'උත්සවය', 'සැමරුම'],
      'ta': ['கலாச்சாரம்', 'பாரம்பரிய', 'திருவிழா', 'விழா'],
    },
    'religious': {
      'en': ['religious', 'temple', 'church', 'mosque', 'kovil', 'prayer', 'worship', 'poya', 'pilgrimage'],
      'si': ['ආගමික', 'පන්සල', 'දේවාලය', 'පල්ලිය', 'පූජා', 'පොය', 'වන්දනාව'],
      'ta': ['மத', 'கோவில்', 'பள்ளி', 'வழிபாடு', 'புனித'],
    },
    'sports': {
      'en': ['sports', 'game', 'tournament', 'match', 'championship', 'athletic', 'competition', 'race'],
      'si': ['ක්‍රීඩා', 'තරගය', 'තරඟාවලිය', 'තරඟය'],
      'ta': ['விளையாட்டு', 'போட்டி', 'விளையாட்டுப் போட்டி'],
    },
    'food': {
      'en': ['food', 'culinary', 'cuisine', 'cooking', 'restaurant', 'dining', 'taste', 'chef'],
      'si': ['ආහාර', 'කෑම', 'ආපන', 'පිසීම', 'රසකැවිලි'],
      'ta': ['உணவு', 'சமையல்', 'உணவகம்', 'சுவை'],
    },
    'art': {
      'en': ['art', 'exhibition', 'gallery', 'painting', 'sculpture', 'artist', 'creative', 'craft'],
      'si': ['කලාව', 'ප්‍රදර්ශනය', 'චිත්‍ර', 'ශිල්පය', 'ශිල්පී'],
      'ta': ['கலை', 'கண்காட்சி', 'ஓவியம்', 'சிற்பம்'],
    },
    'education': {
      'en': ['education', 'workshop', 'seminar', 'training', 'lecture', 'learning', 'class', 'course'],
      'si': ['අධ්‍යාපන', 'පුහුණු', 'වැඩමුළු', 'දේශනය', 'පන්ති'],
      'ta': ['கல்வி', 'பயிற்சி', 'கருத்தரங்கு', 'வகுப்பு'],
    },
    'entertainment': {
      'en': ['entertainment', 'movie', 'cinema', 'theater', 'drama', 'comedy', 'magic', 'circus'],
      'si': ['විනෝදාත්මක', 'චිත්‍රපට', 'නාට්‍ය', 'රංග', 'හාස්‍යය'],
      'ta': ['பொழுதுபோக்கு', 'திரைப்படம்', 'நாடகம்', 'நகைச்சுவை'],
    },
  };

  // Sentiment keywords for multi-language sentiment analysis
  static const Map<String, Map<String, List<String>>> sentimentKeywords = {
    'positive': {
      'en': ['amazing', 'excellent', 'great', 'wonderful', 'fantastic', 'awesome', 'beautiful', 'perfect', 'love', 'best'],
      'si': ['අපූරු', 'විශිෂ්ට', 'හොඳ', 'ලස්සන', 'සුන්දර', 'ප්‍රශංසනීය'],
      'ta': ['அருமை', 'சிறப்பு', 'நல்ல', 'அழகான', 'சிறந்த'],
    },
    'negative': {
      'en': ['bad', 'terrible', 'awful', 'poor', 'disappointing', 'worst', 'boring', 'waste'],
      'si': ['නරක', 'අමනාප', 'අසතුටුදායක', 'නිෂ්ඵල'],
      'ta': ['மோசம்', 'கெட்ட', 'ஏமாற்றம்', 'மோசமான'],
    },
  };

  /// Detect language of text
  String detectLanguage(String text) {
    if (text.isEmpty) return 'en';

    // Check for Sinhala
    if (languagePatterns['si']!.hasMatch(text)) return 'si';

    // Check for Tamil
    if (languagePatterns['ta']!.hasMatch(text)) return 'ta';

    // Default to English
    return 'en';
  }

  /// Get text in user's preferred language
  String getLocalizedText(EventModel event, String language) {
    switch (language) {
      case 'si':
        return event.titleSi ?? event.title;
      case 'ta':
        return event.titleTa ?? event.title;
      default:
        return event.title;
    }
  }

  /// Classify event into categories using NLP
  List<String> classifyEvent(EventModel event, {String? language}) {
    final lang = language ?? detectLanguage(event.title);
    final text = '${event.title} ${event.description}'.toLowerCase();
    final categories = <String>[];

    categoryKeywords.forEach((category, keywords) {
      final langKeywords = keywords[lang] ?? keywords['en']!;
      
      for (final keyword in langKeywords) {
        if (text.contains(keyword.toLowerCase())) {
          categories.add(category);
          break;
        }
      }
    });

    return categories.isEmpty ? ['general'] : categories;
  }

  /// Analyze sentiment of text (for reviews/ratings)
  Map<String, dynamic> analyzeSentiment(String text, {String? language}) {
    final lang = language ?? detectLanguage(text);
    final lowerText = text.toLowerCase();

    int positiveScore = 0;
    int negativeScore = 0;

    // Count positive keywords
    final positiveWords = sentimentKeywords['positive']![lang] ?? 
                          sentimentKeywords['positive']!['en']!;
    for (final word in positiveWords) {
      if (lowerText.contains(word.toLowerCase())) {
        positiveScore++;
      }
    }

    // Count negative keywords
    final negativeWords = sentimentKeywords['negative']![lang] ?? 
                          sentimentKeywords['negative']!['en']!;
    for (final word in negativeWords) {
      if (lowerText.contains(word.toLowerCase())) {
        negativeScore++;
      }
    }

    // Calculate sentiment score (-1 to 1)
    final total = positiveScore + negativeScore;
    final sentiment = total == 0 
        ? 0.0 
        : (positiveScore - negativeScore) / total;

    return {
      'sentiment': sentiment,
      'label': sentiment > 0.2 ? 'positive' : (sentiment < -0.2 ? 'negative' : 'neutral'),
      'positiveScore': positiveScore,
      'negativeScore': negativeScore,
      'confidence': total > 0 ? (positiveScore > negativeScore ? positiveScore / total : negativeScore / total) : 0.0,
    };
  }

  /// Calculate semantic similarity between two texts
  /// Uses Jaccard similarity on word sets
  double calculateTextSimilarity(String text1, String text2, {String? language}) {
    final lang = language ?? detectLanguage(text1);
    
    // Tokenize
    final words1 = _tokenize(text1, lang);
    final words2 = _tokenize(text2, lang);

    if (words1.isEmpty || words2.isEmpty) return 0.0;

    // Calculate Jaccard similarity
    final intersection = words1.toSet().intersection(words2.toSet());
    final union = words1.toSet().union(words2.toSet());

    return union.isEmpty ? 0.0 : intersection.length / union.length;
  }

  /// Multi-language semantic search
  List<EventModel> semanticSearch(
    String query,
    List<EventModel> events, {
    String? language,
    int maxResults = 20,
  }) {
    final lang = language ?? detectLanguage(query);
    final scoredEvents = <MapEntry<EventModel, double>>[];

    for (final event in events) {
      double score = 0.0;

      // Get event text in appropriate language
      final eventTitle = getLocalizedText(event, lang);
      final eventDesc = lang == 'si' 
          ? (event.descriptionSi ?? event.description)
          : lang == 'ta'
              ? (event.descriptionTa ?? event.description)
              : event.description;

      // Title similarity (weighted higher)
      score += calculateTextSimilarity(query, eventTitle, language: lang) * 3.0;

      // Description similarity
      score += calculateTextSimilarity(query, eventDesc, language: lang) * 1.5;

      // Category match
      if (event.category.toLowerCase().contains(query.toLowerCase()) ||
          query.toLowerCase().contains(event.category.toLowerCase())) {
        score += 2.0;
      }

      // Tag matching
      for (final tag in event.tags) {
        final tagSimilarity = calculateTextSimilarity(query, tag, language: lang);
        score += tagSimilarity * 1.0;
      }

      // Location match
      final eventLocation = lang == 'si'
          ? (event.locationSi ?? event.location)
          : lang == 'ta'
              ? (event.locationTa ?? event.location)
              : event.location;
      
      if (eventLocation.toLowerCase().contains(query.toLowerCase())) {
        score += 1.5;
      }

      if (score > 0) {
        scoredEvents.add(MapEntry(event, score));
      }
    }

    // Sort by score and return top results
    scoredEvents.sort((a, b) => b.value.compareTo(a.value));
    return scoredEvents
        .take(maxResults)
        .map((e) => e.key)
        .toList();
  }

  /// Extract keywords from text
  List<String> extractKeywords(String text, {String? language, int maxKeywords = 10}) {
    final lang = language ?? detectLanguage(text);
    final words = _tokenize(text, lang);

    // Count word frequencies
    final wordFreq = <String, int>{};
    for (final word in words) {
      if (word.length > 2) { // Ignore very short words
        wordFreq[word] = (wordFreq[word] ?? 0) + 1;
      }
    }

    // Sort by frequency and return top keywords
    final sortedWords = wordFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedWords
        .take(maxKeywords)
        .map((e) => e.key)
        .toList();
  }

  /// Assess translation quality by comparing keyword overlap
  double assessTranslationQuality(String original, String translation) {
    final origLang = detectLanguage(original);
    final transLang = detectLanguage(translation);

    if (origLang == transLang) return 0.0; // Same language

    // Check if key information is preserved
    // For multi-language, we check if the translation has similar category classifications
    final origCategories = classifyEvent(
      EventModel(
        id: 'temp',
        title: original,
        description: original,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        location: '',
        category: '',
        organizerId: '',
        organizerName: '',
        isApproved: true,
        isSpam: false,
        spamScore: 0,
        trustScore: 100,
        submittedAt: DateTime.now(),
      ),
      language: origLang,
    );

    final transCategories = classifyEvent(
      EventModel(
        id: 'temp',
        title: translation,
        description: translation,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        location: '',
        category: '',
        organizerId: '',
        organizerName: '',
        isApproved: true,
        isSpam: false,
        spamScore: 0,
        trustScore: 100,
        submittedAt: DateTime.now(),
      ),
      language: transLang,
    );

    // Calculate category overlap
    final categoryOverlap = origCategories.toSet().intersection(transCategories.toSet()).length;
    final categoryUnion = origCategories.toSet().union(transCategories.toSet()).length;

    return categoryUnion > 0 ? categoryOverlap / categoryUnion : 0.5;
  }

  /// Generate search suggestions
  List<String> generateSearchSuggestions(
    String partial,
    List<EventModel> events, {
    String? language,
    int maxSuggestions = 5,
  }) {
    final lang = language ?? detectLanguage(partial);
    final suggestions = <String>{};

    // Add category suggestions
    categoryKeywords.forEach((category, keywords) {
      final langKeywords = keywords[lang] ?? keywords['en']!;
      for (final keyword in langKeywords) {
        if (keyword.toLowerCase().startsWith(partial.toLowerCase())) {
          suggestions.add(keyword);
        }
      }
    });

    // Add event titles that match
    for (final event in events) {
      final title = getLocalizedText(event, lang);
      if (title.toLowerCase().contains(partial.toLowerCase())) {
        suggestions.add(title);
      }

      // Add matching tags
      for (final tag in event.tags) {
        if (tag.toLowerCase().contains(partial.toLowerCase())) {
          suggestions.add(tag);
        }
      }
    }

    return suggestions.take(maxSuggestions).toList();
  }

  /// Tokenize text based on language
  List<String> _tokenize(String text, String language) {
    final cleaned = text.toLowerCase().trim();
    
    // Basic tokenization (split on whitespace and punctuation)
    // Using double quotes inside raw string to avoid escaping issues
    final tokens = cleaned.split(RegExp(r"[\s.,;!?(){}\[\]""']+"));
    
    // Remove empty tokens and common stop words
    final stopWords = _getStopWords(language);
    
    return tokens
        .where((token) => token.isNotEmpty && !stopWords.contains(token))
        .toList();
  }

  /// Get stop words for language
  Set<String> _getStopWords(String language) {
    switch (language) {
      case 'si':
        return {'සහ', 'හා', 'මෙම', 'එම', 'ඔබ', 'මම', 'අප'};
      case 'ta':
        return {'மற்றும்', 'இந்த', 'அந்த', 'நான்', 'நாம்'};
      default:
        return {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'is', 'are', 'was', 'were'};
    }
  }

  /// Generate text embedding vector (simplified TF-IDF approach)
  Map<String, double> generateTextEmbedding(String text, {String? language}) {
    final lang = language ?? detectLanguage(text);
    final words = _tokenize(text, lang);
    final embedding = <String, double>{};

    // Calculate term frequency
    final totalWords = words.length.toDouble();
    for (final word in words) {
      embedding[word] = (embedding[word] ?? 0) + (1.0 / totalWords);
    }

    return embedding;
  }

  /// Calculate cosine similarity between embeddings
  double cosineSimilarity(Map<String, double> embedding1, Map<String, double> embedding2) {
    final allKeys = {...embedding1.keys, ...embedding2.keys};
    
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (final key in allKeys) {
      final val1 = embedding1[key] ?? 0.0;
      final val2 = embedding2[key] ?? 0.0;
      
      dotProduct += val1 * val2;
      norm1 += val1 * val1;
      norm2 += val2 * val2;
    }

    if (norm1 == 0 || norm2 == 0) return 0.0;
    
    return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
  }
}

// Math helper
class Math {
  static double sqrt(double x) => x.isNaN ? 0.0 : (x < 0 ? 0.0 : _sqrt(x));
  
  static double _sqrt(double x) {
    if (x == 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
}
