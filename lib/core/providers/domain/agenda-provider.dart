import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/services/agenda-service.dart';

class AgendaProvider extends ChangeNotifier {
  final AgendaService _service;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, DayStatus> _dayStatuses = {};
  String _clinicId = '';
  bool _isLoading = false;
  StreamSubscription<Map<String, DayStatus>>? _statusSub;

  AgendaProvider({required AgendaService service}) : _service = service;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  Map<String, DayStatus> get dayStatuses => _dayStatuses;
  String get clinicId => _clinicId;
  bool get isLoading => _isLoading;

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void setSelectedDay(DateTime? day) {
    _selectedDay = day;
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = day;
    _focusedDay = day;
    notifyListeners();
  }

  void initialize(String clinicId) {
    if (clinicId.isEmpty || clinicId == _clinicId) return;
    _clinicId = clinicId;
    _subscribe();
  }

  void _subscribe() {
    _statusSub?.cancel();
    _isLoading = true;
    notifyListeners();
    _statusSub = _service.streamDayStatuses(_clinicId).listen(
      (statuses) {
        _dayStatuses = statuses;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> setDayStatus(DateTime date, DayStatus status) async {
    await _service.setDayStatus(
      clinicId: _clinicId,
      date: date,
      status: status,
    );
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    await _service.updateAppointmentStatus(id, status);
  }

  Future<void> deleteAppointment(String id) async {
    await _service.deleteAppointment(id);
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> data) async {
    await _service.updateAppointment(id, data);
  }

  String dayKey(DateTime d) => '${d.year}_${d.month}_${d.day}';

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }
}
