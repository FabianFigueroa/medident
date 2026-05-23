import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/models/alert-model.dart';
import 'package:medident/core/services/doctor/doctor-security-service.dart';

class DoctorSecurityProvider with ChangeNotifier {
  final DoctorSecurityService _service;
  final String userId;

  List<AlertModel> _alerts = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _alertsSubscription;

  DoctorSecurityProvider({
    required DoctorSecurityService service,
    required this.userId,
  }) : _service = service;

  List<AlertModel> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initialize() {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    _alertsSubscription?.cancel();
    _alertsSubscription = _service.streamAlertsByUser(userId).listen(
      (alerts) {
        _alerts = alerts;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> markAlertRead(String alertId) async {
    try {
      await _service.markAlertRead(alertId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    super.dispose();
  }
}
