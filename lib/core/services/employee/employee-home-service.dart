import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class EmployeeHomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getEmployeeDashboard(String uid) async {
    try {
      final results = await Future.wait([
        _firestore.collection('users').doc(uid).get(),
        _firestore.collection('posts').where('userId', isEqualTo: uid).limit(100).get(),
        _firestore.collection('turnos')
            .where('employeeId', isEqualTo: uid)
            .where('date', isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
            .get(),
      ]);

      final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final postsSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;
      final turnosSnap = results[2] as QuerySnapshot<Map<String, dynamic>>;

      return {
        'userName': userDoc.data()?['fullName'] ?? '',
        'userPhoto': userDoc.data()?['imageUrl'] ?? '',
        'totalPosts': postsSnap.docs.length,
        'todayShifts': turnosSnap.docs.length,
      };
    } catch (e) {
      debugPrint('EmployeeHomeService.getEmployeeDashboard error: $e');
      return {
        'userName': '',
        'userPhoto': '',
        'totalPosts': 0,
        'todayShifts': 0,
      };
    }
  }
}
