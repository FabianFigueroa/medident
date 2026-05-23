import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-colors.dart';
import 'package:medident/core/widgets/app_card.dart';
import 'package:medident/screens/role/dentist/profile/widgets/dentist-counter-widget.dart';
import 'package:medident/screens/widgets/avatar/global_avatar_widget.dart';

class Header_Container_Widget extends StatelessWidget {
  const Header_Container_Widget({
    super.key,
    required this.userModel,
    this.isFollowing = false,
    this.isOwnProfile = false,
    this.counterWidget,
    this.onEditProfilePressed,
    this.onFollowPressed,
    this.promotions = const [],
    this.featuredPosts = const [],
    this.showFeaturedPosts = false,
    this.onPromotionEdit,
    this.onPromotionDelete,
    this.onPromotionShare,
    this.onFeaturedPostTap,
    this.onPickVideo,
  });

  final Widget? counterWidget;
  final List<Map<String, dynamic>> featuredPosts;
  final bool isFollowing;
  final bool isOwnProfile;
  final VoidCallback? onEditProfilePressed;
  final VoidCallback? onFeaturedPostTap;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onPromotionDelete;
  final VoidCallback? onPromotionEdit;
  final VoidCallback? onPromotionShare;
  final VoidCallback? onPickVideo;
  final List<Map<String, dynamic>> promotions;
  final bool showFeaturedPosts;
  final UserModel userModel;

  String get _avatarUrl => userModel.imageUrl != null && userModel.imageUrl!.isNotEmpty
      ? userModel.imageUrl!
      : AppConstants.placeholderUserImage;

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
    return url.isNotEmpty ? url : '';
  }

  Widget _buildFeaturedPostsSection(List<Map<String, dynamic>> posts) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final post = posts[index];
          final imageUrl = post['imageUrl'] ??
              post['thumbnailUrl'] ??
              post['image'] ??
              post['url'] ??
              post['mediaUrl'] ??
              post['photoUrl'] ??
              '';
          return GestureDetector(
            onTap: onFeaturedPostTap,
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.grey200, child: const Icon(Icons.image, color: Colors.white54)),
                  errorWidget: (_, __, ___) => Container(color: AppColors.grey200, child: const Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoCard(Map<String, dynamic> promo) {
    final url = _getPromotionImageUrl(promo);
    final hasImage = url.isNotEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.tealColor.withOpacity(0.7), AppColors.primary.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              promo['title'] ?? 'Promoción',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (hasImage)
          Global_Avatar_Widget(
            imageUrl: url,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorWidget: const SizedBox.shrink(),
          ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo['title'] ?? 'Sin título',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((promo['price'] ?? 0) > 0)
                  Text(
                    '\$${(promo['price'] as num).toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPromotionDetails(BuildContext context, Map<String, dynamic> promotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_getPromotionImageUrl(promotion).isNotEmpty)
                  Global_Avatar_Widget(
                    imageUrl: _getPromotionImageUrl(promotion),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                else if (promotion['videoUrl'] != null && promotion['videoUrl'].isNotEmpty)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Global_Avatar_Widget(
                        imageUrl: promotion['thumbnailUrl'] ?? promotion['videoUrl'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      const Icon(Icons.play_circle_fill, color: Colors.white70, size: 50),
                    ],
                  )
                else
                  Container(
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.grey200, AppColors.grey300])),
                    height: 200,
                    width: double.infinity,
                    child: const Icon(Icons.image, color: Colors.grey, size: 48),
                  ),
                const SizedBox(height: 16),
                Text(
                  promotion['title'] ?? 'Promoción sin título',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  promotion['description'] ?? 'Sin descripción',
                  style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (onPromotionEdit != null)
                      ElevatedButton.icon(
                        onPressed: () { Navigator.of(ctx).pop(); onPromotionEdit!(); },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar'),
                      ),
                    if (onPromotionDelete != null)
                      ElevatedButton.icon(
                        onPressed: () { Navigator.of(ctx).pop(); onPromotionDelete!(); },
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Eliminar'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      ),
                    if (onPromotionShare != null)
                      ElevatedButton.icon(
                        onPressed: () { Navigator.of(ctx).pop(); onPromotionShare!(); },
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('Compartir'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          profession,
          maxLines: 1,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        if (specialty != null && specialty.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              specialty,
              maxLines: 1,
              style: const TextStyle(fontSize: 11, color: AppColors.primary),
            ),
          ),
        if (fullname != null && fullname.isNotEmpty)
          Text(
            "@$fullname",
            style: const TextStyle(fontSize: 11, color: AppColors.grey500),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final promotionsToShow = promotions.take(5).toList();
    final featuredPostsToShow = featuredPosts.take(3).toList();
    final hasContent = promotionsToShow.isNotEmpty || featuredPostsToShow.isNotEmpty;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.zero,
      elevation: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 370,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: hasContent && promotionsToShow.isNotEmpty
                      ? CarouselSlider(
                          options: CarouselOptions(
                            height: 250,
                            viewportFraction: 1.0,
                            autoPlay: promotionsToShow.length > 1,
                            autoPlayInterval: const Duration(seconds: 4),
                            autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          ),
                          items: promotionsToShow.map((promo) => GestureDetector(
                            onTap: () => _showPromotionDetails(context, promo),
                            child: _buildPromoCard(promo),
                          )).toList(),
                        )
                      : Container(
                          height: 250,
                          color: AppColors.grey100,
                          child: isOwnProfile
                              ? Center(
                                  child: GestureDetector(
                                    onTap: onPickVideo,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.video_library_outlined, color: AppColors.primary, size: 32),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Agregar video destacado',
                                          style: TextStyle(color: AppColors.grey600, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'Sin contenido destacado',
                                    style: TextStyle(color: AppColors.grey500, fontSize: 14),
                                  ),
                                ),
                        ),
                ),
                Positioned(
                  top: 210,
                  left: 15,
                  right: 15,
                  child: counterWidget ?? Dentist_Counter_Widget(
                    currentUser: userModel,
                    isFollowing: isFollowing,
                    onFollowPressed: onFollowPressed,
                    onEditProfilePressed: onEditProfilePressed,
                    isOwnProfile: isOwnProfile,
                  ),
                ),
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
                          borderRadius: 12,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStats(
                            username: userModel.userName ?? '',
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
          if (showFeaturedPosts && featuredPostsToShow.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _buildFeaturedPostsSection(featuredPostsToShow),
            ),
        ],
      ),
    );
  }
}
