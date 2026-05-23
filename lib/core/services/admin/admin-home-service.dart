import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/product-model.dart';

class AdminHomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final usersAgg = await _firestore.collection('users').count().get();
      final postsAgg = await _firestore.collection('posts').count().get();
      final reportsAgg = await _firestore.collection('reports').count().get();

      return {
        'activeUsers': usersAgg.count,
        'totalPosts': postsAgg.count,
        'openReports': reportsAgg.count,
        'newUsersThisWeek': (usersAgg.count ?? 0) ~/ 7,
      };
    } catch (e) {
      // Fallback: limit queries if count() not available
      try {
        final results = await Future.wait([
          _firestore.collection('users').limit(1000).get(),
          _firestore.collection('posts').limit(1000).get(),
          _firestore.collection('reports').limit(1000).get(),
        ]);
        return {
          'activeUsers': results[0].docs.length,
          'totalPosts': results[1].docs.length,
          'openReports': results[2].docs.length,
          'newUsersThisWeek': results[0].docs.length ~/ 7,
        };
      } catch (e2) {
        debugPrint('AdminHomeService.getDashboardStats error: $e');
        return {
          'activeUsers': 0, 'totalPosts': 0, 'openReports': 0, 'newUsersThisWeek': 0,
        };
      }
    }
  }

  Future<List<Map<String, dynamic>>> getModerationQueue() async {
    try {
      final snap = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'pending')
          .limit(10)
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('AdminHomeService.getModerationQueue error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getActivityFeed() async {
    try {
      final snap = await _firestore
          .collection('activity_log')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('AdminHomeService.getActivityFeed error: $e');
      return [];
    }
  }

  Future<List<ProductModel>> getGlobalPromotions() async {
    try {
      final snap = await _firestore.collection('promotions')
          .where('scope', isEqualTo: 'global')
          .get();
      return snap.docs.map((d) => ProductModel.fromJson(d.data(), d.id)).toList();
    } catch (e) {
      debugPrint('AdminHomeService.getGlobalPromotions error: $e');
      return [];
    }
  }

  Future<void> createGlobalPromotion(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('promotions').add(data);
  }

  Future<void> deletePromotion(String id) async {
    await _firestore.collection('promotions').doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getReels() async {
    try {
      final snap = await _firestore.collection('reels')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('AdminHomeService.getReels error: $e');
      return [];
    }
  }

  Future<void> createReel(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('reels').add(data);
  }

  Future<void> deleteReel(String id) async {
    await _firestore.collection('reels').doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getPendingApprovals() async {
    try {
      final snap = await _firestore
          .collection('verification_requests')
          .where('status', isEqualTo: 'pending')
          .limit(10)
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('AdminHomeService.getPendingApprovals error: $e');
      return [];
    }
  }
}
