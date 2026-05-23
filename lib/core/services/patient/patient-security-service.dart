import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PatientSecurityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAccessLogs(String uid) async {
    try {
      final snap = await _firestore
          .collection('rfid_logs')
          .where('patientId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('PatientSecurityService.getAccessLogs error: $e');
      return [];
    }
  }
}
