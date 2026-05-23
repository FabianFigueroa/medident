import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-colors.dart';
import 'package:medident/core/widgets/app_card.dart';

class DentistGalleryWidget extends StatefulWidget {
  final List<Map<String, dynamic>>? images;
  final Function(int)? onImageTap;
  final bool isOwnProfile;
  final VoidCallback? onAddImage;
  final VoidCallback? onPickVideo;

  const DentistGalleryWidget({
    super.key,
    required this.images,
    this.onImageTap,
    this.isOwnProfile = false,
    this.onAddImage,
    this.onPickVideo,
  });

  @override
  State<DentistGalleryWidget> createState() => _DentistGalleryWidgetState();
}

class _DentistGalleryWidgetState extends State<DentistGalleryWidget> {
  bool _showCarousel = false;

  String _getImageUrl(Map<String, dynamic> image) {
    return image['imageUrl'] ??
        image['thumbnailUrl'] ??
        image['image'] ??
        image['url'] ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images ?? [];
    final hasImages = images.isNotEmpty;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Galería',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasImages)
                    GestureDetector(
                      onTap: () => setState(() => _showCarousel = !_showCarousel),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showCarousel ? Icons.grid_view : Icons.view_carousel,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _showCarousel ? 'Cuadrícula' : 'Carrusel',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (widget.isOwnProfile)
                    GestureDetector(
                      onTap: widget.onPickVideo,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.video_library_outlined, color: AppColors.success, size: 20),
                      ),
                    ),
                  if (widget.isOwnProfile)
                    GestureDetector(
                      onTap: widget.onAddImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_photo_alternate, color: AppColors.primary, size: 20),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasImages)
            widget.isOwnProfile
                ? Center(
                    child: GestureDetector(
                      onTap: widget.onPickVideo,
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.video_library_outlined, color: AppColors.grey400, size: 36),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Agregar video o imagen',
                            style: TextStyle(color: AppColors.grey500, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text('No hay contenido en la galería', style: TextStyle(color: AppColors.grey500, fontSize: 14)),
                    ),
                  )
          else if (_showCarousel)
            CarouselSlider(
              options: CarouselOptions(
                height: 220,
                viewportFraction: 0.85,
                autoPlay: images.length > 1,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                enlargeCenterPage: true,
              ),
              items: images.map((image) {
                final url = _getImageUrl(image);
                return GestureDetector(
                  onTap: () => widget.onImageTap?.call(images.indexOf(image)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(color: AppColors.grey200, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                      errorWidget: (_, __, ___) => Container(color: AppColors.grey200, child: const Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: images.length > 6 ? 6 : images.length,
              itemBuilder: (context, index) {
                final url = _getImageUrl(images[index]);
                return GestureDetector(
                  onTap: () => widget.onImageTap?.call(index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.grey200, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                      errorWidget: (_, __, ___) => Container(color: AppColors.grey200, child: const Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                );
              },
            ),
          if (images.length > 6 && !_showCarousel)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${images.length - 6} más',
                style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }
}
