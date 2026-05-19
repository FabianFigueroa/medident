class PromotionSlide {
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final double? price;
  final double? discountPrice;
  final String? ctaText;
  final String overlayPosition;
  final int sortOrder;

  const PromotionSlide({
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.price,
    this.discountPrice,
    this.ctaText,
    this.overlayPosition = 'bottom',
    this.sortOrder = 0,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < (price ?? 0);

  factory PromotionSlide.fromJson(Map<String, dynamic> map) {
    return PromotionSlide(
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'],
      subtitle: map['subtitle'],
      price: map['price']?.toDouble(),
      discountPrice: map['discountPrice']?.toDouble(),
      ctaText: map['ctaText'],
      overlayPosition: map['overlayPosition'] ?? 'bottom',
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'discountPrice': discountPrice,
      'ctaText': ctaText,
      'overlayPosition': overlayPosition,
      'sortOrder': sortOrder,
    };
  }

  PromotionSlide copyWith({
    String? imageUrl,
    String? title,
    String? subtitle,
    double? price,
    double? discountPrice,
    String? ctaText,
    String? overlayPosition,
    int? sortOrder,
  }) {
    return PromotionSlide(
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      ctaText: ctaText ?? this.ctaText,
      overlayPosition: overlayPosition ?? this.overlayPosition,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
