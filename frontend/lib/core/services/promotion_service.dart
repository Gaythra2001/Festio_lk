import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/promotion_model.dart';

class PromotionService {
  FirebaseFirestore? _firestoreInstance;

  // Demo mode storage
  final List<PromotionModel> _localPromotions = [];

  FirebaseFirestore? get _firestore {
    if (!useFirebase) return null;
    _firestoreInstance ??= FirebaseFirestore.instance;
    return _firestoreInstance;
  }

  static const String _collection = 'promotions';

  Future<List<PromotionModel>> list() async {
    if (!useFirebase) {
      // Return active or scheduled first
      final list = [..._localPromotions];
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
    try {
      final snapshot = await _firestore!.collection(_collection).get();
      return snapshot.docs.map((d) => PromotionModel.fromMap(d.data())).toList();
    } catch (e) {
      debugPrint('❌ list promotions: $e');
      return [];
    }
  }

  Future<void> save(PromotionModel p) async {
    if (!useFirebase) {
      _localPromotions.removeWhere((e) => e.id == p.id);
      _localPromotions.add(p);
      return;
    }
    try {
      await _firestore!.collection(_collection).doc(p.id).set(p.toMap());
    } catch (e) {
      debugPrint('❌ save promotion: $e');
      rethrow;
    }
  }
}
