import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DoctorDeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Entregas creadas por este médico. Filtrado en cliente para evitar
  /// índices compuestos (where doctorId + orderBy createdAt).
  Future<List<Map<String, dynamic>>> getDeliveries({required String userId}) async {
    try {
      final snap = await _firestore
          .collection('deliveries')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snap.docs
          .map((d) {
            final data = d.data();
            data['id'] = d.id;
            return data;
          })
          .where((d) => ((d['doctorId'] ?? '').toString()) == userId)
          .toList();
    } catch (e) {
      debugPrint('DoctorDeliveryService.getDeliveries error: $e');
      rethrow;
    }
  }

  /// El médico solicita un envío (medicamentos/insumos) hacia un paciente.
  Future<void> createDeliveryRequest({
    required String doctorId,
    required String doctorName,
    required String patientName,
    required String patientAddress,
    required String items,
    double total = 0,
  }) async {
    try {
      await _firestore.collection('deliveries').add({
        'doctorId': doctorId,
        'doctorName': doctorName,
        'patientName': patientName,
        'patientAddress': patientAddress,
        'items': items.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'total': total,
        'origin': 'doctor',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('DoctorDeliveryService.createDeliveryRequest error: $e');
      rethrow;
    }
  }

  Future<void> cancelDelivery(String deliveryId) async {
    try {
      await _firestore.collection('deliveries').doc(deliveryId).update({
        'status': 'cancelled',
        'cancelledBy': 'doctor',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('DoctorDeliveryService.cancelDelivery error: $e');
      rethrow;
    }
  }
}
