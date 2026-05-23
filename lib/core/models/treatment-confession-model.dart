import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentConfessionModel {
  final String id;
  final String clinicId;
  final String patientId;
  final String patientName;
  final String? patientPhoto;
  final String treatmentName;
  final String? treatmentCategory;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? beforePhoto;
  final String? afterPhoto;
  final String? description;
  final double rating;
  final bool isApproved;
  final String? createdBy;
  final DateTime createdAt;

  TreatmentConfessionModel({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.patientName,
    this.patientPhoto,
    required this.treatmentName,
    this.treatmentCategory,
    required this.videoUrl,
    this.thumbnailUrl,
    this.beforePhoto,
    this.afterPhoto,
    this.description,
    this.rating = 5.0,
    this.isApproved = false,
    this.createdBy,
    required this.createdAt,
  });

  factory TreatmentConfessionModel.fromMap(
      Map<String, dynamic> map, String id) {
    return TreatmentConfessionModel(
      id: id,
      clinicId: map['clinicId'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      patientPhoto: map['patientPhoto']?.toString(),
      treatmentName: map['treatmentName'] ?? '',
      treatmentCategory: map['treatmentCategory']?.toString(),
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl']?.toString(),
      beforePhoto: map['beforePhoto']?.toString(),
      afterPhoto: map['afterPhoto']?.toString(),
      description: map['description']?.toString(),
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      isApproved: map['isApproved'] ?? false,
      createdBy: map['createdBy']?.toString(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhoto': patientPhoto,
      'treatmentName': treatmentName,
      'treatmentCategory': treatmentCategory,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'beforePhoto': beforePhoto,
      'afterPhoto': afterPhoto,
      'description': description,
      'rating': rating,
      'isApproved': isApproved,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  TreatmentConfessionModel copyWith({
    String? id,
    bool? isApproved,
    double? rating,
    String? description,
    String? thumbnailUrl,
  }) {
    return TreatmentConfessionModel(
      id: id ?? this.id,
      clinicId: clinicId,
      patientId: patientId,
      patientName: patientName,
      patientPhoto: patientPhoto,
      treatmentName: treatmentName,
      treatmentCategory: treatmentCategory,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      beforePhoto: beforePhoto,
      afterPhoto: afterPhoto,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      isApproved: isApproved ?? this.isApproved,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
