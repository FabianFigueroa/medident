import 'package:flutter/material.dart';
import 'package:medident/core/services/patient/patient-delivery-service.dart';

class PatientDeliveryProvider with ChangeNotifier {
  final String userId;
  final PatientDeliveryService _service;

  /// Se resuelve desde la pantalla (AuthenticateProvider) porque el
  /// PatientMainProvider solo recibe el userId.
  String patientName;

  List<Map<String, dynamic>> _deliveries = [];
  List<Map<String, dynamic>> _recentDeliveries = [];
  bool _isLoading = false;
  String? _error;

  PatientDeliveryProvider({
    required this.userId,
    this.patientName = '',
    PatientDeliveryService? service,
  }) : _service = service ?? PatientDeliveryService();

  List<Map<String, dynamic>> get deliveries => _deliveries;
  List<Map<String, dynamic>> get recentDeliveries => _recentDeliveries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Cuando el paciente aún no tiene pedidos propios pero hay entregas recientes
  /// en la plataforma (datos demo), se muestran en modo vista general.
  bool get showDemoOverview => _deliveries.isEmpty && _recentDeliveries.isNotEmpty;

  Map<String, int> get stats {
    int countWhere(List<String> statuses) =>
        _deliveries.where((d) => statuses.contains((d['status'] ?? '').toString())).length;
    return {
      'pending': countWhere(['pending']),
      'active': countWhere(['accepted', 'inTransit']),
      'delivered': countWhere(['delivered']),
      'cancelled': countWhere(['cancelled']),
    };
  }

  Future<void> loadDeliveries() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getDeliveries(
        userId: userId,
        patientName: patientName,
      );
      _deliveries = (result['own'] as List).cast<Map<String, dynamic>>();
      _recentDeliveries =
          (result['recent'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      _error = e.toString();
      debugPrint('PatientDeliveryProvider.loadDeliveries error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelDelivery(String deliveryId) async {
    try {
      await _service.cancelDelivery(deliveryId);
      await loadDeliveries();
    } catch (e) {
      _error = e.toString();
      debugPrint('PatientDeliveryProvider.cancelDelivery error: $e');
      notifyListeners();
    }
  }

  Future<void> confirmReceived(String deliveryId) async {
    try {
      await _service.confirmReceived(deliveryId);
      await loadDeliveries();
    } catch (e) {
      _error = e.toString();
      debugPrint('PatientDeliveryProvider.confirmReceived error: $e');
      notifyListeners();
    }
  }
}
