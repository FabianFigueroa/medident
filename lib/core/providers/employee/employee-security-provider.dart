import 'package:flutter/material.dart';
import 'package:medident/core/services/employee/employee-security-service.dart';

class EmployeeSecurityProvider with ChangeNotifier {
  final EmployeeSecurityService _service;
  final String userId;

  Map<String, dynamic>? _securityData;
  bool _isLoading = false;
  String? _error;

  EmployeeSecurityProvider({
    required this.userId,
    EmployeeSecurityService? service,
  }) : _service = service ?? EmployeeSecurityService();

  Map<String, dynamic>? get securityData => _securityData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _securityData = await _service.getSecurityData(userId);
    } catch (e) {
      _error = e.toString();
      debugPrint('EmployeeSecurityProvider.initialize error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
