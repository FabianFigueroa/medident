import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/patient-model.dart';
import 'package:medident/core/models/clinical-record-model.dart';

class PatientService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore.collection('patient_profiles');
  CollectionReference<Map<String, dynamic>> get _records =>
      _firestore.collection('clinical_records');

  Stream<List<PatientModel>> streamPatientsByClinic(String clinicId) {
    // Se filtra por clínica (un solo campo, sin índice compuesto) y el rol
    // se descarta en memoria para no depender de índices de Firestore.
    return _users
        .where('clinicId', isEqualTo: clinicId)
        .snapshots()
        .map((snap) => snap.docs
            .where((d) => d.data()['role'] == 'patient')
            .map((d) {
              final data = d.data();
              return PatientModel(
                id: d.id,
                fullName: data['fullName'] ?? '',
                photo: data['imageUrl'],
                phone: data['phoneNumber'],
                email: data['email'],
                patientCode: data['patientCode'] ?? data['uniqueCode'],
                lastVisit: data['lastVisit'] != null
                    ? (data['lastVisit'] as Timestamp).toDate()
                    : null,
              );
            }).toList());
  }

  Future<PatientModel?> getPatientDetail(String uid) async {
    try {
      final userDoc = await _users.doc(uid).get();
      if (!userDoc.exists) return null;
      final userData = userDoc.data()!;
      final profileDoc = await _profiles.doc(uid).get();
      final profileData = profileDoc.data();

      return _merge(uid, userData, profileData);
    } catch (e) {
      debugPrint('getPatientDetail: $e');
      return null;
    }
  }

  Future<List<PatientModel>> searchPatients(String clinicId, String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final q = query.toLowerCase();
      final snap = await _users
          .where('clinicId', isEqualTo: clinicId)
          .get();
      return snap.docs
          .where((d) => d.data()['role'] == 'patient')
          .map((d) {
            final data = d.data();
            return PatientModel(
              id: d.id,
              fullName: data['fullName'] ?? '',
              photo: data['imageUrl'],
              phone: data['phoneNumber'],
              email: data['email'],
              patientCode: data['patientCode'] ?? data['uniqueCode'],
            );
          })
          .where((p) =>
              p.fullName.toLowerCase().contains(q) ||
              p.id.toLowerCase().contains(q) ||
              (p.patientCode ?? '').toLowerCase().contains(q) ||
              (p.phone ?? '').contains(q))
          .toList();
    } catch (e) {
      debugPrint('searchPatients: $e');
      return [];
    }
  }

  /// Busca un paciente por su código QR o por su UID dentro de la clínica.
  Future<PatientModel?> getPatientByCode(String code, {String? clinicId}) async {
    final value = code.trim();
    if (value.isEmpty) return null;
    try {
      QuerySnapshot<Map<String, dynamic>>? snap =
          await _users.where('patientCode', isEqualTo: value).limit(1).get();
      if (snap.docs.isEmpty) {
        snap = await _users.where('uniqueCode', isEqualTo: value).limit(1).get();
      }
      DocumentSnapshot<Map<String, dynamic>>? doc =
          snap.docs.isEmpty ? null : snap.docs.first;
      if (doc == null) {
        final byId = await _users.doc(value).get();
        if (byId.exists) doc = byId;
      }
      if (doc == null) return null;
      final data = doc.data();
      if (data == null || data['role'] != 'patient') return null;
      if (clinicId != null &&
          clinicId.isNotEmpty &&
          data['clinicId'] != clinicId) {
        return null;
      }
      return PatientModel(
        id: doc.id,
        fullName: data['fullName'] ?? '',
        photo: data['imageUrl'],
        phone: data['phoneNumber'],
        email: data['email'],
        patientCode: data['patientCode'] ?? data['uniqueCode'],
      );
    } catch (e) {
      debugPrint('getPatientByCode: $e');
      return null;
    }
  }

  Future<String> createPatient({
    String? uid,
    required String fullName,
    required String clinicId,
    String? photo,
    String? phone,
    String? email,
    String? gender,
    DateTime? birthDate,
    String? address,
    String? documentId,
    String? maritalStatus,
    String? occupation,
    String? education,
    String? smoker,
    String? alcohol,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? referredBy,
    String? bloodType,
    List<String>? allergies,
    List<String>? medications,
    List<String>? medicalHistory,
    List<String>? dentalHistory,
    String? insuranceProvider,
    String? insuranceId,
    String? notes,
    String? patientCode,
  }) async {
    final now = FieldValue.serverTimestamp();
    final id = (uid != null && uid.isNotEmpty) ? uid : _users.doc().id;
    final code = (patientCode != null && patientCode.trim().isNotEmpty)
        ? patientCode.trim().toUpperCase()
        : generatePatientCode();

    await _users.doc(id).set({
      'uid': id,
      'fullName': fullName,
      'email': email ?? '',
      'phoneNumber': phone,
      'imageUrl': photo,
      'role': 'patient',
      'clinicId': clinicId,
      'patientCode': code,
      'uniqueCode': code,
      'gender': gender,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate) : null,
      'address': address,
      'documentId': documentId,
      'maritalStatus': maritalStatus,
      'occupation': occupation,
      'education': education,
      'smoker': smoker,
      'alcohol': alcohol,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'referredBy': referredBy,
      'isActive': true,
      'followersCount': 0,
      'followingCount': 0,
      'servicesCount': 0,
      'createdAt': now,
      'updatedAt': now,
    });

    await _profiles.doc(id).set({
      'bloodType': bloodType,
      'allergies': allergies ?? [],
      'medications': medications ?? [],
      'medicalHistory': medicalHistory ?? [],
      'dentalHistory': dentalHistory ?? [],
      'insuranceProvider': insuranceProvider,
      'insuranceId': insuranceId,
      'notes': notes,
      'clinicIds': [clinicId],
      'createdAt': now,
      'updatedAt': now,
    });

    return id;
  }

  /// Código corto e imprimible para el QR del paciente.
  static String generatePatientCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final suffix = List.generate(6, (_) => chars[random.nextInt(chars.length)])
        .join();
    return 'MED-$suffix';
  }

  Future<void> updatePatientProfile(String uid, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _profiles.doc(uid).update(updates);
  }

  Future<void> updateUserField(String uid, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _users.doc(uid).update(updates);
  }

  Future<void> deletePatient(String uid) async {
    await _users.doc(uid).update({'isActive': false});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamClinicalRecords(
    String patientId,
    String clinicId,
  ) {
    // Un solo filtro para no requerir índice compuesto. El filtro por clínica
    // y el orden por fecha se aplican en la pantalla.
    return _records
        .where('patientId', isEqualTo: patientId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamClinicClinicalRecords(
    String clinicId,
  ) {
    return _records
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<String> addClinicalRecord({
    required String patientId,
    required String clinicId,
    required String dentistName,
    required DateTime date,
    String? diagnosis,
    String? treatment,
    String? procedure,
    String? notes,
    List<String>? attachments,
    String? odontogramId,
  }) async {
    final ref = _records.doc();
    await ref.set({
      'patientId': patientId,
      'clinicId': clinicId,
      'dentistName': dentistName,
      'date': date.toIso8601String(),
      'diagnosis': diagnosis,
      'treatment': treatment,
      'procedure': procedure,
      'notes': notes,
      'attachments': attachments ?? [],
      'odontogramId': odontogramId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateClinicalRecord(
    String recordId,
    Map<String, dynamic> updates,
  ) async {
    await _records.doc(recordId).update(updates);
  }

  Future<void> deleteClinicalRecord(String recordId) async {
    await _records.doc(recordId).delete();
  }

  // ── Odontogramas ──────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _odontograms =>
      _firestore.collection('odontograms');

  Future<Map<String, dynamic>?> getOdontogramByPatient(String patientId) async {
    try {
      final snap = await _odontograms
          .where('patientId', isEqualTo: patientId)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();
        data['id'] = snap.docs.first.id;
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('getOdontogramByPatient: $e');
      return null;
    }
  }

  Future<void> saveOdontogram({
    required String patientId,
    required String patientName,
    required String dentistId,
    required Map<String, dynamic> teethMap,
  }) async {
    await _odontograms.add({
      'patientId': patientId,
      'patientName': patientName,
      'dentistId': dentistId,
      'teethMap': teethMap,
      'notes': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOdontogram(
    String odontogramId,
    Map<String, dynamic> teethMap,
  ) async {
    await _odontograms.doc(odontogramId).update({
      'teethMap': teethMap,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  PatientModel _merge(
    String uid,
    Map<String, dynamic> userData,
    Map<String, dynamic>? profileData,
  ) {
    return PatientModel(
      id: uid,
      fullName: userData['fullName'] ?? '',
      photo: userData['imageUrl'],
      phone: userData['phoneNumber'],
      email: userData['email'],
      lastVisit: userData['lastVisit'] != null
          ? (userData['lastVisit'] as Timestamp).toDate()
          : null,
      bloodType: profileData?['bloodType'],
      allergies: profileData != null && profileData['allergies'] != null
          ? List<String>.from(profileData['allergies'])
          : [],
      medications: profileData != null && profileData['medications'] != null
          ? List<String>.from(profileData['medications'])
          : [],
      medicalHistory: profileData != null && profileData['medicalHistory'] != null
          ? List<String>.from(profileData['medicalHistory'])
          : [],
      dentalHistory: profileData != null && profileData['dentalHistory'] != null
          ? List<String>.from(profileData['dentalHistory'])
          : [],
      insuranceProvider: profileData?['insuranceProvider'],
      insuranceId: profileData?['insuranceId'],
      patientCode: userData['patientCode'] ?? userData['uniqueCode'],
      notes: profileData?['notes'],
      clinicIds: profileData != null && profileData['clinicIds'] != null
          ? List<String>.from(profileData['clinicIds'])
          : [userData['clinicId'] ?? ''],
    );
  }
}
