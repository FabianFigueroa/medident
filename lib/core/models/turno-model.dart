import 'package:cloud_firestore/cloud_firestore.dart';

class TurnoModel {
  final String id;
  final String clinicId;
  final String dentistId;
  final String employeeId;
  final String employeeName;
  final String? employeePhoto;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final String? notes;
  final DateTime createdAt;

  TurnoModel({
    required this.id,
    required this.clinicId,
    required this.dentistId,
    required this.employeeId,
    required this.employeeName,
    this.employeePhoto,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool get isUpcoming => date.isAfter(DateTime.now()) || isToday;

  String get displayDate {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  TurnoModel copyWith({
    String? id,
    String? clinicId,
    String? dentistId,
    String? employeeId,
    String? employeeName,
    String? employeePhoto,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? status,
    String? notes,
  }) {
    return TurnoModel(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      dentistId: dentistId ?? this.dentistId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeePhoto: employeePhoto ?? this.employeePhoto,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'dentistId': dentistId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeePhoto': employeePhoto,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'notes': notes,
    };
  }

  factory TurnoModel.fromJson(Map<String, dynamic> map, String id) {
    return TurnoModel(
      id: id,
      clinicId: map['clinicId'] ?? '',
      dentistId: map['dentistId'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      employeePhoto: map['employeePhoto'],
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      status: map['status'] ?? 'scheduled',
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
