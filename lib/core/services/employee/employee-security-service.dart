import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class EmployeeSecurityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getSecurityData(String uid) async {
    try {
      final doc = await _firestore.collection('security').doc(uid).get();
      return doc.exists ? doc.data()! : {};
    } catch (e) {
      debugPrint('EmployeeSecurityService.getSecurityData error: $e');
      return {};
    }
  }

  Future<void> updateSecurityData(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('security').doc(uid).update(updates);
    } catch (e) {
      debugPrint('EmployeeSecurityService.updateSecurityData error: $e');
      rethrow;
    }
  }
}
