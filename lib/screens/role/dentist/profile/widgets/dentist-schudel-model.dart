import 'package:flutter/material.dart';

// ─────────────────────────────────────────
//  USER MODEL
// ─────────────────────────────────────────
class UserSchudelModel {
  final String uid;
  final String fullName;
  final String firstName;
  final String avatarUrl;
  final String role; // 'doctor' | 'patient' | 'admin'
  final String specialty;
  final Color avatarColor;
  final bool hasActiveStory;
  final bool storyIsSeen;

  const UserSchudelModel({
    required this.uid,
    required this.fullName,
    required this.firstName,
    required this.avatarUrl,
    required this.role,
    required this.specialty,
    required this.avatarColor,
    this.hasActiveStory = false,
    this.storyIsSeen = false,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }
}

// ─────────────────────────────────────────
//  CLINIC MODEL (Historia clínica del paciente)
// ─────────────────────────────────────────
class ClinicModel {
  final String patientUid;
  final String bloodType;
  final List<String> allergies;
  final List<String> currentMedications;
  final List<String> medicalHistory;
  final List<String> dentalHistory;
  final String insuranceProvider;
  final String insuranceId;
  final DateTime lastVisit;
  final String notes;
  final List<ClinicRecord> records;

  const ClinicModel({
    required this.patientUid,
    required this.bloodType,
    required this.allergies,
    required this.currentMedications,
    required this.medicalHistory,
    required this.dentalHistory,
    required this.insuranceProvider,
    required this.insuranceId,
    required this.lastVisit,
    required this.notes,
    required this.records,
  });
}

class ClinicRecord {
  final String id;
  final DateTime date;
  final String procedure;
  final String diagnosis;
  final String doctorUid;
  final String notes;
  final List<String> attachmentUrls;
  final double cost;

  const ClinicRecord({
    required this.id,
    required this.date,
    required this.procedure,
    required this.diagnosis,
    required this.doctorUid,
    required this.notes,
    required this.attachmentUrls,
    required this.cost,
  });
}

// ─────────────────────────────────────────
//  APPOINTMENT STATUS
// ─────────────────────────────────────────
enum AppointmentStatus {
  newAppointment,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
  rescheduled,
}

extension AppointmentStatusExt on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.newAppointment:
        return 'Nueva';
      case AppointmentStatus.confirmed:
        return 'Confirmada';
      case AppointmentStatus.inProgress:
        return 'En curso';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.noShow:
        return 'No asistió';
      case AppointmentStatus.rescheduled:
        return 'Reprogramada';
    }
  }

  Color get color {
    switch (this) {
      case AppointmentStatus.newAppointment:
        return const Color(0xFF007AFF); // Apple Blue
      case AppointmentStatus.confirmed:
        return const Color(0xFF5856D6); // Apple Indigo
      case AppointmentStatus.inProgress:
        return const Color(0xFFFF9500); // Apple Orange
      case AppointmentStatus.completed:
        return const Color(0xFF34C759); // Apple Green
      case AppointmentStatus.cancelled:
        return const Color(0xFFFF3B30); // Apple Red
      case AppointmentStatus.noShow:
        return const Color(0xFF8E8E93); // Apple Gray
      case AppointmentStatus.rescheduled:
        return const Color(0xFFFF2D55); // Apple Pink
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AppointmentStatus.newAppointment:
        return const Color(0xFFE8F0FF);
      case AppointmentStatus.confirmed:
        return const Color(0xFFEEEEFF);
      case AppointmentStatus.inProgress:
        return const Color(0xFFFFF3E0);
      case AppointmentStatus.completed:
        return const Color(0xFFE8F5EE);
      case AppointmentStatus.cancelled:
        return const Color(0xFFFCE8E8);
      case AppointmentStatus.noShow:
        return const Color(0xFFF2F2F7);
      case AppointmentStatus.rescheduled:
        return const Color(0xFFFFF0F3);
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentStatus.newAppointment:
        return Icons.fiber_new_rounded;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case AppointmentStatus.inProgress:
        return Icons.radio_button_checked_rounded;
      case AppointmentStatus.completed:
        return Icons.check_circle_rounded;
      case AppointmentStatus.cancelled:
        return Icons.cancel_rounded;
      case AppointmentStatus.noShow:
        return Icons.person_off_rounded;
      case AppointmentStatus.rescheduled:
        return Icons.update_rounded;
    }
  }
}

// ─────────────────────────────────────────
//  MAIN MODEL: DentistSchudelModel
// ─────────────────────────────────────────
class DentistSchudelModel {
  final String id;
  final UserSchudelModel assignedDoctor;
  final UserSchudelModel patient;
  final DateTime atTimeInit;
  final DateTime atTimeFinal;
  final String schudelCaption; // título/descripción de la cita
  final String serviceType; // tipo de servicio dental/médico
  final String clinic;
  final AppointmentStatus status;
  final ClinicModel? clinicHistory;
  final String? consultingRoom; // consultorio/sala
  final double cost;
  final String? notes;
  final bool isUrgent;
  final bool requiresLab;
  final List<String> requiredEquipment;
  final String? previousAppointmentId;

  const DentistSchudelModel({
    required this.id,
    required this.assignedDoctor,
    required this.patient,
    required this.atTimeInit,
    required this.atTimeFinal,
    required this.schudelCaption,
    required this.serviceType,
    required this.clinic,
    required this.status,
    this.clinicHistory,
    this.consultingRoom,
    required this.cost,
    this.notes,
    this.isUrgent = false,
    this.requiresLab = false,
    this.requiredEquipment = const [],
    this.previousAppointmentId,
  });

  /// Duración real de la cita en minutos
  int get durationMinutes => atTimeFinal.difference(atTimeInit).inMinutes;

  /// Cuántos "slots" de 30min ocupa (para calcular altura en el widget)
  double get slotsCount => durationMinutes / 30.0;

  /// Altura en píxeles en el timeline (1 slot = 68px)
  double get timelineHeight => slotsCount * 68.0;

  /// Offset desde la medianoche en minutos (para posición vertical)
  int get startOffsetMinutes =>
      atTimeInit.hour * 60 + atTimeInit.minute;

  /// String de hora formateada
  String get timeRangeLabel {
    final startH = atTimeInit.hour.toString().padLeft(2, '0');
    final startM = atTimeInit.minute.toString().padLeft(2, '0');
    final endH = atTimeFinal.hour.toString().padLeft(2, '0');
    final endM = atTimeFinal.minute.toString().padLeft(2, '0');
    return '$startH:$startM – $endH:$endM · $durationMinutes min';
  }
}
