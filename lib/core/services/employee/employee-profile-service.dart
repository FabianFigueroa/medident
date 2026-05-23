import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/user-model.dart';

class EmployeeProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('EmployeeProfileService.getProfile error: $e');
      return null;
    }
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      debugPrint('EmployeeProfileService.updateProfile error: $e');
      rethrow;
    }
  }
}
