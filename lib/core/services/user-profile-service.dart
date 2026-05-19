import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/user-profile-model.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String _path(String uid) => 'userprofiles/$uid';

  Future<UserProfileModel?> get(String uid) async {
    try {
      final doc = await _firestore.doc(_path(uid)).get();
      if (!doc.exists) return null;
      return UserProfileModel.fromJson(doc.data() as Map<String, dynamic>, uid);
    } catch (e) {
      debugPrint('UserProfileService.get error: $e');
      return null;
    }
  }

  Future<void> save(String uid, UserProfileModel profile) async {
    await _firestore.doc(_path(uid)).set(profile.toMap());
  }

  Future<void> update(String uid, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.doc(_path(uid)).update(updates);
  }
}
