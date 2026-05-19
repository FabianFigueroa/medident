import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminDeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDeliveryStats() async {
    try {
      final deliveriesSnap = await _firestore.collection('deliveries').get();
      final pendingSnap = await _firestore.collection('deliveries').where('status', isEqualTo: 'pending').get();
      return {
        'totalDeliveries': deliveriesSnap.docs.length,
        'pendingDeliveries': pendingSnap.docs.length,
        'completedToday': 0,
        'activeRiders': 0,
      };
    } catch (e) {
      debugPrint('AdminDeliveryService.getDeliveryStats error: $e');
      return {'totalDeliveries': 0, 'pendingDeliveries': 0, 'completedToday': 0, 'activeRiders': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getPendingDeliveries() async {
    try {
      final snap = await _firestore.collection('deliveries').where('status', isEqualTo: 'pending').limit(20).get();
      return snap.docs.map((d) { final data = d.data(); data['id'] = d.id; return data; }).toList();
    } catch (e) {
      debugPrint('AdminDeliveryService.getPendingDeliveries error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getActiveRiders() async {
    try {
      final snap = await _firestore.collection('riders').where('active', isEqualTo: true).get();
      return snap.docs.map((d) { final data = d.data(); data['id'] = d.id; return data; }).toList();
    } catch (e) {
      debugPrint('AdminDeliveryService.getActiveRiders error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDeliveryHistory() async {
    try {
      final snap = await _firestore.collection('deliveries').orderBy('createdAt', descending: true).limit(20).get();
      return snap.docs.map((d) { final data = d.data(); data['id'] = d.id; return data; }).toList();
    } catch (e) {
      debugPrint('AdminDeliveryService.getDeliveryHistory error: $e');
      return [];
    }
  }
}
