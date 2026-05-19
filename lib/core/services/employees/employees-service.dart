import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class EmployeesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getEmployeesByClinic(String clinicId) async {
    try {
      final snap = await _firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('employees')
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('EmployeesService.getEmployeesByClinic error: $e');
      return [];
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamEmployeesByClinic(
      String clinicId) {
    return _firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('employees')
        .snapshots();
  }

  Future<void> updateEmployeePosition({
    required String clinicId,
    required String uid,
    required String position,
  }) async {
    try {
      await _firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('employees')
          .doc(uid)
          .update({'position': position});
    } catch (e) {
      debugPrint('EmployeesService.updateEmployeePosition error: $e');
      rethrow;
    }
  }

  Future<void> toggleEmployeeActive({
    required String clinicId,
    required String uid,
    required bool isActive,
  }) async {
    try {
      await _firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('employees')
          .doc(uid)
          .update({'isActive': isActive});
    } catch (e) {
      debugPrint('EmployeesService.toggleEmployeeActive error: $e');
      rethrow;
    }
  }
}
