import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/providers/dentist/dentist-main-provider.dart';
import 'package:medident/core/providers/dentist/dentist-profile-provider.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-counter-widget.dart';
import 'package:medident/screens/widgets/avatar/circle_avatar_widget.dart';

class DentistProfileHeaderWidget extends StatelessWidget {
  const DentistProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final profileP = context.watch<DentistProfileProvider>();
    final userProfile = profileP.userProfile;
    if (userProfile == null) return const SizedBox.shrink();

    final mainP = context.read<DentistMainProvider>();
    final homeP = mainP.homeProvider;
    final promotionImages = _getPromoImageUrls(homeP?.myPromotions);

    return _ProfileHeaderLayout(
      userModel: userProfile,
      promotionImages: promotionImages,
    );
  }

  List<String> _getPromoImageUrls(List<ProductModel>? promos) {
    if (promos == null) return [];
    return promos
        .where((p) => p.imageUrls.isNotEmpty)
        .expand((p) => p.imageUrls)
        .toList();
  }
}

class _ProfileHeaderLayout extends StatelessWidget {
  final UserModel userModel;
  final List<String> promotionImages;

  const _ProfileHeaderLayout({
    required this.userModel,
    required this.promotionImages,
  });

  List<String> get _bannerPhotos {
    if (promotionImages.isNotEmpty) return promotionImages;

    List<String> validPhotos = [];
    if (userModel.imageUrl != null) {
      validPhotos = userModel.imageUrl!
          .split(',')
          .where((p) => p.trim().isNotEmpty)
          .toList();
    }
    if (validPhotos.isEmpty) {
      return [AppConstants.placeholderUserImage];
    }
    return validPhotos;
  }

  String get _avatarUrl => userModel.imageUrl != null &&
          userModel.imageUrl!.isNotEmpty
      ? userModel.imageUrl!
      : AppConstants.placeholderUserImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 15,
              offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 250,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                ),
                items: _bannerPhotos.map((url) => _buildImage(url)).toList(),
              ),
            ),
          ),
          Positioned(
            top: 210,
            left: 15,
            right: 15,
            child: Dentist_Counter_Widget(currentUser: userModel),
          ),
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar_Widget(
                  imageUrl: _avatarUrl,
                  radius: 35,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStats(
                    username: userModel.userName ?? '',
                    profession: userModel.speciality ??
                        userModel.role.displayName,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (_, __) => Container(color: Colors.grey[200]),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }

  Widget _buildStats({
    required String username,
    required String profession,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Ubuntu-Bold',
            fontSize: 17,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          profession,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontFamily: 'Ubuntu-Regular',
          ),
        ),
      ],
    );
  }
}
