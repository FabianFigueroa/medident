import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum DayStatus {
  free('Libre', Icons.check_circle, Color(0xFF22C55E), Color(0xFFDCFCE7)),
  normal('Normal', Icons.circle, Color(0xFF6B7280), null),
  holiday('Festivo', Icons.celebration, Color(0xFFF59E0B), Color(0xFFFEF3C7)),
  clinicClosed('Cerrado', Icons.lock, Color(0xFFEF4444), Color(0xFFFEE2E2)),
  specialistOff('Sin especialista', Icons.person_off, Color(0xFF8B5CF6), Color(0xFFEDE9FE));

  final String label;
  final IconData icon;
  final Color color;
  final Color? bgColor;
  const DayStatus(this.label, this.icon, this.color, this.bgColor);
}

class AgendaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _statuses =>
      _firestore.collection('day_statuses');

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _firestore.collection('appointments');

  String _dayKey(DateTime d) => '${d.year}_${d.month}_${d.day}';

  Stream<Map<String, DayStatus>> streamDayStatuses(String clinicId) {
    final now = DateTime.now();
    return _statuses
        .where('clinicId', isEqualTo: clinicId)
        .where('date', isGreaterThanOrEqualTo:
            Timestamp.fromDate(DateTime(now.year, now.month, now.day - 30)))
        .where('date', isLessThanOrEqualTo:
            Timestamp.fromDate(DateTime(now.year, now.month, now.day + 90)))
        .snapshots()
        .map((snap) {
      final map = <String, DayStatus>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final statusStr = data['status'] as String?;
        if (statusStr != null) {
          final key = doc.id.replaceFirst('${clinicId}_', '');
          map[key] = DayStatus.values.firstWhere(
            (s) => s.name == statusStr,
            orElse: () => DayStatus.normal,
          );
        }
      }
      return map;
    });
  }

  Future<void> setDayStatus({
    required String clinicId,
    required DateTime date,
    required DayStatus status,
  }) async {
    try {
      final key = _dayKey(date);
      await _statuses.doc('${clinicId}_$key').set({
        'status': status.name,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'clinicId': clinicId,
      });
    } catch (e) {
      debugPrint('AgendaService.setDayStatus error: $e');
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _appointments.doc(appointmentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('AgendaService.updateAppointmentStatus error: $e');
      rethrow;
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _appointments.doc(appointmentId).delete();
    } catch (e) {
      debugPrint('AgendaService.deleteAppointment error: $e');
      rethrow;
    }
  }

  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> data) async {
    try {
      await _appointments.doc(appointmentId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('AgendaService.updateAppointment error: $e');
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAppointmentsByDateRange({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) async {
    var query = _appointments
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end));

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers({int limit = 50}) async {
    return _firestore.collection('users').limit(limit).get();
  }
}
