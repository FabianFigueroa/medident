import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/appointment-model.dart';
import 'package:medident/core/services/domain/appointment-service.dart';

/// Servicio de citas para el rol paciente: escucha solo las citas donde el
/// usuario autenticado es el paciente y permite crearlas/actualizarlas.
class PatientAppointmentService implements IAppointmentService {
  final String patientId;
  final FirebaseFirestore _firestore;

  PatientAppointmentService({
    required this.patientId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<AppointmentModel>> streamAppointments() {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => AppointmentModel.fromJson(d.data(), d.id)).toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  @override
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

  @override
  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteAppointment(String appointmentId) =>
      _firestore.collection('appointments').doc(appointmentId).delete();
}
