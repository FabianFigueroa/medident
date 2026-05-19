import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String? patientPhoto;
  final String dentistId;
  final String dentistName;
  final String treatmentName;
  final DateTime date;
  final String timeSlot;
  final String status;
  final String? notes;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.patientPhoto,
    required this.dentistId,
    this.dentistName = '',
    required this.treatmentName,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool get isUpcoming => date.isAfter(DateTime.now());

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? patientPhoto,
    String? dentistId,
    String? dentistName,
    String? treatmentName,
    DateTime? date,
    String? timeSlot,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhoto: patientPhoto ?? this.patientPhoto,
      dentistId: dentistId ?? this.dentistId,
      dentistName: dentistName ?? this.dentistName,
      treatmentName: treatmentName ?? this.treatmentName,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      patientPhoto: map['patientPhoto'],
      dentistId: map['dentistId'] ?? '',
      dentistName: map['dentistName'] ?? '',
      treatmentName: map['treatmentName'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSlot: map['timeSlot'] ?? '',
      status: map['status'] ?? 'pending',
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'patientPhoto': patientPhoto,
      'dentistId': dentistId,
      'dentistName': dentistName,
      'treatmentName': treatmentName,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
