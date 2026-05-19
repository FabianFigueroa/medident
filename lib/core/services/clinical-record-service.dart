import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/clinical-record-model.dart';

class ClinicalRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _records =>
      _firestore.collection('clinical_records');

  Stream<List<ClinicalRecord>> streamRecordsByPatient(
      String patientId, String clinicId) {
    return _records
        .where('patientId', isEqualTo: patientId)
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ClinicalRecord.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<ClinicalRecord>> streamRecordsByClinic(String clinicId) {
    return _records
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ClinicalRecord.fromMap(d.data(), d.id))
            .toList());
  }

  Future<String> addRecord({
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
    try {
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
    } catch (e) {
      debugPrint('ClinicalRecordService.addRecord error: $e');
      rethrow;
    }
  }

  Future<void> updateRecord(
      String recordId, Map<String, dynamic> updates) async {
    try {
      await _records.doc(recordId).update(updates);
    } catch (e) {
      debugPrint('ClinicalRecordService.updateRecord error: $e');
      rethrow;
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      await _records.doc(recordId).delete();
    } catch (e) {
      debugPrint('ClinicalRecordService.deleteRecord error: $e');
      rethrow;
    }
  }
}
