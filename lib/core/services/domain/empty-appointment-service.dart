import 'package:medident/core/models/appointment-model.dart';
import 'package:medident/core/services/domain/appointment-service.dart';

/// Servicio vacío para roles sin clínica: evita consultas a Firestore y
/// mantiene la agenda en estado "sin clínica" hasta que el usuario se una.
class EmptyAppointmentService implements IAppointmentService {
  @override
  Stream<List<AppointmentModel>> streamAppointments() =>
      Stream.value(const []);

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
  }) async =>
      '';

  @override
  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {}

  @override
  Future<void> deleteAppointment(String appointmentId) async {}
}
