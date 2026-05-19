import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/rfid-log-model.dart';

/// Servicio para gestionar eventos de lectura RFID (collection: rfid_logs)
class RfidService {
  final CollectionReference _rfidLogsCollection =
      FirebaseFirestore.instance.collection('rfid_logs');

  /// Crear nuevo log de lectura RFID
  Future<void> createRfidLog(RfidLogModel log) async {
    await _rfidLogsCollection.doc(log.id).set(log.toMap());
  }

  /// Obtener logs en tiempo real (stream)
  Stream<List<RfidLogModel>> getRfidLogsStream(String userId) {
    return _rfidLogsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final logs = snapshot.docs.map((doc) => RfidLogModel.fromFirestore(doc)).toList();
          logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return logs;
        });
  }

  /// Obtener logs de hoy
  Future<List<RfidLogModel>> getTodayLogs(String userId) async {
    try {
      final snapshot = await _rfidLogsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final logs = snapshot.docs
          .map((doc) => RfidLogModel.fromFirestore(doc))
          .where((log) =>
              log.timestamp.isAfter(startOfDay) &&
              log.timestamp.isBefore(endOfDay))
          .toList();
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    } catch (e) {
      debugPrint('getTodayLogs: $e');
      return [];
    }
  }

  /// Obtener logs por reader específico
  Future<List<RfidLogModel>> getLogsByReader(String userId, String readerId) async {
    try {
      final snapshot = await _rfidLogsCollection
          .where('userId', isEqualTo: userId)
          .where('readerId', isEqualTo: readerId)
          .get();

      final logs = snapshot.docs
          .map((doc) => RfidLogModel.fromFirestore(doc))
          .toList();
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs.take(50).toList();
    } catch (e) {
      debugPrint('getLogsByReader: $e');
      return [];
    }
  }

  /// Eliminar log (solo admin o usuario)
  Future<void> deleteLog(String logId) async {
    await _rfidLogsCollection.doc(logId).delete();
  }
}
