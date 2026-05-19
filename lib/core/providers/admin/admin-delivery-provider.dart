import 'package:flutter/material.dart';
import 'package:medident/core/services/admin/admin-delivery-service.dart';

class AdminDeliveryProvider with ChangeNotifier {
  final AdminDeliveryService _service;
  final String userId;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _deliveryStats = {};
  List<Map<String, dynamic>> _pendingDeliveries = [];
  List<Map<String, dynamic>> _activeRiders = [];
  List<Map<String, dynamic>> _deliveryHistory = [];

  AdminDeliveryProvider({required this.userId, AdminDeliveryService? service}) : _service = service ?? AdminDeliveryService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get deliveryStats => _deliveryStats;
  List<Map<String, dynamic>> get pendingDeliveries => _pendingDeliveries;
  List<Map<String, dynamic>> get activeRiders => _activeRiders;
  List<Map<String, dynamic>> get deliveryHistory => _deliveryHistory;

  Future<void> loadInitialData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getDeliveryStats(),
        _service.getPendingDeliveries(),
        _service.getActiveRiders(),
        _service.getDeliveryHistory(),
      ]);
      _deliveryStats = results[0] as Map<String, dynamic>;
      _pendingDeliveries = results[1] as List<Map<String, dynamic>>;
      _activeRiders = results[2] as List<Map<String, dynamic>>;
      _deliveryHistory = results[3] as List<Map<String, dynamic>>;
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminDeliveryProvider.loadInitialData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    _error = null;
    notifyListeners();
    await loadInitialData();
  }
}
