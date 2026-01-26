import 'package:flutter/foundation.dart';
import '../models/promotion_model.dart';
import '../services/promotion_service.dart';
import 'notification_provider.dart';

class PromotionProvider with ChangeNotifier {
  final PromotionService _service = PromotionService();
  final NotificationProvider _notificationProvider;

  PromotionProvider(this._notificationProvider);

  List<PromotionModel> _promotions = [];
  PromotionModel? _current;
  String _selectedLanguage = 'en';
  bool _isLoading = false;
  String? _error;

  List<PromotionModel> get promotions => _promotions;
  PromotionModel? get current => _current;
  String get selectedLanguage => _selectedLanguage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLanguage(String lang) {
    _selectedLanguage = lang;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _promotions = await _service.list();
      _error = null;
    } catch (e) {
      _error = 'Failed to load promotions: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> save(PromotionModel p) async {
    try {
      await _service.save(p);
      await load();
      return true;
    } catch (e) {
      _error = 'Failed to save promotion: $e';
      notifyListeners();
      return false;
    }
  }

  void publish(PromotionModel p, {String iconData = 'campaign'}) {
    // Build notification payload using selected language
    final title = p.localizedTitle[_selectedLanguage] ??
        p.localizedTitle['en'] ??
        'Event Update';
    final message =
        p.localizedMessage[_selectedLanguage] ?? p.localizedMessage['en'] ?? '';
    _notificationProvider.addNotification(
      title: title,
      message: message,
      type: 'promotion',
      iconData: iconData,
      metadata: {
        'eventId': p.eventId,
        'promotionId': p.id,
        'imageUrl': p.imageUrl,
      },
    );
  }
}
