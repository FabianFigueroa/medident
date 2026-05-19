import 'package:cloud_firestore/cloud_firestore.dart';

class DentistModel {
  final String uid;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? imageUrl;
  final String? specialty;
  final String? licenseNumber;
  final String? clinicId;
  final String? clinicName;
  final String? bio;
  final String? website;
  final int yearsOfExperience;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const DentistModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.imageUrl,
    this.specialty,
    this.licenseNumber,
    this.clinicId,
    this.clinicName,
    this.bio,
    this.website,
    this.yearsOfExperience = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory DentistModel.fromMap(Map<String, dynamic> map, String id) {
    return DentistModel(
      uid: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      imageUrl: map['imageUrl'],
      specialty: map['specialty'],
      licenseNumber: map['licenseNumber'],
      clinicId: map['clinicId'],
      clinicName: map['clinicName'],
      bio: map['bio'],
      website: map['website'],
      yearsOfExperience: map['yearsOfExperience'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
      'specialty': specialty,
      'licenseNumber': licenseNumber,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'bio': bio,
      'website': website,
      'yearsOfExperience': yearsOfExperience,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  DentistModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? imageUrl,
    String? specialty,
    String? licenseNumber,
    String? clinicId,
    String? clinicName,
    String? bio,
    String? website,
    int? yearsOfExperience,
    bool? isActive,
  }) {
    return DentistModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
