import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PatientDeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Consulta las entregas sin filtros server-side para evitar índices
  /// compuestos (where + orderBy exige índice en Firestore) y filtra en el
  /// cliente por los campos que la app escribe al crear un pedido:
  /// `patientId` (si existe) o `patientName` como respaldo.
  Future<Map<String, dynamic>> getDeliveries({required String userId, String? patientName}) async {
    try {
      final snap = await _firestore
          .collection('deliveries')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final all = snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();

      final nameKey = patientName?.trim().toLowerCase() ?? '';

      final own = all.where((d) {
        final id = (d['patientId'] ?? '').toString();
        if (id.isNotEmpty) return id == userId;
        final name = (d['patientName'] ?? '').toString().toLowerCase();
        return nameKey.isNotEmpty && name == nameKey;
      }).toList();

      return {
        'own': own,
        'recent': all,
      };
    } catch (e) {
      debugPrint('PatientDeliveryService.getDeliveries error: $e');
      rethrow;
    }
  }

  Future<void> cancelDelivery(String deliveryId) async {
    try {
      await _firestore.collection('deliveries').doc(deliveryId).update({
        'status': 'cancelled',
        'cancelledBy': 'patient',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('PatientDeliveryService.cancelDelivery error: $e');
      rethrow;
    }
  }

  /// Confirma la recepción de una entrega en tránsito/aceptada por el paciente.
  Future<void> confirmReceived(String deliveryId) async {
    try {
      await _firestore.collection('deliveries').doc(deliveryId).update({
        'status': 'delivered',
        'confirmedAt': FieldValue.serverTimestamp(),
        'confirmedByPatient': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('PatientDeliveryService.confirmReceived error: $e');
      rethrow;
    }
  }
}
