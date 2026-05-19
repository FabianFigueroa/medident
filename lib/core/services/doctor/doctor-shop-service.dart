import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DoctorShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getActiveProducts() async {
    try {
      final snap = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .limit(20)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('DoctorShopService.getActiveProducts error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getActivePromotions() async {
    try {
      final snap = await _firestore
          .collection('promotions')
          .where('isActive', isEqualTo: true)
          .limit(10)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('DoctorShopService.getActivePromotions error: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamActiveProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> streamActivePromotions() {
    return _firestore
        .collection('promotions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}
