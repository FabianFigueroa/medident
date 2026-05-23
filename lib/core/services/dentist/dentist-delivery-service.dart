import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DentistDeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getDeliveries() async {
    try {
      final snap = await _firestore
          .collection('deliveries')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('DentistDeliveryService.getDeliveries error: $e');
      return [];
    }
  }

  Future<void> updateDeliveryStatus(String deliveryId, String status) async {
    try {
      await _firestore
          .collection('deliveries')
          .doc(deliveryId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('DentistDeliveryService.updateDeliveryStatus error: $e');
      rethrow;
    }
  }
}
