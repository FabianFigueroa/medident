import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String uid;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? imageUrl;
  final List<String> permissions;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const AdminModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.imageUrl,
    this.permissions = const ['dashboard', 'users', 'promotions'],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminModel.fromMap(Map<String, dynamic> map, String id) {
    return AdminModel(
      uid: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      imageUrl: map['imageUrl'],
      permissions: List<String>.from(map['permissions'] ?? ['dashboard', 'users', 'promotions']),
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
      'permissions': permissions,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
