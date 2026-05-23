import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/product-model.dart';

class PatientHomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDashboard(String uid) async {
    try {
      final results = await Future.wait([
        _firestore
            .collection('appointments')
            .where('patientId', isEqualTo: uid)
            .where('status', whereIn: ['pending', 'confirmed'])
            .orderBy('date')
            .limit(5)
            .get(),
        _firestore.collection('promotions').where('isActive', isEqualTo: true).limit(5).get(),
        _firestore.collection('treatments').where('isActive', isEqualTo: true).limit(8).get(),
        _firestore
            .collection('promotions')
            .where('scope', isEqualTo: 'global')
            .where('isActive', isEqualTo: true)
            .get(),
      ]);

      return {
        'appointments':
            (results[0] as QuerySnapshot).docs.map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>}).toList(),
        'promotions':
            (results[1] as QuerySnapshot).docs.map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>}).toList(),
        'treatments':
            (results[2] as QuerySnapshot).docs.map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>}).toList(),
        'globalPromotions': (results[3] as QuerySnapshot)
            .docs
            .map((d) => ProductModel.fromJson(d.data() as Map<String, dynamic>, d.id))
            .toList(),
      };
    } catch (e) {
      debugPrint('PatientHomeService.getDashboard error: $e');
      return {'appointments': [], 'promotions': [], 'treatments': [], 'globalPromotions': []};
    }
  }
}
