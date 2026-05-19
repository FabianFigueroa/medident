import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medident/core/utils/app-constant.dart';

class DentistGalleryWidget extends StatelessWidget {
  final List<Map<String, dynamic>>? images;
  final Function(int)? onImageTap;
  final bool isOwnProfile;
  final VoidCallback? onAddImage;

  const DentistGalleryWidget({
    super.key,
    required this.images,
    this.onImageTap,
    this.isOwnProfile = false,
    this.onAddImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x1A0F172A), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Galería',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (isOwnProfile)
                  GestureDetector(
                    onTap: onAddImage,
                    child: const Icon(Icons.add_photo_alternate, color: Colors.blue, size: 24),
                  ),
              ],
            ),
          ),
          if ((images ?? []).isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No hay imágenes en la galería',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: (images ?? []).length > 6 ? 6 : (images ?? []).length,
                itemBuilder: (context, index) {
                  final image = (images ?? [])[index];
                  final url = image['imageUrl'] ?? 
                              image['thumbnailUrl'] ?? 
                              image['image'] ?? 
                              image['url'] ?? 
                              AppConstants.placeholderUserImage;
                  return GestureDetector(
                    onTap: onImageTap != null ? () => onImageTap!(index) : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if ((images ?? []).length > 6)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                '+${(images ?? []).length - 6} más',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}