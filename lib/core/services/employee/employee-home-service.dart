import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/product-model.dart';

class EmployeeHomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getEmployeeDashboard(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      return {
        'userName': userDoc.data()?['fullName'] ?? '',
        'userPhoto': userDoc.data()?['imageUrl'] ?? '',
      };
    } catch (e) {
      debugPrint('EmployeeHomeService.getEmployeeDashboard error: $e');
      return {
        'userName': '',
        'userPhoto': '',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getTurnos(String uid) async {
    try {
      final snap = await _firestore
          .collection('turnos')
          .where('employeeId', isEqualTo: uid)
          .where('status', whereIn: ['scheduled', 'in_progress'])
          .orderBy('date')
          .limit(5)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('EmployeeHomeService.getTurnos error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAlerts(String uid) async {
    try {
      final snap = await _firestore
          .collection('alerts')
          .where('userId', isEqualTo: uid)
          .where('read', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('EmployeeHomeService.getAlerts error: $e');
      return [];
    }
  }

  Future<List<ProductModel>> getGlobalPromotions() async {
    try {
      final snap = await _firestore
          .collection('promotions')
          .where('scope', isEqualTo: 'global')
          .where('isActive', isEqualTo: true)
          .get();
      return snap.docs
          .map((d) => ProductModel.fromJson(d.data(), d.id))
          .toList();
    } catch (e) {
      debugPrint('EmployeeHomeService.getGlobalPromotions error: $e');
      return [];
    }
  }
}
