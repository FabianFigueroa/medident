import 'package:medident/core/models/user-model.dart';

class PromotionModel {
  final UserModel? userId;
  final String productId;
  final String title;
  final String imageUrl;
  final double originalPrice;
  final double discountPrice;

  PromotionModel({
    this.userId,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.originalPrice,
    required this.discountPrice,
  });

  bool get hasDiscount => discountPrice < originalPrice;

  String get discountPercentage {
    if (!hasDiscount) return '';
    final percentage = ((originalPrice - discountPrice) / originalPrice * 100).toStringAsFixed(0);
    return '$percentage% OFF';
  }


}

final promotionModelItems = [
  PromotionModel(
    productId: 'prod_001',
    title: 'Café premium 25% OFF',
    imageUrl: 'https://images.pexels.com/photos/5872364/pexels-photo-5872364.jpeg?_gl=1*1892ikz*_ga*MTAxOTY4Mjc0OC4xNzYxMDgwMjc4*_ga_8JE65Q40S6*czE3NjQ3Njk5MDgkbzQ3JGcxJHQxNzY0NzY5OTQzJGoyNSRsMCRoMA',
    originalPrice: 20.000,
    discountPrice: 15.000,
  ),
  PromotionModel(
    productId: 'prod_002',
    title: 'Black Friday 30% en todo!',
    imageUrl: 'https://images.pexels.com/photos/5625013/pexels-photo-5625013.jpeg?_gl=1*1anoae4*_ga*MTAxOTY4Mjc0OC4xNzYxMDgwMjc4*_ga_8JE65Q40S6*czE3NjQ3Njk5MDgkbzQ3JGcxJHQxNzY0NzY5OTg5JGo0OSRsMCRoMA',
    originalPrice: 55.000,
    discountPrice: 48.000, // Sin descuento
  ),
  PromotionModel(
    productId: 'prod_003',
    title: 'Frutas y Verduras',
    imageUrl: 'https://media.istockphoto.com/id/2214969124/photo/minimal-sale-concept-with-percentage-symbol-shopping-bags-and-fashion-accessories-on-white.jpg?s=1024x1024&w=is&k=20&c=FE5AfLODoeNiFSDz2VDPiM2A84dNi7By42pUNesIswk=',
    originalPrice: 25.000,
    discountPrice: 22.500,
  ),
  PromotionModel(
    productId: 'prod_004',
    title: 'Decoración Navideña',
    imageUrl: 'https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg',
    originalPrice: 20.000,
    discountPrice: 3.000,
  ),
];
