import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/comment-model.dart';
import 'package:medident/core/models/jobs-model.dart';
import 'package:medident/core/models/media-item.dart';
import 'package:medident/core/models/post-model.dart';
import 'package:medident/core/models/story-model.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/models/user-light-model.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/models/treatment-model.dart';
import 'package:medident/core/models/appointment-model.dart';
import 'package:medident/core/models/odontogram-model.dart';
import 'package:medident/core/models/turno-model.dart';

class DentistHomeService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  bool _promoChecked = false;

  // ═══════════════════════════════════════════════════════════
  //  STREAMS EN TIEMPO REAL
  // ═══════════════════════════════════════════════════════════

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPosts({
    int limit = 10,
    String? clinicId,
  }) {
    var q = _firestore.collection('posts').orderBy('createdAt', descending: true).limit(limit);
    if (clinicId != null) {
      q = q.where('clinicId', isEqualTo: clinicId);
    }
    return q.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamStories({int limit = 20}) {
    return _firestore
        .collection('stories')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> ensurePromoCollection() async {
    if (_promoChecked) return;
    try {
      final snap = await _firestore.collection('promotions').limit(1).get();
      if (snap.docs.isEmpty) {
        await _firestore.collection('promotions').doc('_seed').set({'seed': true});
      }
      _promoChecked = true;
    } catch (e) { debugPrint('ensurePromo: $e'); }
  }

  Future<Map<String, dynamic>> getPostsPaginated({int limit = 10, DocumentSnapshot? lastDoc, String? clinicId}) async {
    try {
      var q = _firestore.collection('posts') as Query;
      if (clinicId != null) q = q.where('clinicId', isEqualTo: clinicId);
      q = q.orderBy('createdAt', descending: true).limit(limit);
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final posts = snap.docs.map((d) {
        final data = (d.data() as Map<String, dynamic>);
        data['id'] = d.id;
        return PostModel.fromJson(data, d.id);
      }).toList();
      return {
        'posts': posts,
        'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null,
      };
    } catch (e) {
      debugPrint('getPosts: $e');
      return {
        'posts': <PostModel>[],
        'lastDocument': null,
      };
    }
  }

  Future<List<StoryModel>> getStories({int limit = 20}) async {
    try {
      final snap = await _firestore.collection('stories').limit(limit).get();
      final stories = <StoryModel>[];
      final missingUserIds = <String>{};
      final storyDocs = <String, Map<String, dynamic>>{};

      for (final doc in snap.docs) {
        final data = doc.data();
        final story = StoryModel.fromJson(data, doc.id);
        storyDocs[doc.id] = data;
        if (story.userName.isEmpty || story.userPhoto == null || story.userPhoto!.isEmpty) {
          missingUserIds.add(story.userId);
        }
        stories.add(story);
      }

      if (missingUserIds.isNotEmpty) {
        final userSnap = await _firestore.collection('users')
            .where(FieldPath.documentId, whereIn: missingUserIds.take(10).toList())
            .get();
        final userMap = <String, Map<String, dynamic>>{};
        for (final d in userSnap.docs) {
          userMap[d.id] = d.data();
        }

        for (int i = 0; i < stories.length; i++) {
          final story = stories[i];
          if (story.userName.isEmpty || story.userPhoto == null || story.userPhoto!.isEmpty) {
            final userData = userMap[story.userId];
            if (userData != null) {
              final updatedData = Map<String, dynamic>.from(storyDocs[story.id] ?? {});
              if (story.userName.isEmpty) {
                updatedData['userName'] = userData['fullName'] ?? userData['userName'] ?? 'Usuario';
              }
              if (story.userPhoto == null || story.userPhoto!.isEmpty) {
                final imageUrl = userData['imageUrl'];
                if (imageUrl != null && imageUrl.toString().isNotEmpty) {
                  updatedData['userPhoto'] = imageUrl;
                }
              }
              stories[i] = StoryModel.fromJson(updatedData, story.id);
            }
          }
        }
      }

      return stories;
    } catch (e) { debugPrint('getStories: $e'); return []; }
  }

  Future<Map<String, dynamic>> getStoriesPaginated({
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query q = _firestore.collection('stories').orderBy('createdAt', descending: true).limit(limit);
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final stories = <StoryModel>[];
      final missingUserIds = <String>{};
      final storyDocs = <String, Map<String, dynamic>>{};

      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final story = StoryModel.fromJson(data, doc.id);
        storyDocs[doc.id] = data;
        if (story.userName.isEmpty || story.userPhoto == null) {
          missingUserIds.add(story.userId);
        }
        stories.add(story);
      }

      if (missingUserIds.isNotEmpty) {
        final userSnap = await _firestore.collection('users')
            .where(FieldPath.documentId, whereIn: missingUserIds.take(10).toList())
            .get();
        final userMap = <String, Map<String, dynamic>>{};
        for (final d in userSnap.docs) {
          userMap[d.id] = d.data();
        }

        for (int i = 0; i < stories.length; i++) {
          final story = stories[i];
          if (story.userName.isEmpty || story.userPhoto == null) {
            final userData = userMap[story.userId];
            if (userData != null) {
              final updatedData = Map<String, dynamic>.from(storyDocs[story.id] ?? {});
              if (story.userName.isEmpty) {
                updatedData['userName'] = userData['fullName'] ?? userData['userName'] ?? '';
              }
              if (story.userPhoto == null) {
                updatedData['userPhoto'] = userData['imageUrl'];
              }
              stories[i] = StoryModel.fromJson(updatedData, story.id);
            }
          }
        }
      }

      return {
        'stories': stories,
        'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null,
      };
    } catch (e) { debugPrint('getStoriesP: $e'); return {'stories': [], 'lastDocument': null}; }
  }

  Future<List<StoryModel>> getMyStories(String uid, {int limit = 10}) async {
    try {
      final snap = await _firestore.collection('stories').where('userId', isEqualTo: uid).limit(limit).get();
      return snap.docs.map((d) => StoryModel.fromJson(d.data(), d.id)).toList();
    } catch (e) { debugPrint('getMyStories: $e'); return []; }
  }

  Future<void> markStoryViewed(String storyId, String viewerId) async {
    try {
      await _firestore.collection('stories').doc(storyId).update({
        'viewedBy': FieldValue.arrayUnion([viewerId]),
        'isViewed': true,
      });
    } catch (e) { debugPrint('markViewed: $e'); }
  }

  Future<void> likeStory(String storyId, String userId) async {
    final ref = _firestore.collection('stories').doc(storyId);
    final snap = await ref.get();
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    if (likedBy.contains(userId)) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  Future<void> addStoryComment(String storyId, String userId, String content) async {
    await _firestore.collection('story_comments').add({
      'storyId': storyId,
      'userId': userId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getStoryComments(String storyId) async {
    try {
      final snap = await _firestore
          .collection('story_comments')
          .where('storyId', isEqualTo: storyId)
          .get();
      final comments = snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
      
      // Sort by createdAt in memory (descending) to avoid index requirement
      comments.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime);
        }
        return 0;
      });
      
      return comments;
    } catch (e) { debugPrint('getStoryComments: $e'); return []; }
  }

  Future<List<ProductModel>> getProducts({int limit = 10, String? clinicId}) async {
    await ensurePromoCollection();
    try {
      var q = _firestore.collection('promotions') as Query;
      if (clinicId != null) q = q.where('clinicId', isEqualTo: clinicId);
      q = q.where('isActive', isEqualTo: true).limit(limit);
      final snap = await q.get(GetOptions(source: Source.server));
      return snap.docs.map((d) => ProductModel.fromJson(d.data() as Map<String, dynamic>, d.id)).toList();
    } catch (e) { debugPrint('getProducts: $e'); return []; }
  }

  Future<List<TreatmentModel>> getTreatments({int limit = 10, String? clinicId}) async {
    try {
      var q = _firestore.collection('treatments') as Query;
      if (clinicId != null) q = q.where('clinicId', isEqualTo: clinicId);
      q = q.where('isActive', isEqualTo: true).limit(limit);
      final snap = await q.get();
      return snap.docs.map((d) => TreatmentModel.fromJson(d.data() as Map<String, dynamic>, d.id)).toList();
    } catch (e) { debugPrint('getTreatments: $e'); return []; }
  }

  Future<Map<String, dynamic>> getTreatmentsPaginated({int limit = 10, DocumentSnapshot? lastDoc, String? clinicId}) async {
    try {
      var q = _firestore.collection('treatments') as Query;
      if (clinicId != null) q = q.where('clinicId', isEqualTo: clinicId);
      q = q.where('isActive', isEqualTo: true).orderBy('createdAt', descending: true).limit(limit);
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final items = snap.docs.map((d) => TreatmentModel.fromJson(d.data() as Map<String, dynamic>, d.id)).toList();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getTreatmentsP: $e'); return {'items': <TreatmentModel>[], 'lastDocument': null}; }
  }

  Future<List<AppointmentModel>> getAppointments({required String dentistId, int limit = 10}) async {
    try {
      final snap = await _firestore.collection('appointments').where('dentistId', isEqualTo: dentistId).limit(limit).get();
      return snap.docs.map((d) => AppointmentModel.fromJson(d.data(), d.id)).toList();
    } catch (e) { debugPrint('getAppointments: $e'); return []; }
  }

  Future<Map<String, dynamic>> getAppointmentsPaginated({required String dentistId, int limit = 10, DocumentSnapshot? lastDoc}) async {
    try {
      var q = _firestore.collection('appointments').where('dentistId', isEqualTo: dentistId).orderBy('date', descending: true).limit(limit) as Query;
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final items = snap.docs.map((d) => AppointmentModel.fromJson(d.data() as Map<String, dynamic>, d.id)).toList();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getAppointmentsP: $e'); return {'items': <AppointmentModel>[], 'lastDocument': null}; }
  }

  Future<List<OdontogramModel>> getOdontograms({required String dentistId, int limit = 10}) async {
    try {
      final snap = await _firestore.collection('odontograms').where('dentistId', isEqualTo: dentistId).limit(limit).get();
      return snap.docs.map((d) => OdontogramModel.fromJson(d.data(), d.id)).toList();
    } catch (e) { debugPrint('getOdontograms: $e'); return []; }
  }

  Future<Map<String, dynamic>> getOdontogramsPaginated({required String dentistId, int limit = 10, DocumentSnapshot? lastDoc}) async {
    try {
      var q = _firestore.collection('odontograms').where('dentistId', isEqualTo: dentistId).orderBy('createdAt', descending: true).limit(limit) as Query;
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final items = snap.docs.map((d) => OdontogramModel.fromJson(d.data() as Map<String, dynamic>, d.id)).toList();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getOdontogramsP: $e'); return {'items': <OdontogramModel>[], 'lastDocument': null}; }
  }

  Future<List<TurnoModel>> getTurnos({required String dentistId, int limit = 10}) async {
    try {
      final snap = await _firestore
          .collection('turnos')
          .where('dentistId', isEqualTo: dentistId)
          .limit(limit * 2)
          .get();
      final turnos = snap.docs.map((d) => TurnoModel.fromJson(Map<String, dynamic>.from(d.data()), d.id)).toList();
      turnos.sort((a, b) => a.date.compareTo(b.date));
      return turnos.take(limit).toList();
    } catch (e) {
      debugPrint('getTurnos: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getTurnosPaginated({required String dentistId, int limit = 10, DocumentSnapshot? lastDoc}) async {
    try {
      var q = _firestore.collection('turnos').where('dentistId', isEqualTo: dentistId).orderBy('date', descending: true).limit(limit) as Query;
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final items = snap.docs.map((d) => TurnoModel.fromJson(d.data() as Map<String, dynamic>, d.id)).toList();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getTurnosP: $e'); return {'items': <TurnoModel>[], 'lastDocument': null}; }
  }

  Future<List<ProductModel>> getShopProducts({int limit = 10}) async {
    try {
      final snap = await _firestore.collection('products').where('isActive', isEqualTo: true).limit(limit).get(GetOptions(source: Source.server));
      return snap.docs.map((d) => ProductModel.fromJson(d.data(), d.id)).toList();
    } catch (e) { debugPrint('getShopProducts: $e'); return []; }
  }

  Future<Map<String, dynamic>> getShopProductsPaginated({int limit = 10, DocumentSnapshot? lastDoc}) async {
    try {
      var q = _firestore.collection('products').where('isActive', isEqualTo: true).orderBy('createdAt', descending: true).limit(limit) as Query;
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get(GetOptions(source: Source.server));
      final items = snap.docs.map((d) => ProductModel.fromJson(d.data() as Map<String, dynamic>, d.id)).toList();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getShopProductsP: $e'); return {'items': <ProductModel>[], 'lastDocument': null}; }
  }

  Future<List<Map<String, dynamic>>> getChatMessages({int limit = 10}) async {
    try {
      final snap = await _firestore.collection('messages').orderBy('createdAt', descending: true).limit(limit).get();
      return snap.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
    } catch (e) { debugPrint('getChat: $e'); return []; }
  }

  Future<Map<String, dynamic>> getChatMessagesPaginated({int limit = 10, DocumentSnapshot? lastDoc}) async {
    try {
      var q = _firestore.collection('messages').orderBy('createdAt', descending: true).limit(limit) as Query;
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final items = snap.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getChatP: $e'); return {'items': <Map<String, dynamic>>[], 'lastDocument': null}; }
  }

  Future<List<Map<String, dynamic>>> getVideoCalls({int limit = 10}) async {
    try {
      final snap = await _firestore.collection('calls').orderBy('createdAt', descending: true).limit(limit).get();
      return snap.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
    } catch (e) { debugPrint('getCalls: $e'); return []; }
  }

  Future<Map<String, dynamic>> getVideoCallsPaginated({int limit = 10, DocumentSnapshot? lastDoc}) async {
    try {
      var q = _firestore.collection('calls').orderBy('createdAt', descending: true).limit(limit) as Query;
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final items = snap.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getCallsP: $e'); return {'items': <Map<String, dynamic>>[], 'lastDocument': null}; }
  }

  Future<List<Map<String, dynamic>>> getBillInvoices({int limit = 10}) async {
    try {
      final snap = await _firestore.collection('invoices').orderBy('createdAt', descending: true).limit(limit).get();
      return snap.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
    } catch (e) { debugPrint('getInvoices: $e'); return []; }
  }

  Future<Map<String, dynamic>> getBillInvoicesPaginated({int limit = 10, DocumentSnapshot? lastDoc}) async {
    try {
      var q = _firestore.collection('invoices').orderBy('createdAt', descending: true).limit(limit) as Query;
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final items = snap.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getInvoicesP: $e'); return {'items': <Map<String, dynamic>>[], 'lastDocument': null}; }
  }

  Future<List<Map<String, dynamic>>> getClinicalVisits({int limit = 10}) async {
    try {
      final snap = await _firestore.collection('visits').orderBy('date', descending: true).limit(limit).get();
      return snap.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
    } catch (e) { debugPrint('getVisits: $e'); return []; }
  }

  Future<Map<String, dynamic>> getClinicalVisitsPaginated({int limit = 10, DocumentSnapshot? lastDoc}) async {
    try {
      var q = _firestore.collection('visits').orderBy('date', descending: true).limit(limit) as Query;
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final items = snap.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getVisitsP: $e'); return {'items': <Map<String, dynamic>>[], 'lastDocument': null}; }
  }

  Future<List<Map<String, dynamic>>> getShortReels({int limit = 10}) async {
    try {
      final snap = await _firestore.collection('reels').orderBy('createdAt', descending: true).limit(limit).get();
      return snap.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
    } catch (e) { debugPrint('getReels: $e'); return []; }
  }

  Future<Map<String, dynamic>> getShortReelsPaginated({int limit = 10, DocumentSnapshot? lastDoc}) async {
    try {
      var q = _firestore.collection('reels').orderBy('createdAt', descending: true).limit(limit) as Query;
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final items = snap.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getReelsP: $e'); return {'items': <Map<String, dynamic>>[], 'lastDocument': null}; }
  }

  Future<List<ProductModel>> getMyPromotions({required String userId}) async {
    try {
      final snap = await _firestore.collection('promotions').where('userId', isEqualTo: userId).get(GetOptions(source: Source.server));
      return snap.docs.map((d) => ProductModel.fromJson(d.data(), d.id)).toList();
    } catch (e) { debugPrint('getMyPromos: $e'); return []; }
  }

  Future<List<ProductModel>> getGlobalPromotions() async {
    try {
      final snap = await _firestore.collection('promotions')
          .where('scope', isEqualTo: 'global')
          .get(GetOptions(source: Source.server));
      return snap.docs.map((d) => ProductModel.fromJson(d.data(), d.id)).toList();
    } catch (e) { debugPrint('getGlobalPromos: $e'); return []; }
  }

  Future<String> createPromotion({
    required String userId,
    required String name,
    required String description,
    required double price,
    required String scope,
    double? discount,
    List<String>? images,
    String? category,
    String? clinicName,
    DateTime? expires,
  }) async {
    await ensurePromoCollection();
    final ref = _firestore.collection('promotions').doc();
    await ref.set({
      'userId': userId,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discount,
      'imageUrls': images,
      'category': category,
      'clinicName': clinicName,
      'scope': scope,
      'isActive': true,
      'isFeatured': false,
      'expiresAt': expires,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updatePromotion({
    required String promoId,
    String? name,
    String? desc,
    double? price,
    double? discount,
    List<String>? images,
    bool? active,
    bool? featured,
    DateTime? expires,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (desc != null) updates['description'] = desc;
    if (price != null) updates['price'] = price;
    if (discount != null) updates['discountPrice'] = discount;
    if (images != null) updates['imageUrls'] = images;
    if (active != null) updates['isActive'] = active;
    if (featured != null) updates['isFeatured'] = featured;
    if (expires != null) updates['expiresAt'] = expires;
    if (updates.isNotEmpty) {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('promotions').doc(promoId).update(updates);
    }
  }

  Future<void> deletePromotion(String promoId) async {
    await _firestore.collection('promotions').doc(promoId).delete();
  }

  Future<List<JobModel>> getJobs({int limit = 5}) async {
    try {
      final snap = await _firestore.collection('jobs').where('isActive', isEqualTo: true).limit(limit * 2).get();
      final jobs = snap.docs.map((d) => JobModel.fromJson(d.data(), d.id)).toList();
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs.take(limit).toList();
    } catch (e) { debugPrint('getJobs: $e'); return []; }
  }

  Future<Map<String, dynamic>> getJobsPaginated({int limit = 10, DocumentSnapshot? lastDoc}) async {
    try {
      var q = _firestore.collection('jobs').where('isActive', isEqualTo: true).orderBy('createdAt', descending: true).limit(limit) as Query;
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final items = snap.docs.map((d) => JobModel.fromJson(d.data() as Map<String, dynamic>, d.id)).toList();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getJobsP: $e'); return {'items': <JobModel>[], 'lastDocument': null}; }
  }

  Future<List<UserModel>> getSuggested_Friends({int limit = 5}) async {
    try {
      final snap = await _firestore.collection('users').limit(limit).get();
      return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
    } catch (e) { debugPrint('getSuggested: $e'); return []; }
  }

  Future<Map<String, dynamic>> getSuggestedFriendsPaginated({int limit = 10, DocumentSnapshot? lastDoc}) async {
    try {
      var q = _firestore.collection('users').orderBy('fullName').limit(limit) as Query;
      if (lastDoc != null) q = q.startAfterDocument(lastDoc);
      final snap = await q.get();
      final items = snap.docs.map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
      return {'items': items, 'lastDocument': snap.docs.isNotEmpty ? snap.docs.last : null};
    } catch (e) { debugPrint('getSuggestedP: $e'); return {'items': <UserModel>[], 'lastDocument': null}; }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      return null;
    } catch (e) { debugPrint('getUser: $e'); return null; }
  }

  Future<void> likePost(String postId, String userId) async {
    final ref = _firestore.collection('posts').doc(postId);
    final snap = await ref.get();
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    if (likedBy.contains(userId)) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  Future<void> addComment(
    String postId,
    String userId,
    String content, {
    String? sourceName,
    String? sourcePhoto,
  }) async {
    await _firestore.collection('comments').add({
      'postId': postId,
      'userId': userId,
      'sourceType': 'user',
      'sourceId': userId,
      'sourceName': sourceName ?? '',
      'sourcePhoto': sourcePhoto,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sharePost(String postId, String userId) async {
    await _firestore.collection('shares').add({
      'postId': postId,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> savePost(String postId, String userId) async {
    await _firestore.collection('saved').doc('${postId}_$userId').set({
      'postId': postId,
      'userId': userId,
    });
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  Future<void> followUser(String followerId, String followingId) async {
    if (followerId == followingId) return;
    final batch = _firestore.batch();
    final followRef = _firestore.collection('follows').doc('${followerId}_$followingId');
    batch.set(followRef, {
      'followerId': followerId,
      'followingId': followingId,
      'createdAt': Timestamp.now(),
    });
    batch.update(_firestore.collection('users').doc(followerId), {'followingCount': FieldValue.increment(1)});
    batch.update(_firestore.collection('users').doc(followingId), {'followersCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> unfollowUser(String followerId, String followingId) async {
    if (followerId == followingId) return;
    final batch = _firestore.batch();
    final followRef = _firestore.collection('follows').doc('${followerId}_$followingId');
    batch.delete(followRef);
    batch.update(_firestore.collection('users').doc(followerId), {'followingCount': FieldValue.increment(-1)});
    batch.update(_firestore.collection('users').doc(followingId), {'followersCount': FieldValue.increment(-1)});
    await batch.commit();
  }

  Future<void> blockUser(String blockerId, String blockedId) async {
    await _firestore.collection('blocks').doc('${blockerId}_$blockedId').set({
      'blockerId': blockerId,
      'blockedId': blockedId,
    });
  }

  Future<void> reportContent({
    required String contentId,
    required String contentType,
    required String reason,
    String? reporterId,
    String? info,
  }) async {
    await _firestore.collection('reports').add({
      'contentId': contentId,
      'contentType': contentType,
      'reason': reason,
      'reporterId': reporterId,
      'additionalInfo': info,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<UserLightModel>> searchUsers(String query) async {
    try {
      final snap = await _firestore.collection('users').where('fullName', isGreaterThanOrEqualTo: query).limit(10).get();
      return snap.docs.map((d) => UserLightModel.fromJson(d.data(), d.id)).toList();
    } catch (e) { debugPrint('searchUsers: $e'); return []; }
  }

  Future<void> addToCart(String userId, String productId, int quantity) async {
    final ref = _firestore.collection('cart').doc('${userId}_$productId');
    await ref.set({
      'productId': productId,
      'quantity': quantity,
      'userId': userId,
    });
  }

  Future<void> applyToJob(String userId, String jobId, {String? coverLetter}) async {
    await _firestore.collection('job_applications').add({
      'jobId': jobId,
      'userId': userId,
      'coverLetter': coverLetter,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> bookAppointment({
    required String patientId,
    required String patientName,
    required String dentistId,
    required String treatmentName,
    required DateTime date,
    required String timeSlot,
    String? patientPhoto,
    String? notes,
  }) async {
    await _firestore.collection('appointments').add({
      'patientId': patientId,
      'patientName': patientName,
      'patientPhoto': patientPhoto,
      'dentistId': dentistId,
      'treatmentName': treatmentName,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'notes': notes,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendMessage({
    required String senderId,
    required String recipientId,
    required String content,
    String? messageType,
  }) async {
    await _firestore.collection('messages').add({
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'messageType': messageType ?? 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createPost({
    required String userId,
    required String title,
    String? description,
    List<String>? imageUrls,
    List<MediaItem>? media,
    String? city,
    String? clinicId,
    String? sourceType,
    String? sourceId,
    String? sourceName,
    String? sourcePhoto,
  }) async {
    final ref = _firestore.collection('posts').doc();
    final finalMedia = media ?? (imageUrls != null ? MediaItem.fromLegacyUrls(imageUrls) : <MediaItem>[]);
    await ref.set({
      'userId': userId,
      'sourceType': sourceType ?? 'user',
      'sourceId': sourceId ?? userId,
      'sourceName': sourceName ?? '',
      'sourcePhoto': sourcePhoto,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'media': finalMedia.map((m) => m.toMap()).toList(),
      'city': city,
      'clinicId': clinicId,
      'likesCount': 0,
      'commentsCount': 0,
      'sharesCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<String> createStory({
    required String userId,
    required String imageUrl,
    String? text,
    MediaItem? media,
    String? sourceType,
    String? sourceId,
    String? sourceName,
    String? sourcePhoto,
  }) async {
    final ref = _firestore.collection('stories').doc();
    
    final storyMedia = media ?? MediaItem.fromUrl(imageUrl);
    
    String userName = '';
    String? userPhoto;
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        userName = userData['fullName'] ?? userData['userName'] ?? '';
        userPhoto = userData['imageUrl'];
      }
    } catch (e) {
      debugPrint('Error fetching user data for story: $e');
    }
    
    await ref.set({
      'userId': userId,
      'sourceType': sourceType ?? 'user',
      'sourceId': sourceId ?? userId,
      'sourceName': sourceName ?? userName,
      'sourcePhoto': sourcePhoto ?? userPhoto,
      'imageUrl': imageUrl,
      'media': [storyMedia.toMap()],
      'text': text,
      'isActive': true,
      'viewedBy': [],
      'likedBy': [],
      'likesCount': 0,
      'userName': userName,
      'userPhoto': userPhoto,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<String> createTurno({
    required String dentistId,
    required String employeeId,
    required String employeeName,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? notes,
  }) async {
    final ref = _firestore.collection('turnos').doc();
    await ref.set({
      'dentistId': dentistId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'status': 'scheduled',
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).delete();
  }

  Future<void> updateTurnoStatus(String turnoId, String status) async {
    await _firestore.collection('turnos').doc(turnoId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTurno(String turnoId) async {
    await _firestore.collection('turnos').doc(turnoId).delete();
  }

  Future<String> createReel({
    required String userId,
    required String videoUrl,
    String? description,
    String? sourceType,
    String? sourceId,
    String? sourceName,
    String? sourcePhoto,
    String? thumbnailUrl,
  }) async {
    final ref = _firestore.collection('reels').doc();
    await ref.set({
      'userId': userId,
      'sourceType': sourceType ?? 'user',
      'sourceId': sourceId ?? userId,
      'sourceName': sourceName ?? '',
      'sourcePhoto': sourcePhoto,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'likesCount': 0,
      'commentsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
