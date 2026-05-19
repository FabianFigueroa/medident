import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/enums/user-gender.dart';

class PatientModel {
  final String id;
  final String fullName;
  final String email;
  final String? photo;
  final String? phone;
  final DateTime? lastVisit;
  final UserGender? gender;
  final DateTime? birthDate;
  final String? address;
  final String? bloodType;
  final List<String> allergies;
  final List<String> medications;
  final List<String> medicalHistory;
  final List<String> dentalHistory;
  final String? insuranceProvider;
  final String? insuranceId;
  final String? notes;
  final List<String> clinicIds;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const PatientModel({
    required this.id,
    required this.fullName,
    this.email = '',
    this.photo,
    this.phone,
    this.lastVisit,
    this.gender,
    this.birthDate,
    this.address,
    this.bloodType,
    this.allergies = const [],
    this.medications = const [],
    this.medicalHistory = const [],
    this.dentalHistory = const [],
    this.insuranceProvider,
    this.insuranceId,
    this.notes,
    this.clinicIds = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map, String id) {
    return PatientModel(
      id: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      photo: map['imageUrl'] ?? map['photo'],
      phone: map['phone'] ?? map['phoneNumber'],
      lastVisit: (map['lastVisit'] as Timestamp?)?.toDate(),
      gender: map['gender'] != null ? UserGender.values.firstWhere((g) => g.name == map['gender'], orElse: () => UserGender.femenino) : null,
      birthDate: (map['birthDate'] as Timestamp?)?.toDate(),
      address: map['address'],
      bloodType: map['bloodType'],
      allergies: List<String>.from(map['allergies'] ?? []),
      medications: List<String>.from(map['medications'] ?? []),
      medicalHistory: List<String>.from(map['medicalHistory'] ?? []),
      dentalHistory: List<String>.from(map['dentalHistory'] ?? []),
      insuranceProvider: map['insuranceProvider'],
      insuranceId: map['insuranceId'],
      notes: map['notes'],
      clinicIds: List<String>.from(map['clinicIds'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'photo': photo,
      'phone': phone,
      'gender': gender?.name,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'address': address,
      'bloodType': bloodType,
      'allergies': allergies,
      'medications': medications,
      'medicalHistory': medicalHistory,
      'dentalHistory': dentalHistory,
      'insuranceProvider': insuranceProvider,
      'insuranceId': insuranceId,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
