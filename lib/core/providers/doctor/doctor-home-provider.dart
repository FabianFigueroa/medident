import 'package:flutter/material.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/services/doctor/doctor-home-service.dart';

class DoctorHomeProvider with ChangeNotifier {
  final DoctorHomeService _service;
  final String userId;

  Map<String, dynamic> _dashboardData = {};
  List<ProductModel> _globalPromotions = [];
  bool _isLoading = false;
  String? _error;

  DoctorHomeProvider({
    required DoctorHomeService service,
    required this.userId,
  }) : _service = service;

  Map<String, dynamic> get dashboardData => _dashboardData;
  List<ProductModel> get globalPromotions => _globalPromotions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadInitialData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getDashboard(userId),
        _service.getGlobalPromotions(),
      ]);
      _dashboardData = results[0] as Map<String, dynamic>;
      _globalPromotions = results[1] as List<ProductModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
