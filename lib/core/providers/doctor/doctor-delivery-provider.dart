import 'package:flutter/material.dart';
import 'package:medident/core/services/doctor/doctor-delivery-service.dart';

class DoctorDeliveryProvider with ChangeNotifier {
  final String userId;
  final DoctorDeliveryService _service;

  List<Map<String, dynamic>> _deliveries = [];
  bool _isLoading = false;
  String? _error;
  bool _isSubmitting = false;

  DoctorDeliveryProvider({
    required this.userId,
    DoctorDeliveryService? service,
  }) : _service = service ?? DoctorDeliveryService();

  List<Map<String, dynamic>> get deliveries => _deliveries;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Map<String, int> get stats {
    return {
      'pending': _deliveries.where((d) => (d['status'] ?? '') == 'pending').length,
      'active': _deliveries
          .where((d) => ['accepted', 'inTransit'].contains((d['status'] ?? '')))
          .length,
      'delivered': _deliveries.where((d) => (d['status'] ?? '') == 'delivered').length,
      'cancelled': _deliveries.where((d) => (d['status'] ?? '') == 'cancelled').length,
    };
  }

  Future<void> loadDeliveries() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deliveries = await _service.getDeliveries(userId: userId);
    } catch (e) {
      _error = e.toString();
      debugPrint('DoctorDeliveryProvider.loadDeliveries error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitDeliveryRequest({
    required String doctorName,
    required String patientName,
    required String patientAddress,
    required String items,
    double total = 0,
  }) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createDeliveryRequest(
        doctorId: userId,
        doctorName: doctorName,
        patientName: patientName,
        patientAddress: patientAddress,
        items: items,
        total: total,
      );
      await loadDeliveries();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('DoctorDeliveryProvider.submitDeliveryRequest error: $e');
      notifyListeners();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> cancelDelivery(String deliveryId) async {
    try {
      await _service.cancelDelivery(deliveryId);
      await loadDeliveries();
    } catch (e) {
      _error = e.toString();
      debugPrint('DoctorDeliveryProvider.cancelDelivery error: $e');
      notifyListeners();
    }
  }
}
