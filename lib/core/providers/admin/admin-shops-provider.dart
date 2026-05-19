import 'package:flutter/material.dart';
import 'package:medident/core/services/admin/admin-shops-service.dart';

class AdminShopsProvider with ChangeNotifier {
  final AdminShopsService _service;
  final String userId;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _shopsOverview = {};
  List<Map<String, dynamic>> _pendingShops = [];
  List<Map<String, dynamic>> _activeShops = [];

  AdminShopsProvider({required this.userId, AdminShopsService? service}) : _service = service ?? AdminShopsService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get shopsOverview => _shopsOverview;
  List<Map<String, dynamic>> get pendingShops => _pendingShops;
  List<Map<String, dynamic>> get activeShops => _activeShops;

  Future<void> loadInitialData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getShopsOverview(),
        _service.getPendingShops(),
        _service.getActiveShops(),
      ]);
      _shopsOverview = results[0] as Map<String, dynamic>;
      _pendingShops = results[1] as List<Map<String, dynamic>>;
      _activeShops = results[2] as List<Map<String, dynamic>>;
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminShopsProvider.loadInitialData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveShop(String shopId) async {
    await _service.approveShop(shopId);
    await refreshData();
  }

  Future<void> rejectShop(String shopId) async {
    await _service.rejectShop(shopId);
    await refreshData();
  }

  Future<void> refreshData() async {
    _error = null;
    notifyListeners();
    await loadInitialData();
  }
}
