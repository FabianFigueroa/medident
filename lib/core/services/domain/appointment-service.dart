import 'package:medident/core/models/appointment-model.dart';

abstract class IAppointmentService {
  Stream<List<AppointmentModel>> streamAppointments();
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
  });
  Future<void> updateAppointmentStatus(String appointmentId, String status);
  Future<void> deleteAppointment(String appointmentId);
}
