import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String iconName;
  final String category;
  final int durationMinutes;
  final bool isActive;
  final String? clinicId;
  final DateTime createdAt;

  TreatmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.iconName,
    required this.category,
    required this.durationMinutes,
    this.isActive = true,
    this.clinicId,
    required this.createdAt,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  factory TreatmentModel.fromJson(Map<String, dynamic> map, String id) {
    return TreatmentModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice']?.toDouble(),
      iconName: map['iconName'] ?? 'medical',
      category: map['category'] ?? 'general',
      durationMinutes: map['durationMinutes'] ?? 30,
      isActive: map['isActive'] ?? true,
      clinicId: map['clinicId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'iconName': iconName,
      'category': category,
      'durationMinutes': durationMinutes,
      'isActive': isActive,
      'clinicId': clinicId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
