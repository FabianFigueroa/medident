import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeDeliveryProvider with ChangeNotifier {
  final String userId;

  List<Map<String, dynamic>> _deliveries = [];
  bool _isLoading = false;
  String? _error;

  EmployeeDeliveryProvider({required this.userId});

  List<Map<String, dynamic>> get deliveries => _deliveries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDeliveries() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await FirebaseFirestore.instance
          .collection('deliveries')
          .where('employeeId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _deliveries = snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('EmployeeDeliveryProvider.loadDeliveries error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptDelivery(String deliveryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('deliveries')
          .doc(deliveryId)
          .update({
        'status': 'accepted',
        'employeeId': userId,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      await loadDeliveries();
    } catch (e) {
      _error = e.toString();
      debugPrint('EmployeeDeliveryProvider.acceptDelivery error: $e');
      notifyListeners();
    }
  }

  Future<void> completeDelivery(String deliveryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('deliveries')
          .doc(deliveryId)
          .update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      await loadDeliveries();
    } catch (e) {
      _error = e.toString();
      debugPrint('EmployeeDeliveryProvider.completeDelivery error: $e');
      notifyListeners();
    }
  }
}
