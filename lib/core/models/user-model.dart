import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/enums/user-gender.dart';
import 'package:medident/core/models/roles/user_role.dart';

// |X| Campos eliminados (ya están en otras colecciones):
//    shopkeeperId, shopId, salary, employeeCode, emergencyContact*,
//    identificationNumber, hiringDate, contractType, rfidUid,
//    userSales, photosUrl
// ✅ followersCount / followingCount: contadores desnormalizados (int)
//    — evitan queries extra al mostrar perfil o sugerencias

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? userName;
  final String? phoneNumber;
  final String? imageUrl;
  final UserRole role;
  final UserGender? gender;
  final DateTime? birthDate;
  final String? address;
  final String? speciality;
  final String? status;
  final bool isActive;
  final int followersCount;
  final int followingCount;
  final int servicesCount;
  final String? clinicId;
  final bool isClinicOwner;
  final String? bio;
  final String? clinicName;
  final String? website;
  final String? licenseNumber;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.userName,
    this.phoneNumber,
    this.imageUrl,
    required this.role,
    this.gender,
    this.birthDate,
    this.address,
    this.speciality,
    this.status,
    this.isActive = true,
    this.followersCount = 0,
    this.followingCount = 0,
    this.servicesCount = 0,
    this.clinicId,
    this.isClinicOwner = false,
    this.bio,
    this.clinicName,
    this.website,
    this.licenseNumber,
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? userName,
    String? phoneNumber,
    String? imageUrl,
    UserRole? role,
    UserGender? gender,
    DateTime? birthDate,
    String? address,
    String? speciality,
    String? status,
    bool? isActive,
    int? followersCount,
    int? followingCount,
    String? clinicId,
    bool? isClinicOwner,
    String? bio,
    String? clinicName,
    String? website,
    String? licenseNumber,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      speciality: speciality ?? this.speciality,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      clinicId: clinicId ?? this.clinicId,
      isClinicOwner: isClinicOwner ?? this.isClinicOwner,
      bio: bio ?? this.bio,
      clinicName: clinicName ?? this.clinicName,
      website: website ?? this.website,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
      'role': role.name,
      'gender': gender?.name,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'address': address,
      'speciality': speciality,
      'status': status,
      'isActive': isActive,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'servicesCount': servicesCount,
      'clinicId': clinicId,
      'isClinicOwner': isClinicOwner,
      'bio': bio,
      'clinicName': clinicName,
      'website': website,
      'licenseNumber': licenseNumber,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    // ── Role ─────────────────────────────────────────────────
    final rawRole = (map['role'] ?? 'patient').toString();
    final resolvedRole = UserRole.values.firstWhere(
      (r) => r.name == rawRole,
      orElse: () => UserRole.patient,
    );

    // ── Gender — tu enum solo tiene: femenino, masculino ─────
    UserGender? resolvedGender;
    final rawGender = map['gender']?.toString();
    if (rawGender != null) {
      resolvedGender = UserGender.values.firstWhere(
        (g) => g.name == rawGender,
        orElse: () => UserGender.femenino, // fallback seguro
      );
    }

    return UserModel(
      uid: map['uid'] ?? id,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      userName: map['userName'],
      phoneNumber: map['phoneNumber'],
      imageUrl: map['imageUrl'],
      role: resolvedRole,
      gender: resolvedGender,
      birthDate: (map['birthDate'] is Timestamp)
          ? (map['birthDate'] as Timestamp).toDate()
          : null,
      address: map['address'],
      // ✅ compatibilidad con campo viejo 'jobTitle'
      speciality: map['speciality'] ?? map['jobTitle'],
      status: map['status'],
      isActive: map['isActive'] ?? true,
      followersCount: ( map['followersCount'] ?? map['userFollowers'] ?? 0) is int ? (map['followersCount'] ?? map['userFollowers'] ?? 0) : int.tryParse('${map['followersCount'] ?? map['userFollowers'] ?? 0}') ?? 0,
      followingCount: ( map['followingCount'] ?? map['userFollows'] ?? 0) is int ? (map['followingCount'] ?? map['userFollows'] ?? 0) : int.tryParse('${map['followingCount'] ?? map['userFollows'] ?? 0}') ?? 0,
      servicesCount: ( map['servicesCount'] ?? map['userSales'] ?? 0) is int ? (map['servicesCount'] ?? map['userSales'] ?? 0) : int.tryParse('${map['servicesCount'] ?? map['userSales'] ?? 0}') ?? 0,
      clinicId: map['clinicId'],
      isClinicOwner: map['isClinicOwner'] ?? false,
      bio: map['bio'],
      clinicName: map['clinicName'],
      website: map['website'],
      licenseNumber: map['licenseNumber'],
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  int get userFollowers => followersCount;
}
