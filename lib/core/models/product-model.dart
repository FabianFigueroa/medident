import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/promotion-slide-model.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> imageUrls;
  final List<PromotionSlide> slides;
  final String? category;
  final String? clinicId;
  final String? clinicName;
  final double? rating;
  final int? reviewsCount;
  final bool isFeatured;
  final bool isAvailable;
  final bool isActive;
  final String? createdBy;
  final String? terms;
  final String scope;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrls,
    this.slides = const [],
    this.category,
    this.clinicId,
    this.clinicName,
    this.rating,
    this.reviewsCount,
    this.isFeatured = false,
    this.isAvailable = true,
    this.isActive = true,
    this.createdBy,
    this.terms,
    this.scope = 'profile',
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  String get discountPercentage {
    if (!hasDiscount) return '';
    final pct = ((price - discountPrice!) / price * 100).round();
    return '$pct% OFF';
  }

  String get popularityLabel {
    if (rating == null) return '';
    if (rating! >= 4.5) return '🔥 Muy popular';
    if (rating! >= 4.0) return '⭐ Bien valorado';
    return '';
  }

  factory ProductModel.fromJson(Map<String, dynamic> map, String id) {
    List<String> urls = [];
    if (map['imageUrls'] != null) {
      urls = List<String>.from(map['imageUrls']);
    } else if (map['imageUrl'] != null && (map['imageUrl'] as String).isNotEmpty) {
      urls = [map['imageUrl'] as String];
    }

    List<PromotionSlide> slides = [];
    if (map['slides'] != null) {
      slides = (map['slides'] as List)
          .map((s) => PromotionSlide.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice']?.toDouble(),
      imageUrls: urls,
      slides: slides,
      category: map['category'],
      clinicId: map['clinicId'],
      clinicName: map['clinicName'],
      rating: map['rating']?.toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      isAvailable: map['isAvailable'] ?? true,
      isActive: map['isActive'] ?? true,
      createdBy: map['createdBy'],
      terms: map['terms'],
      scope: map['scope'] ?? 'profile',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrls': imageUrls,
      'slides': slides.map((s) => s.toMap()).toList(),
      'category': category,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isFeatured': isFeatured,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'createdBy': createdBy,
      'terms': terms,
      'scope': scope,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? imageUrls,
    List<PromotionSlide>? slides,
    String? category,
    String? clinicId,
    String? clinicName,
    double? rating,
    int? reviewsCount,
    bool? isFeatured,
    bool? isAvailable,
    bool? isActive,
    String? createdBy,
    String? terms,
    String? scope,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrls: imageUrls ?? this.imageUrls,
      slides: slides ?? this.slides,
      category: category ?? this.category,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isAvailable: isAvailable ?? this.isAvailable,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      terms: terms ?? this.terms,
      scope: scope ?? this.scope,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
