import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DoctorHomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDashboard(String uid) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final results = await Future.wait([
        _firestore.collection('users').doc(uid).get(),
        _firestore
            .collection('appointments')
            .where('dentistId', isEqualTo: uid)
            .where('date', isGreaterThanOrEqualTo: startOfDay)
            .where('date', isLessThan: endOfDay)
            .get(),
        _firestore
            .collection('appointments')
            .where('dentistId', isEqualTo: uid)
            .where('status', whereIn: ['pending', 'confirmed'])
            .orderBy('date', descending: false)
            .limit(5)
            .get(),
        _firestore
            .collection('users')
            .where('role', isEqualTo: 'patient')
            .limit(10)
            .get(),
      ]);

      final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final todayAppts = results[1] as QuerySnapshot<Map<String, dynamic>>;
      final upcomingAppts = results[2] as QuerySnapshot<Map<String, dynamic>>;
      final patientsSnap = results[3] as QuerySnapshot<Map<String, dynamic>>;

      return {
        'fullName': userDoc.data()?['fullName'] ?? '',
        'imageUrl': userDoc.data()?['imageUrl'] ?? '',
        'todayCount': todayAppts.docs.length,
        'completedCount':
            todayAppts.docs.where((d) => d.data()['status'] == 'completed').length,
        'pendingCount':
            todayAppts.docs.where((d) => d.data()['status'] == 'pending').length,
        'appointments': upcomingAppts.docs.map((d) => d.data()).toList(),
        'patients': patientsSnap.docs.map((d) => d.data()).toList(),
      };
    } catch (e) {
      debugPrint('DoctorHomeService.getDashboard error: $e');
      return {
        'fullName': '',
        'imageUrl': '',
        'todayCount': 0,
        'completedCount': 0,
        'pendingCount': 0,
        'appointments': [],
        'patients': [],
      };
    }
  }
}
