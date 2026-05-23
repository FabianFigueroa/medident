import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PatientShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final snap = await _firestore.collection('products').where('isActive', isEqualTo: true).limit(20).get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('PatientShopService.getProducts error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPromotions() async {
    try {
      final snap = await _firestore.collection('promotions').where('isActive', isEqualTo: true).limit(10).get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('PatientShopService.getPromotions error: $e');
      return [];
    }
  }
}
