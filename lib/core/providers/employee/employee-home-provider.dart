import 'package:flutter/material.dart';
import 'package:medident/core/services/employee/employee-home-service.dart';

class EmployeeHomeProvider with ChangeNotifier {
  final EmployeeHomeService _service;
  final String userId;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _dashboardData = {};

  EmployeeHomeProvider({
    required this.userId,
    EmployeeHomeService? service,
  }) : _service = service ?? EmployeeHomeService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboardData => _dashboardData;

  Future<void> loadInitialData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _service.getEmployeeDashboard(userId);
    } catch (e) {
      _error = e.toString();
      debugPrint('EmployeeHomeProvider.loadInitialData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
