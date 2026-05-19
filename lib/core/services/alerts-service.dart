import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/alert-model.dart';

/// Servicio para gestionar alertas de seguridad (collection: alerts)
class AlertsService {
  final CollectionReference _alertsCollection =
      FirebaseFirestore.instance.collection('alerts');

  /// Crear nueva alerta
  Future<void> createAlert(AlertModel alert) async {
    await _alertsCollection.doc(alert.id).set(alert.toMap());
  }

  /// Obtener alertas en tiempo real
  Stream<List<AlertModel>> getAlertsStream(String userId) {
    return _alertsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final alerts =
              snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList();
          alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return alerts;
        });
  }

  /// Obtener alertas no leídas
  Stream<List<AlertModel>> getUnreadAlertsStream(String userId) {
    return _alertsCollection
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final alerts =
              snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList();
          alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return alerts;
        });
  }

  /// Marcar alerta como leída
  Future<void> markAsRead(String alertId) async {
    await _alertsCollection.doc(alertId).update({'read': true});
  }

  /// Marcar alerta como manejada
  Future<void> markAsHandled(String alertId, String handledBy) async {
    await _alertsCollection.doc(alertId).update({
      'handled': true,
      'handledBy': handledBy,
    });
  }

  /// Obtener conteo de no leídas
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _alertsCollection
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  /// Eliminar alerta
  Future<void> deleteAlert(String alertId) async {
    await _alertsCollection.doc(alertId).delete();
  }

  /// Obtener alertas por tipo
  Future<List<AlertModel>> getAlertsByType(String userId, String type) async {
    try {
      final snapshot = await _alertsCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .get();

      final alerts = snapshot.docs
          .map((doc) => AlertModel.fromFirestore(doc))
          .toList();
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return alerts.take(100).toList();
    } catch (e) {
      debugPrint('getAlertsByType: $e');
      return [];
    }
  }
}
