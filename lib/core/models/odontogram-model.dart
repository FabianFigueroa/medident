import 'package:cloud_firestore/cloud_firestore.dart';

class OdontogramModel {
  final String id;
  final String patientId;
  final String patientName;
  final String dentistId;
  final Map<String, dynamic> teethMap;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OdontogramModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.dentistId,
    required this.teethMap,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  int get totalTeeth => teethMap.length;

  factory OdontogramModel.fromJson(Map<String, dynamic> map, String id) {
    return OdontogramModel(
      id: id,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      dentistId: map['dentistId'] ?? '',
      teethMap: Map<String, dynamic>.from(map['teethMap'] ?? {}),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
