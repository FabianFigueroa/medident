import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String title;
  final String description;
  final String company;
  final String? companyLogo;
  final String location;
  final String type; // 'full-time', 'part-time', 'contract', 'remote'
  final double? salary;
  final String? salaryRange;
  final List<String>? requirements;
  final List<String>? benefits;
  final String? specialty; // Especialidad dental requerida
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final String? postedById; // ID del usuario que publicó
  final String? clinicId;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    this.companyLogo,
    required this.location,
    required this.type,
    this.salary,
    this.salaryRange,
    this.requirements,
    this.benefits,
    this.specialty,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
    this.postedById,
    this.clinicId,
  });

  factory JobModel.fromJson(Map<String, dynamic> map, String id) {
    return JobModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      company: map['company'] ?? '',
      companyLogo: map['companyLogo'],
      location: map['location'] ?? '',
      type: map['type'] ?? 'full-time',
      salary: map['salary']?.toDouble(),
      salaryRange: map['salaryRange'],
      requirements: map['requirements'] != null ? List<String>.from(map['requirements']) : null,
      benefits: map['benefits'] != null ? List<String>.from(map['benefits']) : null,
      specialty: map['specialty'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
      postedById: map['postedById'],
      clinicId: map['clinicId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'company': company,
      'companyLogo': companyLogo,
      'location': location,
      'type': type,
      'salary': salary,
      'salaryRange': salaryRange,
      'requirements': requirements,
      'benefits': benefits,
      'specialty': specialty,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isActive': isActive,
      'postedById': postedById,
      'clinicId': clinicId,
    };
  }
}
