import 'package:cloud_firestore/cloud_firestore.dart';

class TurnoRequestModel {
  final String id;
  final String turnoId;
  final String employeeId;
  final String employeeName;
  final String type; // novedad, cambio_horario, cambio_turno, intercambio
  final String details;
  final String status; // 'pending', 'approved', 'rejected'
  final String? targetEmployeeId;
  final String? targetEmployeeName;
  final String? targetTurnoId;
  final DateTime? requestedDate;
  final String? requestedStartTime;
  final String? requestedEndTime;
  final DateTime createdAt;

  TurnoRequestModel({
    required this.id,
    required this.turnoId,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.details,
    required this.status,
    this.targetEmployeeId,
    this.targetEmployeeName,
    this.targetTurnoId,
    this.requestedDate,
    this.requestedStartTime,
    this.requestedEndTime,
    required this.createdAt,
  });

  factory TurnoRequestModel.fromJson(Map<String, dynamic> map, String id) {
    return TurnoRequestModel(
      id: id,
      turnoId: map['turnoId'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      type: map['type'] ?? 'novedad',
      details: map['details'] ?? '',
      status: map['status'] ?? 'pending',
      targetEmployeeId: map['targetEmployeeId'],
      targetEmployeeName: map['targetEmployeeName'],
      targetTurnoId: map['targetTurnoId'],
      requestedDate: (map['requestedDate'] as Timestamp?)?.toDate(),
      requestedStartTime: map['requestedStartTime'],
      requestedEndTime: map['requestedEndTime'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'turnoId': turnoId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'type': type,
      'details': details,
      'status': status,
      'targetEmployeeId': targetEmployeeId,
      'targetEmployeeName': targetEmployeeName,
      'targetTurnoId': targetTurnoId,
      'requestedDate':
          requestedDate != null ? Timestamp.fromDate(requestedDate!) : null,
      'requestedStartTime': requestedStartTime,
      'requestedEndTime': requestedEndTime,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
