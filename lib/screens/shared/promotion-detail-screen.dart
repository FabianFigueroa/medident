import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/promotion-slide-model.dart';

class PromotionDetailScreen extends StatelessWidget {
  final String promoId;
  final String clinicId;
  final String? clinicName;
  final bool isOwner;

  const PromotionDetailScreen({
    super.key,
    required this.promoId,
    this.clinicId = '',
    this.clinicName,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Promoción',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        actions: isOwner ? [
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_horiz, color: Colors.black87, size: 20),
            ),
            onSelected: (v) async {
              if (v == 'toggle') {
                final doc = await FirebaseFirestore.instance.collection('promotions').doc(promoId).get();
                final current = doc.data()?['isAvailable'] ?? true;
                await FirebaseFirestore.instance.collection('promotions').doc(promoId).update({
                  'isAvailable': !current,
                });
              } else if (v == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Eliminar promoción'),
                    content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Eliminar')),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await FirebaseFirestore.instance.collection('promotions').doc(promoId).delete();
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'toggle', child: Row(children: [Icon(Icons.visibility, size: 18), SizedBox(width: 8), Text('Activar / Desactivar')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ] : [],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('promotions').doc(promoId).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (!snap.data!.exists) {
            return const Center(child: Text('Promoción no encontrada'));
          }
          final data = snap.data!.data() as Map<String, dynamic>;
          return _PromotionBody(data: data, clinicName: clinicName);
        },
      ),
    );
  }
}

class _PromotionBody extends StatelessWidget {
  final Map<String, dynamic> data;
  final String? clinicName;
  const _PromotionBody({required this.data, this.clinicName});

  @override
  Widget build(BuildContext context) {
    final imageUrls = (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    final slidesData = data['slides'] as List<dynamic>?;
    final name = data['name'] as String? ?? data['title'] as String? ?? 'Promoción';
    final description = data['description'] as String? ?? '';
    final price = (data['price'] as num?) ?? 0;
    final discountPrice = data['discountPrice'] as num?;
    final category = data['category'] as String?;
    final terms = data['terms'] as String?;
    final expiresAt = data['expiresAt'] as Timestamp?;
    final rating = (data['rating'] as num?) ?? 0;
    final reviewsCount = data['reviewsCount'] as int? ?? 0;

    final slides = slidesData != null
        ? slidesData.map((s) => PromotionSlide.fromJson(s as Map<String, dynamic>)).toList()
        : <PromotionSlide>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slides.isNotEmpty)
            _SlidesGallery(slides: slides)
          else if (imageUrls.isNotEmpty)
            _ImageGallery(imageUrls: imageUrls, category: category),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category != null && category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9333EA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(category.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9333EA), letterSpacing: 0.5)),
                  ),
                const SizedBox(height: 12),
                Text(name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.2)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: discountPrice != null ? Colors.grey[400] : const Color(0xFF9333EA),
                        decoration: discountPrice != null ? TextDecoration.lineThrough : null,
                      )),
                    if (discountPrice != null) ...[
                      const SizedBox(width: 12),
                      Text('\$${discountPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF9333EA))),
                      Container(
                        margin: const EdgeInsets.only(left: 8, bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${((1 - discountPrice / price) * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                if (rating > 0)
                  Row(children: [
                    ...List.generate(5, (i) => Icon(
                      i < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 18, color: const Color(0xFFF59E0B),
                    )),
                    const SizedBox(width: 6),
                    Text('$rating ($reviewsCount reseñas)',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ]),
                if (rating > 0) const SizedBox(height: 20),
                if (description.isNotEmpty) ...[
                  const Text('Descripción',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Text(description,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6)),
                  const SizedBox(height: 20),
                ],
                if (terms != null && terms.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.15)),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.orange[600]),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Términos y condiciones',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                        const SizedBox(height: 4),
                        Text(terms,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4)),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],
                if (expiresAt != null) ...[
                  Row(children: [
                    Icon(Icons.event, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Text('Válido hasta: ${expiresAt.toDate().day}/${expiresAt.toDate().month}/${expiresAt.toDate().year}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ]),
                  const SizedBox(height: 20),
                ],
                if (clinicName != null)
                  Row(children: [
                    Icon(Icons.store, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Text('Ofrecido por $clinicName',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF9333EA).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9333EA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Solicitar servicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidesGallery extends StatelessWidget {
  final List<PromotionSlide> slides;
  const _SlidesGallery({required this.slides});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      width: double.infinity,
      child: PageView.builder(
        itemCount: slides.length,
        itemBuilder: (_, i) {
          final s = slides[i];
          return Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: s.imageUrl, fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.75), Colors.transparent],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (s.title != null)
                        Text(s.title!, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      if (s.subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(s.subtitle!, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                        ),
                      if (s.discountPrice != null || s.price != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (s.price != null && s.discountPrice != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text('\$${s.price!.toStringAsFixed(0)}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, decoration: TextDecoration.lineThrough)),
                                ),
                              Text('\$${(s.discountPrice ?? s.price ?? 0).toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      if (s.ctaText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(s.ctaText!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${i + 1}/${slides.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final String? category;
  const _ImageGallery({required this.imageUrls, this.category});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        children: [
          if (imageUrls.length > 1)
            PageView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: imageUrls[i], fit: BoxFit.cover, width: double.infinity,
                errorWidget: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
              ),
            )
          else
            CachedNetworkImage(
              imageUrl: imageUrls.first, fit: BoxFit.cover, width: double.infinity,
              errorWidget: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
            ),
          Positioned(
            top: 16, left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF9333EA).withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.card_giftcard, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                const Text('PROMO', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
          if (imageUrls.length > 1)
            Positioned(
              bottom: 16, right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('1/${imageUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}
