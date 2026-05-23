import 'package:flutter/material.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/services/patient/patient-home-service.dart';

class PatientHomeProvider with ChangeNotifier {
  final PatientHomeService _service;
  final String userId;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _dashboardData = {};
  List<ProductModel> _globalPromotions = [];

  PatientHomeProvider({
    required this.userId,
    PatientHomeService? service,
  }) : _service = service ?? PatientHomeService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboardData => _dashboardData;
  List<ProductModel> get globalPromotions => _globalPromotions;

  Future<void> loadInitialData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _service.getDashboard(userId);
      _globalPromotions = (_dashboardData['globalPromotions'] as List<ProductModel>?) ?? [];
    } catch (e) {
      _error = e.toString();
      debugPrint('PatientHomeProvider.loadInitialData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
