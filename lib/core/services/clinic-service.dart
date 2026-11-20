import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/clinic-model.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/models/treatment-model.dart';
import 'package:medident/core/models/turno-model.dart';
import 'package:medident/core/models/treatment-confession-model.dart';
import 'package:medident/core/models/story-model.dart';

class ClinicService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String _generateApiKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random();
    final segments = List.generate(4, (_) =>
      List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join()
    );
    return 'CL-${segments.join('-')}';
  }

  Future<ClinicModel> createClinic({
    required String name,
    required String ownerId,
    required String nit,
    String? address,
    String? phone,
    String? email,
    String? website,
    Map<String, String>? socialMedia,
    Map<String, Map<String, String>>? businessHours,
    String? description,
    String? logoUrl,
  }) async {
    final apiKey = _generateApiKey();
    final ref = _firestore.collection('clinics').doc();
    await ref.set({
      'name': name,
      'ownerId': ownerId,
      'nit': nit,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'socialMedia': socialMedia,
      'businessHours': businessHours,
      'description': description,
      'logoUrl': logoUrl,
      'apiKey': apiKey,
      'employeeIds': [ownerId],
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('users').doc(ownerId).update({
      'clinicId': ref.id,
      'isClinicOwner': true,
    });
    return ClinicModel(
      id: ref.id,
      name: name,
      ownerId: ownerId,
      nit: nit,
      address: address,
      phone: phone,
      email: email,
      website: website,
      socialMedia: socialMedia,
      businessHours: businessHours,
      description: description,
      logoUrl: logoUrl,
      apiKey: apiKey,
      employeeIds: [ownerId],
    );
  }

  Future<ClinicModel?> getClinic(String clinicId) async {
    try {
      final doc = await _firestore.collection('clinics').doc(clinicId).get();
      if (doc.exists) {
        return ClinicModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('getClinic: $e');
      return null;
    }
  }

  Future<ClinicModel?> getClinicByApiKey(String apiKey) async {
    try {
      final snap = await _firestore
          .collection('clinics')
          .where('apiKey', isEqualTo: apiKey.trim().toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        return ClinicModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
      }
      return null;
    } catch (e) {
      debugPrint('getClinicByApiKey: $e');
      return null;
    }
  }

  Future<void> updateClinic(String clinicId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('clinics').doc(clinicId).update(updates);
  }

  Future<bool> joinClinic({
    required String clinicId,
    required String userId,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? const <String, dynamic>{};
      final role = (userData['role'] ?? '').toString();
      final position = (userData['position'] as String?)?.isNotEmpty == true
          ? userData['position'] as String
          : (role == 'dentist' || role == 'doctor'
              ? 'odontologo_planta'
              : 'asistente');

      final batch = _firestore.batch();
      batch.set(
        _firestore.collection('users').doc(userId),
        {
          'clinicId': clinicId,
          'isClinicOwner': false,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      batch.set(
        _firestore.collection('clinics').doc(clinicId),
        {
          'employeeIds': FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      batch.set(
        _firestore
            .collection('clinics')
            .doc(clinicId)
            .collection('employees')
            .doc(userId),
        {
          'uid': userId,
          'fullName': userData['fullName'] ??
              userData['userName'] ??
              '',
          'imageUrl': userData['imageUrl'] ?? '',
          'position': position,
          'isActive': true,
          'hasSecurityAccess': false,
          'canManageAgenda': false,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('joinClinic: $e');
      return false;
    }
  }

  Future<String> createClinicPost({
    required String clinicId,
    required String createdBy,
    required String userName,
    String? userPhoto,
    required String type,
    required String description,
    List<String>? imageUrls,
  }) async {
    String clinicName = 'Clínica';
    String clinicLogo = '';
    try {
      final clinicDoc = await _firestore.collection('clinics').doc(clinicId).get();
      final data = clinicDoc.data();
      if (data != null) {
        final name = (data['name'] as String?)?.trim() ?? '';
        if (name.isNotEmpty) clinicName = name;
        clinicLogo = (data['logoUrl'] as String?) ?? '';
      }
    } catch (_) {}

    final ref = _firestore.collection('posts').doc();
    await ref.set({
      'clinicId': clinicId,
      'createdBy': clinicId,
      'createdByUserId': createdBy,
      'userName': clinicName,
      'userPhoto': clinicLogo,
      'sourceType': 'clinic',
      'sourceId': clinicId,
      'sourceName': clinicName,
      'sourcePhoto': clinicLogo,
      'type': type,
      'description': description,
      'imageUrls': imageUrls ?? [],
      'likesCount': 0,
      'commentsCount': 0,
      'sharesCount': 0,
      'likedBy': <String>[],
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

  Future<String> bookAppointment({
    String? clinicId,
    required String patientId,
    required String patientName,
    required String dentistId,
    String? dentistName,
    required String treatmentName,
    required DateTime date,
    required String timeSlot,
    String? patientPhoto,
    String? notes,
  }) async {
    final ref = _firestore.collection('appointments').doc();
    await ref.set({
      'clinicId': clinicId,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhoto': patientPhoto,
      'dentistId': dentistId,
      'dentistName': dentistName ?? '',
      'treatmentName': treatmentName,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'notes': notes,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<bool> leaveClinic(String clinicId, String userId) async {
    try {
      final batch = _firestore.batch();
      batch.set(
        _firestore.collection('clinics').doc(clinicId),
        {
          'employeeIds': FieldValue.arrayRemove([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      batch.set(
        _firestore.collection('users').doc(userId),
        {
          'clinicId': FieldValue.delete(),
          'isClinicOwner': false,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      batch.delete(
        _firestore
            .collection('clinics')
            .doc(clinicId)
            .collection('employees')
            .doc(userId),
      );
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('leaveClinic: $e');
      return false;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAppointmentsByClinic(String clinicId) {
    return _firestore
        .collection('appointments')
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // ── Turnos ─────────────────────────────────────────────
  Stream<QuerySnapshot<Map<String, dynamic>>> streamTurnosByClinic(String clinicId) {
    return _firestore
        .collection('turnos')
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<String> createTurno({
    required String clinicId,
    required String dentistId,
    required String employeeId,
    required String employeeName,
    String? employeePhoto,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? notes,
  }) async {
    final ref = _firestore.collection('turnos').doc();
    await ref.set({
      'clinicId': clinicId,
      'dentistId': dentistId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeePhoto': employeePhoto,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'status': 'scheduled',
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
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

  Future<List<TreatmentModel>> getTreatmentsByClinic(String clinicId) async {
    try {
      final snap = await _firestore
          .collection('treatments')
          .where('clinicId', isEqualTo: clinicId)
          .where('isActive', isEqualTo: true)
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return TreatmentModel.fromJson(data, d.id);
      }).toList();
    } catch (e) {
      debugPrint('getTreatmentsByClinic: $e');
      return [];
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveEmployeesByClinic(String clinicId) {
    return _firestore
        .collection('users')
        .where('clinicId', isEqualTo: clinicId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamTreatmentsByClinic(String clinicId) {
    return _firestore
        .collection('treatments')
        .where('clinicId', isEqualTo: clinicId)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  /// Posts de la clínica en tiempo real
  Stream<QuerySnapshot<Map<String, dynamic>>> streamClinicPosts(String clinicId) {
    return _firestore
        .collection('posts')
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Promociones de la clínica. Nunca mezcla promociones personales del dueño
  /// (Regla de oro 1: el perfil del usuario y el perfil de la clínica son
  /// entidades separadas).
  Future<List<ProductModel>> getClinicPromotions(String clinicId, String ownerId) async {
    try {
      final snap = await _firestore.collection('promotions')
          .where('clinicId', isEqualTo: clinicId)
          .get();
      return snap.docs
          .where((d) {
            final data = d.data();
            final isActive = data['isActive'] == true;
            final source = data['source'] as String?;
            return isActive && (source == null || source == 'clinic');
          })
          .map((d) => ProductModel.fromJson(d.data(), d.id))
          .toList();
    } catch (e) {
      debugPrint('getClinicPromotions: $e');
      return [];
    }
  }

  List<ProductModel> _parsePromotions(QuerySnapshot snap) {
    return snap.docs
        .where((d) {
          final data = d.data() as Map<String, dynamic>;
          final source = data['source'] as String?;
          return data['isActive'] == true &&
              (source == null || source == 'clinic');
        })
        .map((d) {
          final data = Map<String, dynamic>.from(d.data() as Map<String, dynamic>);
          return ProductModel.fromJson(data, d.id);
        })
        .toList();
  }

  Stream<List<ProductModel>> streamClinicPromotions(String clinicId, String ownerId) {
    StreamSubscription? sub;
    final controller = StreamController<List<ProductModel>>(
      onCancel: () => sub?.cancel(),
    );
    _resolvePromotionsStream(controller, clinicId, ownerId).then((s) => sub = s);
    return controller.stream;
  }

  Future<StreamSubscription?> _resolvePromotionsStream(
    StreamController<List<ProductModel>> controller,
    String clinicId,
    String ownerId,
  ) async {
    try {
      // Solo promociones propias de la clínica. Sin fallback al dueño.
      final query = _firestore
          .collection('promotions')
          .where('clinicId', isEqualTo: clinicId);

      return query.snapshots().listen(
        (snap) {
          if (!controller.isClosed) controller.add(_parsePromotions(snap));
        },
        onError: (e) {
          if (!controller.isClosed) controller.addError(e);
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('streamClinicPromotions error: $e');
      if (!controller.isClosed) {
        controller.addError(e);
        controller.close();
      }
      return null;
    }
  }

  /// Stream combinado de TODO el contenido de la clínica
  /// (posts, eventos, reels, polls, apoyos, grupos, streaming, promos)
  Stream<List<Map<String, dynamic>>> streamClinicContent(String clinicId) {
    final subs = <StreamSubscription>[];
    final controller = StreamController<List<Map<String, dynamic>>>(
      onCancel: () {
        for (final s in subs) {
          s.cancel();
        }
      },
    );
    // map: type -> map of id -> doc data
    final all = <String, Map<String, Map<String, dynamic>>>{};
    final collections = [
      'posts', 'events', 'reels', 'polls', 'apoyos', 'grupos', 'streaming', 'promotions'
    ];

    void emitMerged() {
      final merged = <Map<String, dynamic>>[];
      for (final typeMap in all.values) {
        merged.addAll(typeMap.values);
      }
      merged.sort((a, b) {
        final at = a['createdAt'] as Timestamp;
        final bt = b['createdAt'] as Timestamp;
        return bt.compareTo(at);
      });
      if (!controller.isClosed) controller.add(merged);
    }

    for (final col in collections) {
      all[col] = {};
      final sub = _firestore.collection(col).where('clinicId', isEqualTo: clinicId).snapshots().listen(
        (snap) {
          final typeMap = all[col]!;
          typeMap.clear();
          for (final doc in snap.docs) {
            final data = doc.data();
            data['_type'] = col;
            data['_id'] = doc.id;
            data['createdAt'] = data['createdAt'] ?? Timestamp.now();
            typeMap[doc.id] = data;
          }
          emitMerged();
        },
        onError: (_) {},
      );
      subs.add(sub);
    }
    return controller.stream;
  }

  // ── Treatment Confessions ─────────────────────────────
  Future<List<TreatmentConfessionModel>> getTreatmentConfessions(
    String clinicId, {
    bool onlyApproved = true,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection('treatment_confessions')
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (onlyApproved) query = query.where('isApproved', isEqualTo: true);
    final snap = await query.get();
    return snap.docs
        .map((d) => TreatmentConfessionModel.fromMap(
            d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Stream<List<TreatmentConfessionModel>> streamTreatmentConfessions(
    String clinicId, {
    bool onlyApproved = false,
  }) {
    Query query = _firestore
        .collection('treatment_confessions')
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true);
    if (onlyApproved) query = query.where('isApproved', isEqualTo: true);
    return query.snapshots().map((snap) => snap.docs
        .map((d) => TreatmentConfessionModel.fromMap(
            d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  Future<String> createTreatmentConfession(
      TreatmentConfessionModel confession) async {
    final ref = _firestore.collection('treatment_confessions').doc();
    final data = confession.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await ref.set(data);
    return ref.id;
  }

  Future<void> approveTreatmentConfession(String id) async {
    await _firestore
        .collection('treatment_confessions')
        .doc(id)
        .update({'isApproved': true});
  }

  Future<void> deleteTreatmentConfession(String id) async {
    await _firestore.collection('treatment_confessions').doc(id).delete();
  }

  // ── Clinical Stories ───────────────────────────────────
  Stream<List<StoryModel>> streamClinicalStories(String clinicId) {
    return _firestore
        .collection('stories')
        .where('sourceType', isEqualTo: 'clinical')
        .where('sourceId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                StoryModel.fromJson(d.data(), d.id))
            .toList());
  }

  Future<List<ClinicModel>> getClinicsForUser(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final clinicId = userDoc.data()?['clinicId'] as String?;
      if (clinicId == null || clinicId.isEmpty) return [];
      final clinicDoc = await _firestore.collection('clinics').doc(clinicId).get();
      if (clinicDoc.exists) {
        return [ClinicModel.fromMap(clinicDoc.data()!, clinicDoc.id)];
      }
      return [];
    } catch (e) {
      debugPrint('getClinicsForUser: $e');
      return [];
    }
  }
}
