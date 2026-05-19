import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminShopsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getShopsOverview() async {
    try {
      final shopsSnap = await _firestore.collection('shops').get();
      final pendingSnap = await _firestore.collection('shops').where('status', isEqualTo: 'pending').get();
      return {
        'totalShops': shopsSnap.docs.length,
        'pendingApprovals': pendingSnap.docs.length,
        'activeShops': 0,
        'totalProducts': 0,
      };
    } catch (e) {
      debugPrint('AdminShopsService.getShopsOverview error: $e');
      return {'totalShops': 0, 'pendingApprovals': 0, 'activeShops': 0, 'totalProducts': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getPendingShops() async {
    try {
      final snap = await _firestore.collection('shops').where('status', isEqualTo: 'pending').limit(20).get();
      return snap.docs.map((d) { final data = d.data(); data['id'] = d.id; return data; }).toList();
    } catch (e) {
      debugPrint('AdminShopsService.getPendingShops error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getActiveShops() async {
    try {
      final snap = await _firestore.collection('shops').where('status', isEqualTo: 'active').limit(20).get();
      return snap.docs.map((d) { final data = d.data(); data['id'] = d.id; return data; }).toList();
    } catch (e) {
      debugPrint('AdminShopsService.getActiveShops error: $e');
      return [];
    }
  }

  Future<void> approveShop(String shopId) async {
    try {
      await _firestore.collection('shops').doc(shopId).update({'status': 'active'});
    } catch (e) {
      debugPrint('AdminShopsService.approveShop error: $e');
    }
  }

  Future<void> rejectShop(String shopId) async {
    try {
      await _firestore.collection('shops').doc(shopId).update({'status': 'rejected'});
    } catch (e) {
      debugPrint('AdminShopsService.rejectShop error: $e');
    }
  }
}
