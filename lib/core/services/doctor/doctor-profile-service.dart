import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DoctorProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return {};
      final data = doc.data()!;
      return {
        'fullName': data['fullName'] ?? '',
        'email': data['email'] ?? '',
        'phoneNumber': data['phoneNumber'] ?? '',
        'imageUrl': data['imageUrl'] ?? '',
        'role': data['role'] ?? '',
        'clinicId': data['clinicId'] ?? '',
      };
    } catch (e) {
      debugPrint('DoctorProfileService.getProfile error: $e');
      return {};
    }
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      debugPrint('DoctorProfileService.updateProfile error: $e');
      rethrow;
    }
  }
}
