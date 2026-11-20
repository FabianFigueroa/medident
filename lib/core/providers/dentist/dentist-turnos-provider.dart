import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/models/turno-model.dart';
import 'package:medident/core/services/agenda-service.dart';

/// Sub-provider de la sección "Mis turnos laborales" del dentista.
///
/// Escucha en tiempo real la colección `turnos` filtrando por el
/// `employeeId` del usuario y expone estadísticas/agrupaciones para la UI.
class DentistTurnosProvider extends ChangeNotifier {
  final String userId;
  final AgendaService _service;
  StreamSubscription<List<TurnoModel>>? _sub;
  final Set<String> _sentReminders = {};

  List<TurnoModel> _turnos = const [];
  bool _isLoading = true;
  String? _error;
  bool _disposed = false;

  DentistTurnosProvider({required this.userId, AgendaService? service})
      : _service = service ?? AgendaService() {
    _subscribe();
  }

  List<TurnoModel> get turnos => _turnos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get todayCount =>
      _turnos.where((t) => t.isToday).length;

  int get upcomingCount =>
      _turnos.where((t) => t.isUpcoming).length;

  int get activeCount => _turnos
      .where((t) => t.status == 'active' || t.status == 'scheduled')
      .length;

  List<TurnoModel> byDay(DateTime day) {
    return _turnos
        .where((t) =>
            t.date.year == day.year &&
            t.date.month == day.month &&
            t.date.day == day.day)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<TurnoModel> byWeek(DateTime weekStart) {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));
    return _turnos
        .where((t) {
          final d = DateTime(t.date.year, t.date.month, t.date.day);
          return !d.isBefore(start) && d.isBefore(end);
        })
        .toList()
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : a.startTime.compareTo(b.startTime);
      });
  }

  Map<String, int> get dayCounts {
    final map = <String, int>{};
    for (final t in _turnos) {
      final key = '${t.date.year}_${t.date.month}_${t.date.day}';
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  TurnoModel? nextTurno() {
    final now = DateTime.now();
    final upcoming = _turnos
        .where((t) =>
            t.isToday ||
            DateTime(t.date.year, t.date.month, t.date.day).isAfter(
              DateTime(now.year, now.month, now.day),
            ))
        .toList();
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// Pull-to-refresh: reinicia la escucha en tiempo real de turnos.
  void refresh() => _subscribe();

  Future<void> confirmAttendance(TurnoModel turno) {
    return _service.setTurnoAttendance(
      turnoId: turno.id,
      employeeId: turno.employeeId,
      employeeName: turno.employeeName,
      attendanceStatus: 'confirmed',
      clinicId: turno.clinicId,
      notifyUserId: turno.dentistId,
    );
  }

  Future<void> declineAttendance(TurnoModel turno, {String? reason}) {
    return _service.setTurnoAttendance(
      turnoId: turno.id,
      employeeId: turno.employeeId,
      employeeName: turno.employeeName,
      attendanceStatus: 'declined',
      reason: reason,
      clinicId: turno.clinicId,
      notifyUserId: turno.dentistId,
    );
  }

  Future<void> requestNovedad(TurnoModel turno, String details) {
    return _service.requestTurnoChange(
      turnoId: turno.id,
      employeeId: turno.employeeId,
      employeeName: turno.employeeName,
      type: 'novedad',
      details: details,
      clinicId: turno.clinicId,
    );
  }

  void _scheduleReminders(List<TurnoModel> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final turno in list) {
      if (turno.attendanceStatus != 'pending') continue;
      final day = DateTime(turno.date.year, turno.date.month, turno.date.day);
      final diff = day.difference(today).inDays;
      if (diff < 0) continue;
      if (diff == 0 && !turno.reminderDaySent) {
        if (_sentReminders.add('${turno.id}_day')) {
          _service.ensureAttendanceReminder(turno: turno, kind: 'day');
        }
      } else if (diff > 0 && diff <= 7 && !turno.reminderWeekSent) {
        if (_sentReminders.add('${turno.id}_week')) {
          _service.ensureAttendanceReminder(turno: turno, kind: 'week');
        }
      }
    }
  }

  void _subscribe() {
    _sub?.cancel();
    _isLoading = true;
    _notify();
    _sub = _service.streamTurnosByEmployee(userId).listen(
      (list) {
        _turnos = list;
        _isLoading = false;
        _error = null;
        _scheduleReminders(list);
        _notify();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        _notify();
      },
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}
