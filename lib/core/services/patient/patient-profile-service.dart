import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PatientProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return {};
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      debugPrint('PatientProfileService.getProfile error: $e');
      return {};
    }
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      debugPrint('PatientProfileService.updateProfile error: $e');
      rethrow;
    }
  }
}
