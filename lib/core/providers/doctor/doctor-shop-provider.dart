import 'package:flutter/material.dart';
import 'package:medident/core/services/doctor/doctor-shop-service.dart';

class DoctorShopProvider with ChangeNotifier {
  final DoctorShopService _service;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _promotions = [];
  bool _isLoading = false;
  String? _error;

  DoctorShopProvider({required DoctorShopService service}) : _service = service;

  List<Map<String, dynamic>> get products => _products;
  List<Map<String, dynamic>> get promotions => _promotions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _service.getActiveProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPromotions() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _promotions = await _service.getActivePromotions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
