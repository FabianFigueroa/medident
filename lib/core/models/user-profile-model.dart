import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/media-item.dart';
import 'package:medident/core/models/user-model.dart';

class UserProfileModel {
  final String uid;
  final String? address;
  final DateTime? birthDate;
  final String? gender;
  final String? identificationNumber;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;
  final DateTime? updatedAt;

  const UserProfileModel({
    required this.uid,
    this.address,
    this.birthDate,
    this.gender,
    this.identificationNumber,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> map, String uid) {
    return UserProfileModel(
      uid: uid,
      address: map['address'] as String?,
      birthDate: (map['birthDate'] as Timestamp?)?.toDate(),
      gender: map['gender'] as String?,
      identificationNumber: map['identificationNumber'] as String?,
      emergencyContactName: map['emergencyContactName'] as String?,
      emergencyContactPhone: map['emergencyContactPhone'] as String?,
      emergencyContactRelationship: map['emergencyContactRelationship'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    if (address != null) 'address': address,
    if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
    if (gender != null) 'gender': gender,
    if (identificationNumber != null) 'identificationNumber': identificationNumber,
    if (emergencyContactName != null) 'emergencyContactName': emergencyContactName,
    if (emergencyContactPhone != null) 'emergencyContactPhone': emergencyContactPhone,
    if (emergencyContactRelationship != null) 'emergencyContactRelationship': emergencyContactRelationship,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
