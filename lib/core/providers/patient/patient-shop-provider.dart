import 'package:flutter/material.dart';
import 'package:medident/core/services/patient/patient-shop-service.dart';

class PatientShopProvider with ChangeNotifier {
  final PatientShopService _service;
  final String userId;

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _promotions = [];

  PatientShopProvider({
    required this.userId,
    PatientShopService? service,
  }) : _service = service ?? PatientShopService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get products => _products;
  List<Map<String, dynamic>> get promotions => _promotions;

  Future<void> loadProducts() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _service.getProducts();
    } catch (e) {
      _error = e.toString();
      debugPrint('PatientShopProvider.loadProducts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPromotions() async {
    try {
      _promotions = await _service.getPromotions();
      notifyListeners();
    } catch (e) {
      debugPrint('PatientShopProvider.loadPromotions error: $e');
    }
  }
}
