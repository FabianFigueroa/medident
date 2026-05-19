import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicModel {
  final String id;
  final String name;
  final String ownerId;
  final String nit;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final Map<String, String>? socialMedia;
  final Map<String, Map<String, String>>? businessHours;
  final String? description;
  final String? logoUrl;
  final String? primaryColor;
  final String apiKey;
  final List<String> employeeIds;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const ClinicModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.nit,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.socialMedia,
    this.businessHours,
    this.description,
    this.logoUrl,
    this.primaryColor,
    required this.apiKey,
    this.employeeIds = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  ClinicModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? nit,
    String? address,
    String? phone,
    String? email,
    String? website,
    Map<String, String>? socialMedia,
    Map<String, Map<String, String>>? businessHours,
    String? description,
    String? logoUrl,
    String? primaryColor,
    String? apiKey,
    List<String>? employeeIds,
    bool? isActive,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ClinicModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      nit: nit ?? this.nit,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      socialMedia: socialMedia ?? this.socialMedia,
      businessHours: businessHours ?? this.businessHours,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      apiKey: apiKey ?? this.apiKey,
      employeeIds: employeeIds ?? this.employeeIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'nit': nit,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'socialMedia': socialMedia,
      'businessHours': businessHours,
      'description': description,
      'logoUrl': logoUrl,
      'primaryColor': primaryColor,
      'apiKey': apiKey,
      'employeeIds': employeeIds,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ClinicModel.fromMap(Map<String, dynamic> map, String id) {
    return ClinicModel(
      id: id,
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      nit: map['nit'] ?? '',
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      website: map['website'],
      socialMedia: map['socialMedia'] != null
          ? Map<String, String>.from(map['socialMedia'])
          : null,
      businessHours: map['businessHours'] != null
          ? (map['businessHours'] as Map).map((k, v) => MapEntry(k as String, Map<String, String>.from(v)))
          : null,
      description: map['description'],
      logoUrl: map['logoUrl'],
      primaryColor: map['primaryColor'],
      apiKey: map['apiKey'] ?? '',
      employeeIds: map['employeeIds'] != null
          ? List<String>.from(map['employeeIds'])
          : [],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }
}
