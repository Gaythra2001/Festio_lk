import '../../models/event_model.dart';
import 'multi_language_nlp_service.dart';

/// Advanced Text Classification Service
/// Automatically categorizes and tags events using ML techniques
class TextClassifierService {
  final MultiLanguageNLPService _nlpService = MultiLanguageNLPService();

  /// Auto-classify event and suggest categories
  Map<String, dynamic> classifyEvent(EventModel event) {
    final language = _nlpService.detectLanguage(event.title);

    // Get suggested categories
    final suggestedCategories =
        _nlpService.classifyEvent(event, language: language);

    // Extract keywords for tagging
    final titleKeywords = _nlpService.extractKeywords(event.title,
        language: language, maxKeywords: 5);
    final descKeywords = _nlpService.extractKeywords(event.description,
        language: language, maxKeywords: 10);

    // Combine and deduplicate keywords
    final allKeywords = <String>{...titleKeywords, ...descKeywords}.toList();

    // Calculate confidence scores for each category
    final categoryScores = <String, double>{};
    for (final category in suggestedCategories) {
      categoryScores[category] =
          _calculateCategoryConfidence(event, category, language);
    }

    return {
      'primaryCategory': suggestedCategories.isNotEmpty
          ? suggestedCategories.first
          : 'general',
      'allCategories': suggestedCategories,
      'categoryScores': categoryScores,
      'suggestedTags': allKeywords,
      'detectedLanguage': language,
      'confidence': categoryScores.values.isEmpty
          ? 0.0
          : categoryScores.values.reduce((a, b) => a > b ? a : b),
    };
  }

  /// Calculate confidence score for category classification
  double _calculateCategoryConfidence(
      EventModel event, String category, String language) {
    final text = '${event.title} ${event.description}'.toLowerCase();
    final keywords =
        MultiLanguageNLPService.categoryKeywords[category]?[language] ?? [];

    if (keywords.isEmpty) return 0.0;

    int matchCount = 0;
    for (final keyword in keywords) {
      if (text.contains(keyword.toLowerCase())) {
        matchCount++;
      }
    }

    return matchCount / keywords.length;
  }

  /// Validate and improve event translations
  Map<String, dynamic> validateTranslations(EventModel event) {
    final results = <String, dynamic>{};

    // Check Sinhala translation
    if (event.titleSi != null && event.titleSi!.isNotEmpty) {
      final siQuality =
          _nlpService.assessTranslationQuality(event.title, event.titleSi!);
      results['sinhalaQuality'] = siQuality;
      results['sinhalaScore'] = (siQuality * 100).round();
    }

    // Check Tamil translation
    if (event.titleTa != null && event.titleTa!.isNotEmpty) {
      final taQuality =
          _nlpService.assessTranslationQuality(event.title, event.titleTa!);
      results['tamilQuality'] = taQuality;
      results['tamilScore'] = (taQuality * 100).round();
    }

    // Overall translation quality
    final scores = <double>[];
    if (results.containsKey('sinhalaQuality'))
      scores.add(results['sinhalaQuality']);
    if (results.containsKey('tamilQuality'))
      scores.add(results['tamilQuality']);

    results['overallQuality'] =
        scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;
    results['needsImprovement'] = results['overallQuality'] < 0.5;

    return results;
  }

  /// Generate smart tags for event
  List<String> generateSmartTags(EventModel event, {int maxTags = 8}) {
    final classification = classifyEvent(event);
    final suggestedTags = classification['suggestedTags'] as List<String>;
    final categories = classification['allCategories'] as List<String>;

    // Combine category-based tags and keyword-based tags
    final allTags = <String>{};

    // Add categories as tags
    allTags.addAll(categories);

    // Add extracted keywords
    allTags.addAll(suggestedTags.take(maxTags - categories.length));

    // Add location-based tag
    if (event.location.isNotEmpty) {
      final locationWords = event.location.split(' ');
      if (locationWords.isNotEmpty) {
        allTags.add(locationWords.first.toLowerCase());
      }
    }

    return allTags.take(maxTags).toList();
  }

  /// Detect spam or inappropriate content
  Map<String, dynamic> detectSpam(EventModel event) {
    final text = '${event.title} ${event.description}'.toLowerCase();

    // Spam indicators
    final spamKeywords = [
      'free money', 'click here', 'buy now', 'limited offer', 'act now',
      'winner', 'congratulations', 'claim', 'prize', 'lottery',
      // Sinhala spam indicators
      'නොමිලේ', 'ත්‍යාගය', 'ජයග්‍රහණය',
      // Tamil spam indicators
      'இலவசம்', 'பரிசு', 'வெற்றி',
    ];

    int spamScore = 0;
    final foundSpamWords = <String>[];

    for (final keyword in spamKeywords) {
      if (text.contains(keyword.toLowerCase())) {
        spamScore += 10;
        foundSpamWords.add(keyword);
      }
    }

    // Excessive capitalization
    final caps = RegExp(r'[A-Z]').allMatches(event.title).length;
    if (caps > event.title.length * 0.5 && event.title.length > 10) {
      spamScore += 15;
    }

    // Excessive punctuation
    final punctuation = RegExp(r'[!?.]').allMatches(text).length;
    if (punctuation > 10) {
      spamScore += 10;
    }

    // Suspicious URLs or contact info in inappropriate places
    if (RegExp(r'http[s]?://|www\.|\.com|\.lk').hasMatch(event.title)) {
      spamScore += 20;
    }

    return {
      'isSpam': spamScore > 30,
      'spamScore': spamScore.clamp(0, 100),
      'confidence': (spamScore / 100).clamp(0.0, 1.0),
      'spamIndicators': foundSpamWords,
      'severity': spamScore > 60 ? 'high' : (spamScore > 30 ? 'medium' : 'low'),
    };
  }

  /// Analyze event description quality
  Map<String, dynamic> analyzeContentQuality(EventModel event) {
    final descLength = event.description.length;
    int qualityScore = 0;
    final issues = <String>[];
    final suggestions = <String>[];

    // Length check
    if (descLength < 50) {
      issues.add('Description too short');
      suggestions.add('Add more details about the event');
      qualityScore -= 20;
    } else if (descLength > 100) {
      qualityScore += 20;
    }

    // Multi-language check
    final hasEnglish = event.title.isNotEmpty;
    final hasSinhala = event.titleSi != null && event.titleSi!.isNotEmpty;
    final hasTamil = event.titleTa != null && event.titleTa!.isNotEmpty;

    int langCount =
        (hasEnglish ? 1 : 0) + (hasSinhala ? 1 : 0) + (hasTamil ? 1 : 0);

    if (langCount >= 2) {
      qualityScore += 30;
    } else {
      suggestions.add('Add translations in Sinhala and Tamil');
    }

    // Has tags
    if (event.tags.isNotEmpty) {
      qualityScore += 15;
    } else {
      issues.add('No tags added');
      suggestions.add('Add relevant tags for better discoverability');
    }

    // Has location details
    if (event.location.length > 10) {
      qualityScore += 15;
    } else {
      suggestions.add('Provide detailed location information');
    }

    // Has image
    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      qualityScore += 20;
    } else {
      issues.add('No image provided');
      suggestions.add('Add an attractive event image');
    }

    qualityScore = qualityScore.clamp(0, 100);

    return {
      'qualityScore': qualityScore,
      'grade': qualityScore >= 80
          ? 'A'
          : (qualityScore >= 60 ? 'B' : (qualityScore >= 40 ? 'C' : 'D')),
      'issues': issues,
      'suggestions': suggestions,
      'multiLanguageSupport': langCount >= 2,
      'completeness': (qualityScore / 100).clamp(0.0, 1.0),
    };
  }
}
