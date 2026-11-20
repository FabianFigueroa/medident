import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/clinic-model.dart';
import 'package:medident/core/models/post-model.dart';

/// Seguimiento (follow) de clínicas.
///
/// Colección: `clinic_follows/{userId}_{clinicId}`
///   { userId, clinicId, createdAt }
///
/// Con esto cualquier usuario puede suscribirse a una clínica y ver en su
/// home() todo lo que la clínica publique (posts). Es independiente del
/// sistema de `follows` entre usuarios.
class ClinicFollowService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String _docId(String userId, String clinicId) => '${userId}_$clinicId';

  Future<void> followClinic({
    required String userId,
    required String clinicId,
  }) async {
    if (userId.isEmpty || clinicId.isEmpty) return;
    await _firestore
        .collection('clinic_follows')
        .doc(_docId(userId, clinicId))
        .set({
      'userId': userId,
      'clinicId': clinicId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unfollowClinic({
    required String userId,
    required String clinicId,
  }) async {
    if (userId.isEmpty || clinicId.isEmpty) return;
    await _firestore
        .collection('clinic_follows')
        .doc(_docId(userId, clinicId))
        .delete();
  }

  Future<bool> isFollowingClinic({
    required String userId,
    required String clinicId,
  }) async {
    if (userId.isEmpty || clinicId.isEmpty) return false;
    try {
      final doc = await _firestore
          .collection('clinic_follows')
          .doc(_docId(userId, clinicId))
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('isFollowingClinic: $e');
      return false;
    }
  }

  /// IDs de las clínicas que sigue el usuario.
  Stream<List<String>> streamFollowedClinicIds(String userId) {
    if (userId.isEmpty) return Stream.value(const []);
    return _firestore
        .collection('clinic_follows')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => d.data()['clinicId'] as String? ?? '')
            .where((id) => id.isNotEmpty)
            .toList());
  }

  /// Datos completos de las clínicas seguidas.
  Future<List<ClinicModel>> getFollowedClinics(String userId) async {
    if (userId.isEmpty) return [];
    try {
      final followSnap = await _firestore
          .collection('clinic_follows')
          .where('userId', isEqualTo: userId)
          .get();
      final ids = followSnap.docs
          .map((d) => d.data()['clinicId'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      if (ids.isEmpty) return [];
      return _getClinicsByIds(ids);
    } catch (e) {
      debugPrint('getFollowedClinics: $e');
      return [];
    }
  }

  Future<List<ClinicModel>> _getClinicsByIds(List<String> ids) async {
    final result = <ClinicModel>[];
    // whereIn admite max 10; partimos en lotes.
    for (var i = 0; i < ids.length; i += 10) {
      final batch = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final snap = await _firestore
          .collection('clinics')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      result.addAll(snap.docs
          .map((d) => ClinicModel.fromMap(d.data(), d.id)));
    }
    return result;
  }

  /// Posts de las clínicas seguidas, en tiempo real.
  Stream<List<PostModel>> streamFollowedClinicPosts(String userId, {int limit = 30}) {
    final controller = StreamController<List<PostModel>>();
    StreamSubscription<List<String>>? idsSub;
    final subs = <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];
    final batchMaps = <int, Map<String, PostModel>>{};
    var closed = false;

    void cancelAll() {
      idsSub?.cancel();
      for (final s in subs) {
        s.cancel();
      }
      subs.clear();
      batchMaps.clear();
    }

    void emit() {
      final all = <String, PostModel>{};
      for (final m in batchMaps.values) {
        all.addAll(m);
      }
      final list = all.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!closed) controller.add(list);
    }

    idsSub = streamFollowedClinicIds(userId).listen((ids) {
      // Reinicia subscripciones a posts cuando cambian las clínicas seguidas.
      for (final s in subs) {
        s.cancel();
      }
      subs.clear();
      batchMaps.clear();
      if (ids.isEmpty) {
        if (!closed) controller.add(const []);
        return;
      }
      for (var i = 0; i < ids.length; i += 10) {
        final batch = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
        final bi = i ~/ 10;
        final q = _firestore
            .collection('posts')
            .where('clinicId', whereIn: batch)
            .limit(limit);
        final sub = q.snapshots().listen((snap) {
          final local = <String, PostModel>{};
          for (final doc in snap.docs) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            local[doc.id] = PostModel.fromJson(data, doc.id);
          }
          batchMaps[bi] = local;
          emit();
        }, onError: (e) {
          debugPrint('streamFollowedClinicPosts: $e');
        });
        subs.add(sub);
      }
    }, onError: (e) {
      debugPrint('streamFollowedClinicPosts ids: $e');
    });

    controller.onCancel = () {
      closed = true;
      cancelAll();
    };
    return controller.stream;
  }

  /// Todas las clínicas activas (para explorar y seguir).
  Stream<List<ClinicModel>> streamAllClinics({int limit = 50}) {
    return _firestore
        .collection('clinics')
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ClinicModel.fromMap(d.data(), d.id))
            .toList());
  }

  /// Clínicas que el usuario aún NO sigue (sugerencias / explorar).
  Future<List<ClinicModel>> getSuggestions(String userId, {int limit = 20}) async {
    try {
      final all = await _firestore
          .collection('clinics')
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();
      final followed = await _firestore
          .collection('clinic_follows')
          .where('userId', isEqualTo: userId)
          .get();
      final followedIds =
          followed.docs.map((d) => d.data()['clinicId'] as String?).toSet();
      return all.docs
          .where((d) => !followedIds.contains(d.id))
          .map((d) => ClinicModel.fromMap(d.data(), d.id))
          .toList();
    } catch (e) {
      debugPrint('getSuggestions: $e');
      return [];
    }
  }
}
