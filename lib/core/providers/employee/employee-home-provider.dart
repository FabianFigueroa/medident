import 'package:flutter/material.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/services/employee/employee-home-service.dart';

class EmployeeHomeProvider with ChangeNotifier {
  final EmployeeHomeService _service;
  final String userId;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _dashboardData = {};
  List<Map<String, dynamic>> _turnos = [];
  List<Map<String, dynamic>> _alerts = [];
  List<ProductModel> _globalPromotions = [];

  EmployeeHomeProvider({
    required this.userId,
    EmployeeHomeService? service,
  }) : _service = service ?? EmployeeHomeService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboardData => _dashboardData;
  List<Map<String, dynamic>> get turnos => _turnos;
  List<Map<String, dynamic>> get alerts => _alerts;
  List<ProductModel> get globalPromotions => _globalPromotions;

  Future<void> loadInitialData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getEmployeeDashboard(userId),
        _service.getTurnos(userId),
        _service.getAlerts(userId),
        _service.getGlobalPromotions(),
      ]);
      _dashboardData = results[0] as Map<String, dynamic>;
      _turnos = results[1] as List<Map<String, dynamic>>;
      _alerts = results[2] as List<Map<String, dynamic>>;
      _globalPromotions = results[3] as List<ProductModel>;
    } catch (e) {
      _error = e.toString();
      debugPrint('EmployeeHomeProvider.loadInitialData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
