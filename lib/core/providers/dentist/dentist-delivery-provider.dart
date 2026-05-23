import 'package:flutter/material.dart';
import 'package:medident/core/services/dentist/dentist-delivery-service.dart';

class DentistDeliveryProvider with ChangeNotifier {
  final String userId;
  final DentistDeliveryService _service = DentistDeliveryService();

  List<Map<String, dynamic>> _deliveries = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;

  DentistDeliveryProvider({required this.userId});

  List<Map<String, dynamic>> get deliveries => _deliveries;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDeliveries() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deliveries = await _service.getDeliveries();
      _computeStats();
    } catch (e) {
      _error = e.toString();
      debugPrint('DentistDeliveryProvider.loadDeliveries error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDeliveryStatus(String deliveryId, String status) async {
    try {
      await _service.updateDeliveryStatus(deliveryId, status);
      await loadDeliveries();
    } catch (e) {
      _error = e.toString();
      debugPrint('DentistDeliveryProvider.updateDeliveryStatus error: $e');
      notifyListeners();
    }
  }

  void _computeStats() {
    final total = _deliveries.length;
    final pending = _deliveries.where((d) => d['status'] == 'pending').length;
    final accepted = _deliveries.where((d) => d['status'] == 'accepted').length;
    final completed = _deliveries.where((d) => d['status'] == 'completed').length;

    _stats = {
      'total': total,
      'pending': pending,
      'accepted': accepted,
      'completed': completed,
    };
  }
}
