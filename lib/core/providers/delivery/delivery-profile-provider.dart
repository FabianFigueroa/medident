import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Datos del rider para Perfil y Seguridad: documento `riders/{userId}` +
/// conteo de entregas completadas (`deliveries` con riderId, cliente).
class DeliveryProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  Map<String, dynamic>? _rider;
  Map<String, dynamic>? _user;
  int _completedCount = 0;
  int _inProgressCount = 0;
  bool _isLoading = false;
  String? _error;

  DeliveryProfileProvider({required this.userId});

  Map<String, dynamic>? get rider => _rider;
  Map<String, dynamic>? get user => _user;
  int get completedCount => _completedCount;
  int get inProgressCount => _inProgressCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isServiceActive => (rider?['isActive'] ?? false) as bool;

  Future<void> initialize() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final riderDoc = await _firestore.collection('riders').doc(userId).get();
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final deliveriesSnap = await _firestore
          .collection('deliveries')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _rider = riderDoc.exists ? riderDoc.data() : null;
      _user = userDoc.exists ? userDoc.data() : null;

      _completedCount = 0;
      _inProgressCount = 0;
      for (final doc in deliveriesSnap.docs) {
        final riderId = (doc.data()['riderId'] ?? '').toString();
        if (riderId != userId) continue;
        switch ((doc.data()['status'] ?? '').toString()) {
          case 'delivered':
            _completedCount++;
            break;
          case 'accepted':
          case 'inTransit':
            _inProgressCount++;
            break;
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('DeliveryProfileProvider.initialize error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleServiceStatus(bool active) async {
    try {
      await _firestore.collection('riders').doc(userId).set({
        'userId': userId,
        'isActive': active,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _rider = {...?_rider, 'isActive': active};
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('DeliveryProfileProvider.toggleServiceStatus error: $e');
      notifyListeners();
    }
  }
}
