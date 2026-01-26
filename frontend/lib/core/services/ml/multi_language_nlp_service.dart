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
      'en': ['sports', 'game', 'match', 'tournament', 'cricket', 'football', 'competition', 'championship'],
      'si': ['ක්‍රීඩා', 'තරඟය', 'තරග', 'ක්‍රිකට්', 'පාපන්දු'],
      'ta': ['விளையாட்டு', 'போட்டி', 'கிரிக்கெட்', 'கால்பந்து'],
    },
    'food': {
      'en': ['food', 'cuisine', 'restaurant', 'dining', 'culinary', 'taste', 'cooking', 'festival'],
      'si': ['ආහාර', 'රසකැවිලි', 'ආපනශාලාව', 'කෑම', 'උත්සවය'],
      'ta': ['உணவு', 'சமையல்', 'உணவகம்', 'உணவு திருவிழா'],
    },
    'art': {
      'en': ['art', 'exhibition', 'gallery', 'painting', 'sculpture', 'craft', 'design', 'creative'],
      'si': ['කලාව', 'ප්‍රදර්ශනය', 'චිත්‍ර', 'ශිල්පය', 'නිර්මාණ'],
      'ta': ['கலை', 'கண்காட்சி', 'ஓவியம்', 'சிற்பம்', 'வடிவமைப்பு'],
    },
    'education': {
      'en': ['education', 'workshop', 'seminar', 'training', 'conference', 'learning', 'class', 'lecture'],
      'si': ['අධ්‍යාපන', 'වැඩමුළුව', 'සම්මන්ත්‍රණය', 'පුහුණුව', 'ඉගෙනීම'],
      'ta': ['கல்வி', 'பட்டறை', 'கருத்தரங்கு', 'பயிற்சி', 'மாநாடு'],
    },
    'entertainment': {
      'en': ['entertainment', 'comedy', 'movie', 'show', 'performance', 'theater', 'drama', 'cinema'],
      'si': ['විනෝදාත්මක', 'හාස්‍ය', 'චිත්‍රපටය', 'නාට්‍ය', 'ප්‍රදර්ශනය'],
      'ta': ['பொழுதுபோக்கு', 'நகைச்சுவை', 'திரைப்படம்', 'நாடகம்', 'நிகழ்ச்சி'],
    },
  };

  // Sentiment keywords
  static const Map<String, Map<String, List<String>>> sentimentKeywords = {
    'positive': {
      'en': ['amazing', 'excellent', 'great', 'wonderful', 'fantastic', 'awesome', 'beautiful', 'perfect', 'loved', 'enjoyed'],
      'si': ['අපූරු', 'විශිෂ්ට', 'ලස්සන', 'හොඳ', 'සුන්දර', 'ප්‍රශස්ත'],
      'ta': ['அருமை', 'சிறப்பு', 'அழகான', 'நல்ல', 'சிறந்த'],
    },
    'negative': {
      'en': ['bad', 'terrible', 'awful', 'disappointing', 'poor', 'boring', 'waste', 'horrible'],
      'si': ['නරක', 'අප්‍රසන්න', 'කාලය නාස්ති', 'දුර්වල'],
      'ta': ['மோசம்', 'மோசமான', 'ஏமாற்றம்', 'வீண்'],
    },
  };

  /// Detect the language of input text
  String detectLanguage(String text) {
    if (text.isEmpty) return 'en';

    // Check for Sinhala
    if (languagePatterns['si']!.hasMatch(text)) {
      return 'si';
    }

    // Check for Tamil
    if (languagePatterns['ta']!.hasMatch(text)) {
      return 'ta';
    }

    // Default to English
    return 'en';
  }

  /// Classify event into categories based on keywords
  List<String> classifyEvent(EventModel event, {String? language}) {
    final lang = language ?? detectLanguage(event.description);
    final matchedCategories = <String>[];

    final searchText =
        '${event.title.toLowerCase()} ${event.description.toLowerCase()} ${event.tags.join(' ').toLowerCase()}';

    for (final category in categoryKeywords.keys) {
      final keywords = categoryKeywords[category]?[lang] ?? [];

      for (final keyword in keywords) {
        if (searchText.contains(keyword.toLowerCase())) {
          matchedCategories.add(category);
          break;
        }
      }
    }

    return matchedCategories.isEmpty ? ['entertainment'] : matchedCategories;
  }

  /// Analyze sentiment of text
  Map<String, dynamic> analyzeSentiment(String text, {String? language}) {
    final lang = language ?? detectLanguage(text);
    final lowerText = text.toLowerCase();

    int positiveScore = 0;
    int negativeScore = 0;

    // Count positive keywords
    final positiveKeywords = sentimentKeywords['positive']?[lang] ?? [];
    for (final keyword in positiveKeywords) {
      if (lowerText.contains(keyword.toLowerCase())) {
        positiveScore++;
      }
    }

    // Count negative keywords
    final negativeKeywords = sentimentKeywords['negative']?[lang] ?? [];
    for (final keyword in negativeKeywords) {
      if (lowerText.contains(keyword.toLowerCase())) {
        negativeScore++;
      }
    }

    // Calculate sentiment
    final totalScore = positiveScore + negativeScore;
    String sentiment;
    double sentimentValue;

    if (totalScore == 0) {
      sentiment = 'neutral';
      sentimentValue = 0.0;
    } else {
      final positiveRatio = positiveScore / totalScore;
      if (positiveRatio > 0.6) {
        sentiment = 'positive';
        sentimentValue = positiveRatio;
      } else if (positiveRatio < 0.4) {
        sentiment = 'negative';
        sentimentValue = -1 * (negativeScore / totalScore);
      } else {
        sentiment = 'neutral';
        sentimentValue = 0.0;
      }
    }

    return {
      'label': sentiment,
      'sentiment': sentimentValue,
      'positiveCount': positiveScore,
      'negativeCount': negativeScore,
      'confidence': totalScore > 0 ? totalScore / 10.0 : 0.0,
    };
  }

  /// Semantic search using text similarity
  List<EventModel> semanticSearch(
    String query,
    List<EventModel> events, {
    String? language,
    int maxResults = 20,
  }) {
    final lang = language ?? detectLanguage(query);
    final results = <Map<String, dynamic>>[];

    for (final event in events) {
      double score = 0.0;

      // Calculate similarity score
      final similarity = calculateTextSimilarity(
        query,
        '${event.title} ${event.description}',
        language: lang,
      );
      score += similarity * 3.0; // Title/description match weighted heavily

      // Category match
      final eventCategories = classifyEvent(event, language: lang);
      for (final category in eventCategories) {
        final categoryWords = categoryKeywords[category]?[lang] ?? [];
        for (final word in categoryWords) {
          if (query.toLowerCase().contains(word.toLowerCase())) {
            score += 2.0;
          }
        }
      }

      // Tag match
      for (final tag in event.tags) {
        if (query.toLowerCase().contains(tag.toLowerCase()) ||
            tag.toLowerCase().contains(query.toLowerCase())) {
          score += 1.5;
        }
      }

      // Location match
      if (event.location.toLowerCase().contains(query.toLowerCase())) {
        score += 1.0;
      }

      if (score > 0) {
        results.add({'event': event, 'score': score});
      }
    }

    // Sort by score descending
    results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return results
        .take(maxResults)
        .map((r) => r['event'] as EventModel)
        .toList();
  }

  /// Calculate text similarity using Jaccard similarity
  double calculateTextSimilarity(String text1, String text2, {String? language}) {
    final lang = language ?? detectLanguage(text1);

    final tokens1 = _tokenize(text1, lang);
    final tokens2 = _tokenize(text2, lang);

    if (tokens1.isEmpty || tokens2.isEmpty) return 0.0;

    final set1 = tokens1.toSet();
    final set2 = tokens2.toSet();

    final intersection = set1.intersection(set2).length;
    final union = set1.union(set2).length;

    return union > 0 ? intersection / union : 0.0;
  }

  /// Extract keywords from text
  List<String> extractKeywords(String text, {String? language, int maxKeywords = 10}) {
    final lang = language ?? detectLanguage(text);
    final tokens = _tokenize(text, lang);

    // Count frequency
    final frequency = <String, int>{};
    for (final token in tokens) {
      frequency[token] = (frequency[token] ?? 0) + 1;
    }

    // Sort by frequency
    final sortedKeywords = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedKeywords
        .take(maxKeywords)
        .map((e) => e.key)
        .toList();
  }

  /// Assess translation quality
  double assessTranslationQuality(String original, String translation) {
    final origLang = detectLanguage(original);
    final transLang = detectLanguage(translation);

    if (origLang == transLang) return 0.0; // Same language

    // Check if key information is preserved
    // For multi-language, we check if the translation has similar category classifications
    final now = DateTime.now();
    final origCategories = classifyEvent(
      EventModel(
        id: 'temp',
        title: original,
        description: original,
        category: '',
        startDate: now,
        endDate: now,
        location: '',
        organizerId: '',
        organizerName: '',
        submittedAt: now,
        tags: [],
        isApproved: false,
        isSpam: false,
        spamScore: 0.0,
        trustScore: 0,
      ),
      language: origLang,
    );

    final transCategories = classifyEvent(
      EventModel(
        id: 'temp',
        title: translation,
        description: translation,
        category: '',
        startDate: now,
        endDate: now,
        location: '',
        organizerId: '',
        organizerName: '',
        submittedAt: now,
        tags: [],
        isApproved: false,
        isSpam: false,
        spamScore: 0.0,
        trustScore: 0,
      ),
      language: transLang,
    );

    // Calculate overlap
    final origSet = origCategories.toSet();
    final transSet = transCategories.toSet();
    final intersection = origSet.intersection(transSet).length;
    final union = origSet.union(transSet).length;

    return union > 0 ? intersection / union : 0.0;
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
    for (final category in categoryKeywords.keys) {
      final keywords = categoryKeywords[category]?[lang] ?? [];
      for (final keyword in keywords) {
        if (keyword.toLowerCase().startsWith(partial.toLowerCase())) {
          suggestions.add(keyword);
        }
      }
    }

    // Add from event titles
    for (final event in events) {
      if (event.title.toLowerCase().contains(partial.toLowerCase())) {
        suggestions.add(event.title);
      }
    }

    // Add from tags
    for (final event in events) {
      for (final tag in event.tags) {
        if (tag.toLowerCase().startsWith(partial.toLowerCase())) {
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

  /// Calculate TF-IDF embeddings
  Map<String, double> calculateTFIDF(String text, List<String> corpus) {
    final tokens = _tokenize(text, detectLanguage(text));
    final tf = <String, double>{};
    final idf = <String, double>{};

    // Calculate term frequency
    for (final token in tokens) {
      tf[token] = (tf[token] ?? 0) + 1;
    }

    // Normalize TF
    final maxFreq = tf.values.isEmpty ? 1 : tf.values.reduce((a, b) => a > b ? a : b);
    for (final key in tf.keys) {
      tf[key] = tf[key]! / maxFreq;
    }

    // Calculate IDF
    for (final token in tf.keys) {
      int documentCount = 0;
      for (final doc in corpus) {
        if (doc.toLowerCase().contains(token)) {
          documentCount++;
        }
      }
      idf[token] = documentCount > 0
          ? (corpus.length / documentCount).clamp(1.0, 10.0)
          : 1.0;
    }

    // Calculate TF-IDF
    final tfidf = <String, double>{};
    for (final token in tf.keys) {
      tfidf[token] = tf[token]! * idf[token]!;
    }

    return tfidf;
  }

  /// Calculate cosine similarity between two TF-IDF vectors
  double cosineSimilarity(Map<String, double> vec1, Map<String, double> vec2) {
    if (vec1.isEmpty || vec2.isEmpty) return 0.0;

    final allKeys = {...vec1.keys, ...vec2.keys};
    double dotProduct = 0.0;
    double magnitude1 = 0.0;
    double magnitude2 = 0.0;

    for (final key in allKeys) {
      final val1 = vec1[key] ?? 0.0;
      final val2 = vec2[key] ?? 0.0;

      dotProduct += val1 * val2;
      magnitude1 += val1 * val1;
      magnitude2 += val2 * val2;
    }

    magnitude1 = magnitude1.isFinite ? magnitude1 : 0.0;
    magnitude2 = magnitude2.isFinite ? magnitude2 : 0.0;

    final denominator = (magnitude1 * magnitude2);
    if (denominator == 0) return 0.0;

    return dotProduct / denominator;
  }
}
