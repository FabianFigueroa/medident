import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/alert-model.dart';

class DoctorSecurityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AlertModel>> streamAlertsByUser(String userId) {
    return _firestore
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AlertModel.fromFirestore(d)).toList());
  }

  Future<void> markAlertRead(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({'read': true});
    } catch (e) {
      debugPrint('DoctorSecurityService.markAlertRead error: $e');
    }
  }
}
