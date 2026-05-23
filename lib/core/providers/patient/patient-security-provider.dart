import 'package:flutter/material.dart';
import 'package:medident/core/services/patient/patient-security-service.dart';

class PatientSecurityProvider with ChangeNotifier {
  final PatientSecurityService _service;
  final String userId;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _securityData = {};

  PatientSecurityProvider({
    required this.userId,
    PatientSecurityService? service,
  }) : _service = service ?? PatientSecurityService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get securityData => _securityData;

  Future<void> initialize() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final logs = await _service.getAccessLogs(userId);
      _securityData = {'accessLogs': logs};
    } catch (e) {
      _error = e.toString();
      debugPrint('PatientSecurityProvider.initialize error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
