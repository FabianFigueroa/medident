import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/models/appointment-model.dart';
import 'package:medident/core/services/domain/appointment-service.dart';

class AppointmentProvider extends ChangeNotifier {
  final IAppointmentService _service;
  StreamSubscription<List<AppointmentModel>>? _sub;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  String? _error;

  AppointmentProvider({required IAppointmentService service}) : _service = service {
    _subscribe();
  }

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get todayAppointmentsCount {
    final now = DateTime.now();
    return _appointments.where((a) =>
      a.date.year == now.year &&
      a.date.month == now.month &&
      a.date.day == now.day
    ).length;
  }

  int get uniquePatientsCount {
    return _appointments.map((a) => a.patientId).toSet().length;
  }

  int get pendingAppointmentsCount {
    return _appointments.where((a) => a.status != 'confirmed').length;
  }

  List<AppointmentModel> getByDate(DateTime date) {
    return _appointments.where((a) =>
      a.date.year == date.year &&
      a.date.month == date.month &&
      a.date.day == date.day
    ).toList();
  }

  List<AppointmentModel> getUpcoming() {
    return _appointments.where((a) =>
      a.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))
    ).toList();
  }

  void _subscribe() {
    _sub?.cancel();
    _isLoading = true;
    notifyListeners();
    _sub = _service.streamAppointments().listen(
      (list) {
        _appointments = list;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<String> bookAppointment({
    String? clinicId,
    required String patientId,
    required String patientName,
    required String dentistId,
    String? dentistName,
    required String treatmentName,
    required DateTime date,
    required String timeSlot,
    String? patientPhoto,
    String? notes,
  }) {
    return _service.bookAppointment(
      clinicId: clinicId,
      patientId: patientId,
      patientName: patientName,
      dentistId: dentistId,
      dentistName: dentistName,
      treatmentName: treatmentName,
      date: date,
      timeSlot: timeSlot,
      patientPhoto: patientPhoto,
      notes: notes,
    );
  }

  Future<void> updateStatus(String appointmentId, String status) async {
    try {
      await _service.updateAppointmentStatus(appointmentId, status);
      final i = _appointments.indexWhere((a) => a.id == appointmentId);
      if (i != -1) {
        _appointments[i] = _appointments[i].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AppointmentProvider.updateStatus error: $e');
      rethrow;
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _service.deleteAppointment(appointmentId);
      _appointments.removeWhere((a) => a.id == appointmentId);
      notifyListeners();
    } catch (e) {
      debugPrint('AppointmentProvider.delete error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
