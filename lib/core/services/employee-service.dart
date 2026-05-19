import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/employee-model.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String _path(String clinicId, String uid) =>
      'clinics/$clinicId/employees/$uid';

  Future<EmployeeModel?> get(String clinicId, String uid) async {
    try {
      final doc = await _firestore.doc(_path(clinicId, uid)).get();
      if (!doc.exists) return null;
      return EmployeeModel.fromJson(doc.data() as Map<String, dynamic>, uid);
    } catch (e) {
      debugPrint('EmployeeService.get error: $e');
      return null;
    }
  }

  Future<void> set(String clinicId, EmployeeModel employee) async {
    await _firestore.doc(_path(clinicId, employee.uid)).set(employee.toMap());
  }

  Future<void> update(String clinicId, String uid, Map<String, dynamic> updates) async {
    await _firestore.doc(_path(clinicId, uid)).update(updates);
  }

  Future<void> delete(String clinicId, String uid) async {
    await _firestore.doc(_path(clinicId, uid)).delete();
  }

  Stream<List<EmployeeModel>> streamByClinic(String clinicId) {
    return _firestore
        .collection('clinics/$clinicId/employees')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => EmployeeModel.fromJson(d.data(), d.id))
            .toList());
  }
}
