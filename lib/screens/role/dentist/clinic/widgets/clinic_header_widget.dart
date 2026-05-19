import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/models/treatment-model.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-counter-widget.dart';
import 'package:medident/screens/widgets/avatar/global_avatar_widget.dart';
import 'package:medident/screens/shared/promotion-detail-screen.dart';
import 'package:medident/screens/role/dentist/clinic/treatments-screen.dart';

class Clinic_Header_Widget extends StatelessWidget {
  final UserModel userModel;
  final bool isOwner;
  final VoidCallback? onEditProfilePressed;
  final List<Map<String, dynamic>> promotions;
  final List<TreatmentModel> treatments;
  final String clinicId;

  const Clinic_Header_Widget({
    super.key,
    required this.userModel,
    this.isOwner = false,
    this.onEditProfilePressed,
    required this.promotions,
    this.treatments = const [],
    this.clinicId = '',
  });

  String get _avatarUrl => userModel.imageUrl != null && userModel.imageUrl!.isNotEmpty 
      ? userModel.imageUrl!   
      : '';

  String _getPromotionImageUrl(Map<String, dynamic> promo) {
    final imageUrls = promo['imageUrls'] as List<dynamic>?;
    if (imageUrls != null && imageUrls.isNotEmpty && imageUrls.first.toString().isNotEmpty) {
      return imageUrls.first.toString();
    }
    final url = promo['imageUrl'] ?? 
                 promo['thumbnailUrl'] ?? 
                 promo['image'] ?? 
                 promo['url'] ?? 
                 promo['mediaUrl'] ?? 
                 promo['photoUrl'] ??
                 '';
    return url ?? '';
  }

  Widget _buildPromoCard(Map<String, dynamic> promo, double cardWidth) {
    final url = _getPromotionImageUrl(promo);
    final hasImage = url.isNotEmpty;
    final subtitle = promo['subtitle'] as String?;
    final ctaText = promo['ctaText'] as String?;
    final overlayPos = promo['overlayPosition'] as String? ?? 'bottom';
    final price = (promo['price'] as num?) ?? 0;
    final discountPrice = promo['discountPrice'] as num?;

    double overlayBottom;
    CrossAxisAlignment alignment;
    switch (overlayPos) {
      case 'top':
        overlayBottom = 130; alignment = CrossAxisAlignment.start; break;
      case 'center':
        overlayBottom = 80; alignment = CrossAxisAlignment.center; break;
      case 'bottom-left':
        overlayBottom = 0; alignment = CrossAxisAlignment.start; break;
      default:
        overlayBottom = 0; alignment = CrossAxisAlignment.start;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: CachedNetworkImage(
              imageUrl: url,
              width: cardWidth,
              height: 250,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[200]),
              errorWidget: (_, __, ___) => _buildGradientFallback(promo['title'] ?? 'Promoción'),
            ),
          )
        else
          _buildGradientFallback(promo['title'] ?? 'Promoción'),
        Positioned(
          bottom: overlayBottom, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                Text(
                  promo['title'] ?? 'Sin título',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(subtitle,
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (price > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (discountPrice != null && discountPrice > 0) ...[
                          Text('\$${price.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, decoration: TextDecoration.lineThrough)),
                          const SizedBox(width: 6),
                        ],
                        Text('\$${(discountPrice ?? price).toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                if (ctaText != null && ctaText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(ctaText,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientFallback(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF9333EA).withOpacity(0.7), const Color(0xFF7C3AED).withOpacity(0.9)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showPromotionDetails(BuildContext context, Map<String, dynamic> promotion) {
    final promoId = promotion['id'] as String?;
    if (promoId == null || promoId.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PromotionDetailScreen(
        promoId: promoId,
        clinicId: clinicId,
        clinicName: userModel.userName,
        isOwner: isOwner,
      ),
    ));
  }

  Widget _buildStats({
    required String username,
    required String profession,
    String? specialty,
    String? fullname,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          username, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: 'Ubuntu-Bold', fontSize: 16, color: Color(0xFF0F172A)),
          softWrap: true,
        ),
        Text(
          profession, maxLines: 1,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Ubuntu-Regular'),
        ),
        if (specialty != null && specialty.isNotEmpty)
          Text(
            specialty, maxLines: 1,
            style: const TextStyle(fontSize: 11, color: Colors.blueAccent, fontFamily: 'Ubuntu-Medium'),
          ),
        if (fullname != null && fullname.isNotEmpty)
          Text(
            "@$fullname",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildFeaturedTreatments(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tratamientos destacados',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              TextButton(
                onPressed: () => _navigateToTreatments(context),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 24), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Ver todo', style: TextStyle(fontSize: 11, color: Color(0xFF0EA5A4))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: treatments.length > 6 ? 6 : treatments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final t = treatments[i];
                return GestureDetector(
                  onTap: () => _navigateToTreatments(context),
                  child: Container(
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        if (t.price > 0)
                          Text('\$${t.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0EA5A4))),
                        Text('${t.durationMinutes} min',
                            style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTreatments(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => TreatmentsScreen(clinicId: clinicId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> promotionsToShow = promotions.take(5).toList();
    final cardWidth = MediaQuery.of(context).size.width - 16;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal:8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x1A0F172A), blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 370,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: promotionsToShow.isEmpty
                      ? Container(
                          height: 250,
                          color: const Color.fromARGB(255, 255, 183, 183),
                          child: const Center(
                            child: Text('No hay promociones', style: TextStyle(color: Color.fromARGB(255, 97, 91, 91), fontSize: 16)),
                          ),
                        )
                      : CarouselSlider(
                          options: CarouselOptions(
                            height: 250,
                            viewportFraction: 1.0,
                            autoPlay: promotionsToShow.length > 1,
                            autoPlayInterval: const Duration(seconds: 4),
                          ),
                          items: promotionsToShow.map((promo) => GestureDetector(
                            onTap: () => _showPromotionDetails(context, promo),
                            child: _buildPromoCard(promo, cardWidth),
                          )).toList(),
                        ),
                ),
                Positioned(
                  top: 210,
                  left: 15,
                  right: 15,
                  child: Dentist_Counter_Widget(
                    currentUser: userModel,
                    isFollowing: false,
                    onFollowPressed: null,
                    onEditProfilePressed: onEditProfilePressed,
                    isOwnProfile: isOwner,
                  ),
                ),
                const SizedBox(height: 8),
                Positioned(
                  top: 295,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Global_Avatar_Widget(
                          imageUrl: _avatarUrl,
                          width: 50,
                          height: 50,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStats(
                            username: "${userModel.userName}",
                            profession: userModel.speciality ?? userModel.role.displayName,
                            specialty: 'www.doctormontiel.com',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (treatments.isNotEmpty)
            _buildFeaturedTreatments(context),
        ],
      ),
    );
  }
}
