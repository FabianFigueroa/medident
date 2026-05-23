import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/treatment-confession-model.dart';

class TreatmentConfessionService {
  final FirebaseFirestore _firestore;

  TreatmentConfessionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _firestore.collection('treatment_confessions');

  Future<List<TreatmentConfessionModel>> getByClinic(
    String clinicId, {
    bool onlyApproved = true,
    int limit = 20,
  }) async {
    Query query = _collection
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (onlyApproved) {
      query = query.where('isApproved', isEqualTo: true);
    }
    final snap = await query.get();
    return snap.docs
        .map((d) =>
            TreatmentConfessionModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Stream<List<TreatmentConfessionModel>> streamByClinic(
    String clinicId, {
    bool onlyApproved = true,
  }) {
    Query query = _collection
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true);
    if (onlyApproved) {
      query = query.where('isApproved', isEqualTo: true);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) =>
            TreatmentConfessionModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  Future<String> create(TreatmentConfessionModel confession) async {
    final ref = _collection.doc();
    final data = confession.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await ref.set(data);
    return ref.id;
  }

  Future<void> updateApproval(String id, bool isApproved) async {
    await _collection.doc(id).update({'isApproved': isApproved});
  }

  Future<void> updateRating(String id, double rating) async {
    await _collection.doc(id).update({'rating': rating});
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> updateMedia(
      String id, {String? thumbnailUrl, String? beforePhoto, String? afterPhoto}) async {
    final updates = <String, dynamic>{};
    if (thumbnailUrl != null) updates['thumbnailUrl'] = thumbnailUrl;
    if (beforePhoto != null) updates['beforePhoto'] = beforePhoto;
    if (afterPhoto != null) updates['afterPhoto'] = afterPhoto;
    if (updates.isNotEmpty) {
      await _collection.doc(id).update(updates);
    }
  }
}
