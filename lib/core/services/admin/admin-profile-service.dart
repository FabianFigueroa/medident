import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final snap = await _firestore.collection('admin_profiles').limit(1).get();
      if (snap.docs.isNotEmpty) return snap.docs.first.data();
      return {'name': 'Administrador', 'email': '', 'role': 'admin', 'phone': ''};
    } catch (e) {
      debugPrint('AdminProfileService.getProfile error: $e');
      return {'name': 'Administrador', 'email': '', 'role': 'admin', 'phone': ''};
    }
  }

  Future<List<Map<String, dynamic>>> getAuditLog() async {
    try {
      final snap = await _firestore.collection('audit_log').orderBy('timestamp', descending: true).limit(20).get();
      return snap.docs.map((d) { final data = d.data(); data['id'] = d.id; return data; }).toList();
    } catch (e) {
      debugPrint('AdminProfileService.getAuditLog error: $e');
      return [];
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('admin_profiles').doc('admin').set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('AdminProfileService.updateProfile error: $e');
    }
  }
}
