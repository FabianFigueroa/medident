import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/models/appointment-model.dart';
import 'package:medident/core/models/patient-model.dart';
import 'package:medident/core/providers/domain/appointment-provider.dart';
import 'package:medident/core/services/domain/appointment-service.dart';
import 'package:medident/core/services/patient-service.dart';

/// Define qué citas se consideran "propias" para el rol que consume la agenda.
enum AgendaScope {
  /// Citas asignadas al usuario o solicitudes pendientes sin asignar.
  dentist,

  /// Todas las citas de la clínica (empleados con permiso de agenda).
  clinic,

  /// Citas del paciente autenticado.
  patient,
}

/// Sub-provider de la sección "Mi agenda" del dentista.
///
/// Mantiene en tiempo real las citas de la clínica (a través de
/// [AppointmentProvider] + [IAppointmentService]) y los pacientes de la
/// clínica. Expone estadísticas y filtros listos para la UI.
class DentistAgendaProvider extends ChangeNotifier {
  final String userId;
  final String clinicId;
  final AgendaScope scope;
  final AppointmentProvider _appointments;
  final PatientService _patientService;
  StreamSubscription<List<PatientModel>>? _patientsSub;

  List<PatientModel> _patients = const [];
  bool _patientsLoaded = false;
  String? _patientsError;
  bool _disposed = false;

  DentistAgendaProvider({
    required this.userId,
    required this.clinicId,
    required IAppointmentService appointmentService,
    PatientService? patientService,
    this.scope = AgendaScope.dentist,
  })  : _appointments = AppointmentProvider(service: appointmentService),
        _patientService = patientService ?? PatientService() {
    _appointments.addListener(_onAppointmentsChanged);
    if (clinicId.isNotEmpty) {
      _subscribePatients();
    } else {
      _patientsLoaded = true;
    }
  }

  // ── Estado básico ─────────────────────────────────────────────────
  List<AppointmentModel> get appointments => _appointments.appointments;
  List<PatientModel> get patients => _patients;
  bool get isLoading => _appointments.isLoading && !_patientsLoaded;
  bool get isLoadingPatients => !_patientsLoaded;
  String? get error => _appointments.error ?? _patientsError;
  AppointmentProvider get appointmentProvider => _appointments;
  bool get hasClinic => clinicId.isNotEmpty;

  /// Citas propias del rol + solicitudes pendientes sin asignar.
  /// Se ordenan por fecha ascendente.
  List<AppointmentModel> get mine {
    late final List<AppointmentModel> list;
    switch (scope) {
      case AgendaScope.patient:
        list = appointments.where((a) => a.patientId == userId).toList();
        break;
      case AgendaScope.clinic:
        list = appointments.toList();
        break;
      case AgendaScope.dentist:
        list = appointments
            .where((a) =>
                a.dentistId == userId ||
                (a.status == 'pending' && a.dentistId.isEmpty))
            .toList();
        break;
    }
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Solicitudes de cita pendientes.
  List<AppointmentModel> get pendingRequests =>
      mine.where((a) => a.status == 'pending').toList();

  /// Solicitudes de usuarios externos (sin historia en la clínica).
  List<AppointmentModel> get requesters {
    if (scope == AgendaScope.patient) return const [];
    final knownIds = _patients.map((p) => p.id).toSet();
    final result = <AppointmentModel>[];
    for (final a in pendingRequests) {
      if (a.patientId.isEmpty || knownIds.contains(a.patientId)) continue;
      if (result.any((r) => r.patientId == a.patientId)) continue;
      result.add(a);
    }
    return result;
  }

  int get todayCount {
    final now = DateTime.now();
    return mine
        .where((a) =>
            a.date.year == now.year &&
            a.date.month == now.month &&
            a.date.day == now.day)
        .length;
  }

  int get pendingCount => mine.where((a) => a.status != 'confirmed').length;

  int get uniquePatientsCount => mine.map((a) => a.patientId).toSet().length;

  List<AppointmentModel> byDay(DateTime day) {
    return mine
        .where((a) =>
            a.date.year == day.year &&
            a.date.month == day.month &&
            a.date.day == day.day)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<AppointmentModel> byWeek(DateTime weekStart) {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));
    return mine
        .where((a) {
          final d = DateTime(a.date.year, a.date.month, a.date.day);
          return !d.isBefore(start) && d.isBefore(end);
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Map<String, int> get dayCounts {
    final map = <String, int>{};
    for (final a in mine) {
      final key = '${a.date.year}_${a.date.month}_${a.date.day}';
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  PatientModel? patientById(String? id) {
    if (id == null) return null;
    for (final p in _patients) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> updateStatus(String appointmentId, String status) =>
      _appointments.updateStatus(appointmentId, status);

  Future<void> deleteAppointment(String appointmentId) =>
      _appointments.deleteAppointment(appointmentId);

  /// Pull-to-refresh: reinicia los streams de citas y pacientes.
  Future<void> refresh() async {
    _appointments.refresh();
    _patientsLoaded = false;
    _notify();
    if (clinicId.isNotEmpty) _subscribePatients();
  }

  void _subscribePatients() {
    _patientsSub?.cancel();
    _patientsSub = _patientService.streamPatientsByClinic(clinicId).listen(
      (list) {
        _patients = list;
        _patientsLoaded = true;
        _patientsError = null;
        _notify();
      },
      onError: (e) {
        _patientsLoaded = true;
        _patientsError = e.toString();
        _notify();
      },
    );
  }

  void _onAppointmentsChanged() => _notify();

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _appointments.removeListener(_onAppointmentsChanged);
    _patientsSub?.cancel();
    _appointments.dispose();
    super.dispose();
  }
}
