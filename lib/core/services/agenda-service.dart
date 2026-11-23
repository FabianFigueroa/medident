import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/turno-model.dart';
import 'package:medident/core/models/turno-request-model.dart';
import 'package:medident/core/services/clinic-service.dart' show validateHorario;

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

  // ==================== TURNOS (EMPLEADOS) ====================

  Future<List<TurnoModel>> getTurnos({required String dentistId, int limit = 10}) async {
    try {
      final snap = await _firestore.collection('turnos')
          .where('dentistId', isEqualTo: dentistId)
          .orderBy('date', descending: false)
          .limit(limit)
          .get();
      return snap.docs.map((d) => TurnoModel.fromJson(d.data(), d.id)).toList();
    } catch (e) {
      debugPrint('getTurnos: $e');
      return [];
    }
  }

  /// Stream en tiempo real de los turnos laborales de un empleado/dentista.
  /// Se ordena en memoria para no depender de índices compuestos.
  Stream<List<TurnoModel>> streamTurnosByEmployee(String employeeId) {
    if (employeeId.isEmpty) return Stream.value(const []);
    return _firestore
        .collection('turnos')
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => TurnoModel.fromJson(d.data(), d.id))
          .toList()
        ..sort((a, b) {
          final byDate = a.date.compareTo(b.date);
          return byDate != 0 ? byDate : a.startTime.compareTo(b.startTime);
        });
      return list;
    });
  }

  Future<String> createTurno({
    required String dentistId,
    required String employeeId,
    required String employeeName,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? notes,
  }) async {
    final ref = _firestore.collection('turnos').doc();
    await ref.set({
      'dentistId': dentistId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'status': 'scheduled',
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateTurnoStatus(String turnoId, String status) async {
    await _firestore.collection('turnos').doc(turnoId).update({'status': status});
  }

  Future<void> setTurnoAttendance({
    required String turnoId,
    required String employeeId,
    required String employeeName,
    required String attendanceStatus,
    String? reason,
    String? clinicId,
    String? notifyUserId,
  }) async {
    await _firestore.collection('turnos').doc(turnoId).update({
      'attendanceStatus': attendanceStatus,
      'attendanceAt': FieldValue.serverTimestamp(),
      if (reason != null && reason.trim().isNotEmpty) 'attendanceNote': reason.trim(),
    });

    final targetId = (notifyUserId != null && notifyUserId.isNotEmpty)
        ? notifyUserId
        : await _clinicOwnerId(clinicId);
    if (targetId == null || targetId.isEmpty || targetId == employeeId) return;

    final label = attendanceStatus == 'confirmed'
        ? 'confirmó su asistencia'
        : 'declinó su asistencia';
    await _firestore.collection('notifications').add({
      'userId': targetId,
      'type': 'turno',
      'title': attendanceStatus == 'confirmed'
          ? 'Asistencia confirmada'
          : 'Asistencia declinada',
      'body': '$employeeName $label'
          '${reason != null && reason.trim().isNotEmpty ? ': ${reason.trim()}' : ''}',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> ensureAttendanceReminder({
    required TurnoModel turno,
    required String kind,
  }) async {
    final isWeek = kind == 'week';
    if (isWeek ? turno.reminderWeekSent : turno.reminderDaySent) return;
    await _firestore.collection('turnos').doc(turno.id).update({
      isWeek ? 'reminderWeekSent' : 'reminderDaySent': true,
    });
    await _firestore.collection('notifications').add({
      'userId': turno.employeeId,
      'type': 'turno',
      'title': isWeek
          ? 'Tu turno está cerca'
          : 'Hoy tienes turno',
      'body': isWeek
          ? 'Tienes un turno el ${turno.displayDate} de ${turno.startTime} a ${turno.endTime}. Confirma tu asistencia.'
          : 'Tu turno de hoy empieza a las ${turno.startTime}. Confirma o declina tu asistencia.',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> _clinicOwnerId(String? clinicId) async {
    if (clinicId == null || clinicId.isEmpty) return null;
    try {
      final clinicDoc = await _firestore.collection('clinics').doc(clinicId).get();
      return clinicDoc.data()?['ownerId'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> requestTurnoChange({
    required String turnoId,
    required String employeeId,
    required String employeeName,
    required String type,
    required String details,
    String? clinicId,
    String? targetEmployeeId,
    String? targetEmployeeName,
    String? targetTurnoId,
    DateTime? requestedDate,
    String? requestedStartTime,
    String? requestedEndTime,
  }) async {
    await _firestore.collection('turno_requests').add({
      'turnoId': turnoId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'type': type,
      'details': details,
      'status': 'pending',
      'targetEmployeeId': targetEmployeeId,
      'targetEmployeeName': targetEmployeeName,
      'targetTurnoId': targetTurnoId,
      if (requestedDate != null)
        'requestedDate': Timestamp.fromDate(requestedDate),
      'requestedStartTime': requestedStartTime,
      'requestedEndTime': requestedEndTime,
      if (clinicId != null && clinicId.isNotEmpty) 'clinicId': clinicId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final typeLabel = switch (type) {
      'cambio_horario' => 'solicitud de cambio de horario',
      'cambio_turno' => 'solicitud de cambio de turno',
      'intercambio' => 'solicitud de intercambio de turno',
      _ => 'novedad',
    };

    // Avisar al dueño de la clínica para que revise la solicitud.
    final ownerId = await _clinicOwnerId(clinicId);
    if (ownerId != null && ownerId.isNotEmpty && ownerId != employeeId) {
      await _sendNotification(
        userId: ownerId,
        title: 'Nueva $typeLabel',
        body: '$employeeName envió una $typeLabel'
            '${targetEmployeeName != null && targetEmployeeName.isNotEmpty ? ' con $targetEmployeeName' : ''}',
      );
    }

    // Avisar al empleado implicado en un cambio/intercambio.
    if (targetEmployeeId != null &&
        targetEmployeeId.isNotEmpty &&
        targetEmployeeId != employeeId) {
      await _sendNotification(
        userId: targetEmployeeId,
        title: 'Te proponen un intercambio',
        body: '$employeeName quiere intercambiar o cambiar un turno contigo. Revisa la solicitud.',
      );
    }
  }

  Future<void> _sendNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'type': 'system',
      'title': title,
      'body': body,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRequestStatus(String requestId, String status, String employeeId) async {
    final requestRef = _firestore.collection('turno_requests').doc(requestId);
    await requestRef.update({
      'status': status,
      'resolvedAt': FieldValue.serverTimestamp(),
    });

    // Al aprobar un cambio de horario se aplica el horario pedido al turno
    // (antes solo cambiaba el estado de la solicitud y el turno seguía igual).
    if (status == 'approved') {
      final data = (await requestRef.get()).data();
      if (data != null && data['type'] == 'cambio_horario') {
        final turnoId = data['turnoId'] as String?;
        final start = data['requestedStartTime'] as String?;
        final end = data['requestedEndTime'] as String?;
        if (turnoId != null && turnoId.isNotEmpty && start != null && end != null &&
            validateHorario(start, end) == null) {
          await _firestore.collection('turnos').doc(turnoId).update({
            'startTime': start,
            'endTime': end,
            if (data['requestedDate'] is Timestamp) 'date': data['requestedDate'],
            // El horario cambió: la asistencia se vuelve a confirmar.
            'attendanceStatus': 'pending',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    // Send notification
    await _firestore.collection('notifications').add({
      'userId': employeeId,
      'type': 'system',
      'title': 'Solicitud de Turno',
      'body': status == 'approved'
          ? 'Tu solicitud fue aprobada'
          : status == 'rejected'
              ? 'Tu solicitud fue rechazada'
              : 'Tu solicitud ha sido: $status',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<TurnoRequestModel>> streamTurnoRequests({
    String? employeeId,
    String? clinicId,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection('turno_requests');
    if (employeeId != null && employeeId.isNotEmpty) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }
    if (clinicId != null && clinicId.isNotEmpty) {
      query = query.where('clinicId', isEqualTo: clinicId);
    }
    // Sin orderBy para evitar índices compuestos; se ordena en memoria.
    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => TurnoRequestModel.fromJson(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<String> createReel({required String userId, required String videoUrl, String? description}) async {
    final ref = _firestore.collection('reels').doc();
    await ref.set({
      'userId': userId,
      'videoUrl': videoUrl,
      'description': description,
      'likesCount': 0,
      'commentsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
