import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/widgets/avatar/global_avatar_widget.dart';

class Promotions_Carousel_Widget extends StatefulWidget {
  final List<ProductModel> products;
  // ✅ Callback para navegación — la pantalla decide a dónde ir
  final void Function(ProductModel product)? onProductTap;
  // ✅ Callbacks para editar y eliminar promociones
  final void Function(ProductModel product)? onEdit;
  final void Function(ProductModel product)? onDelete;
  // ✅ UID del usuario actual para mostrar opciones solo a dueños
  final String? currentUserId;

  const Promotions_Carousel_Widget({
    super.key,
    required this.products,
    this.onProductTap,
    this.onEdit,
    this.onDelete,
    this.currentUserId,

  });

  @override
  State<Promotions_Carousel_Widget> createState() => _Promotions_Carousel_WidgetState();
}

class _Promotions_Carousel_WidgetState extends State<Promotions_Carousel_Widget> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 500; // alto para ilusión de infinito

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.92, // muestra borde del siguiente card
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.products.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _currentPage++;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  int get _activeIndex => _currentPage % widget.products.length;

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No hay promociones activas.')),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) {
              if (mounted) setState(() => _currentPage = i);
            },
            itemBuilder: (context, index) {
              final item = widget.products[index % widget.products.length];
              final isOwner = widget.currentUserId != null &&
                  item.createdBy == widget.currentUserId;
              return _PromoCard(
                product: item,
                onTap: () => widget.onProductTap?.call(item),
                onEdit: isOwner && widget.onEdit != null
                    ? () => widget.onEdit?.call(item)
                    : null,
                onDelete: isOwner && widget.onDelete != null
                    ? () => widget.onDelete?.call(item)
                    : null,
                isOwner: isOwner,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // ✅ Dots indicadores
        if (widget.products.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.products.length, (i) {
              final active = _activeIndex == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: active ? 22 : 6,
                decoration: BoxDecoration(
                  color: active
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
      ],
    );
  }
}

// ✅ Card separado para mantener el widget principal limpio
class _PromoCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isOwner;

  const _PromoCard({
    required this.product,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.isOwner = false,
  });

  @override
  State<_PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<_PromoCard> {
  late final PageController _imageController;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.product;
    final cacheKey = item.updatedAt?.millisecondsSinceEpoch ?? item.createdAt.millisecondsSinceEpoch;
    final images = item.imageUrls.map((url) => '$url?v=$cacheKey').toList();

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ─── Imágenes (carrusel interno por swipe) ───────────
            images.isEmpty
                ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF9333EA).withOpacity(0.5), const Color(0xFF7C3AED).withOpacity(0.7)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                  )
                : PageView.builder(
                    controller: _imageController,
                    onPageChanged: (i) => setState(() => _imageIndex = i),
                    itemCount: images.length,
                    itemBuilder: (_, i) => Global_Avatar_Widget(
                      imageUrl: images[i],
                      fit: BoxFit.cover,
                      errorWidget: const SizedBox.shrink(),
                    ),
                  ),

            // ─── Gradiente para legibilidad del texto ───────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // ─── Info inferior ───────────────────────────────────
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Clínica
                  if (item.clinicName != null)
                    Text(
                      item.clinicName!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  // Nombre
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 3, color: Colors.black54)],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Precios + popularidad
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.hasDiscount)
                            Text(
                              '\$${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            item.hasDiscount
                                ? '\$${item.discountPrice!.toStringAsFixed(0)}'
                                : '\$${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // ✅ Rating + popularidad
                          if (item.rating != null)
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  '${item.rating!.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                                if (item.popularityLabel.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    item.popularityLabel,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 11),
                                  ),
                                ]
                              ],
                            ),
                        ],
                      ),
                      // Botón ver más
                      ElevatedButton(
                        onPressed: widget.onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          elevation: 0,
                        ),
                        child: const Text('Ver más',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Badge descuento ─────────────────────────────────
            if (item.hasDiscount)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    item.discountPercentage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

            // ─── Botones editar/eliminar (solo dueño) ────────────
            if (widget.isOwner)
              Positioned(
                top: 8,
                left: 8,
                child: Row(
                  children: [
                    if (widget.onEdit != null)
                      GestureDetector(
                        onTap: widget.onEdit,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    if (widget.onEdit != null && widget.onDelete != null)
                      const SizedBox(width: 6),
                    if (widget.onDelete != null)
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Eliminar promoción'),
                              content: const Text(
                                  '¿Estás seguro de eliminar esta promoción?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Eliminar',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) widget.onDelete?.call();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete,
                              color: Colors.white, size: 16),
                        ),
                      ),
                  ],
                ),
              ),

            // ─── Dots internos de imágenes ───────────────────────
            if (images.length > 1)
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    final active = _imageIndex == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      width: active ? 16 : 4,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
