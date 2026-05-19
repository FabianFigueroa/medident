import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/appointment-model.dart';
import 'package:medident/core/services/domain/appointment-service.dart';
import 'package:medident/core/services/clinic-service.dart';

class ClinicAppointmentService implements IAppointmentService {
  final ClinicService _clinicService;
  final String clinicId;

  ClinicAppointmentService({required this.clinicId, ClinicService? clinicService})
      : _clinicService = clinicService ?? ClinicService();

  @override
  Stream<List<AppointmentModel>> streamAppointments() {
    return _clinicService.streamAppointmentsByClinic(clinicId).map(
      (snap) => snap.docs
          .map((d) => AppointmentModel.fromJson(d.data(), d.id))
          .toList(),
    );
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
  }) {
    return _clinicService.bookAppointment(
      clinicId: clinicId ?? this.clinicId,
      patientId: patientId,
      patientName: patientName,
      dentistId: dentistId,
      dentistName: dentistName,
      treatmentName: treatmentName,
      date: date,
      timeSlot: timeSlot,
      patientPhoto: patientPhoto,
      notes: notes,
    );
  }

  @override
  Future<void> updateAppointmentStatus(String appointmentId, String status) {
    return _clinicService.updateAppointmentStatus(appointmentId, status);
  }

  @override
  Future<void> deleteAppointment(String appointmentId) {
    return _clinicService.deleteAppointment(appointmentId);
  }
}
