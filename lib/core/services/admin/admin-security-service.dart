import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminSecurityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getSecurityOverview() async {
    try {
      final securitySnap = await _firestore.collection('security').get();
      final alertsSnap = await _firestore
          .collection('alerts')
          .where('read', isEqualTo: false)
          .get();

      return {
        'totalStaff': securitySnap.docs.length,
        'activeAlerts': alertsSnap.docs.length,
        'secureZones': 12,
        'incidentsToday': 3,
      };
    } catch (e) {
      debugPrint('AdminSecurityService.getSecurityOverview error: $e');
      return {
        'totalStaff': 0,
        'activeAlerts': 0,
        'secureZones': 0,
        'incidentsToday': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getRecentAlerts() async {
    try {
      final snap = await _firestore
          .collection('alerts')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('AdminSecurityService.getRecentAlerts error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAccessLogs() async {
    try {
      final snap = await _firestore
          .collection('rfid_logs')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('AdminSecurityService.getAccessLogs error: $e');
      return [];
    }
  }
}
