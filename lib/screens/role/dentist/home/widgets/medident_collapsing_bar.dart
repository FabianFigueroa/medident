import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/utils/app-colors.dart';

/// Item de la cabecera colapsable. Adaptado del `TenderosCarouselItem` de
/// Tenderos, pero alimentado con `ProductModel` (promociones) de Medident.
class MedidentCarouselItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String videoUrl;
  final String badgeText;
  final String ctaLabel;
  final double? originalPrice;
  final double? discountPrice;
  final String productName;
  final String promoterName;
  final String promoterRole;
  final String promoterAvatar;
  final String promoterUid;
  final VoidCallback? onCtaPressed;

  const MedidentCarouselItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.videoUrl = '',
    this.badgeText = 'Promocion',
    this.ctaLabel = 'Ver mas',
    this.originalPrice,
    this.discountPrice,
    this.productName = '',
    this.promoterName = '',
    this.promoterRole = 'Medident',
    this.promoterAvatar = '',
    this.promoterUid = '',
    this.onCtaPressed,
  });

  factory MedidentCarouselItem.fromProduct(
    ProductModel product, {
    String promoterName = '',
    String promoterRole = 'Medident',
    String promoterAvatar = '',
    String promoterUid = '',
    VoidCallback? onCtaPressed,
  }) {
    return MedidentCarouselItem(
      id: product.id,
      title: product.name,
      subtitle: product.description.isNotEmpty
          ? product.description
          : (product.clinicName ?? 'Servicio dental'),
      imageUrl: product.imageUrl,
      videoUrl: product.videoUrl ?? '',
      badgeText: product.hasDiscount
          ? product.discountPercentage
          : (product.isFeatured ? 'Destacado' : 'Disponible hoy'),
      ctaLabel: 'Ver detalle',
      originalPrice: product.price,
      discountPrice: product.hasDiscount ? product.discountPrice : null,
      productName: product.name,
      promoterName: promoterName,
      promoterRole: promoterRole,
      promoterAvatar: promoterAvatar,
      promoterUid: promoterUid,
      onCtaPressed: onCtaPressed,
    );
  }

  String get effectiveHeroTag => 'medident_carousel_$id';

  bool get hasDiscount =>
      discountPrice != null && (originalPrice ?? 0) > discountPrice!;
}

class MedidentBrandProfile {
  final String storeOrUserName;
  final String roleOrCity;
  final String avatarUrl;
  final String uid;

  const MedidentBrandProfile({
    required this.storeOrUserName,
    this.roleOrCity = 'Medident',
    this.avatarUrl = '',
    this.uid = '',
  });
}

/// Cabecera colapsable tipo Tenderos: imagen full-bleed, carrusel de promos,
/// pastilla del publicador, precio, CTA y dots. Devuelve un `SliverAppBar`,
/// por lo que se inserta directamente en `slivers:`.
class MedidentCollapsingBar extends StatefulWidget {
  final List<MedidentCarouselItem> carouselItems;
  final MedidentBrandProfile userProfile;
  final String collapsedTitle;
  final double expandedHeight;
  final Duration autoPlayInterval;
  final bool pinned;
  final bool floating;
  final bool snap;
  final bool isLoading;
  final bool useGradientAppBar;
  final int notificationBadgeCount;
  final ScrollController? scrollController;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onScannerPressed;

  /// Si es true, el icono del lector QR se reemplaza por "crear publicación".
  final bool showCreatePost;
  final VoidCallback? onCreatePostPressed;

  final ValueChanged<MedidentCarouselItem>? onCarouselItemTapped;
  final ValueChanged<MedidentBrandProfile>? onProfileCardTapped;

  const MedidentCollapsingBar({
    super.key,
    required this.carouselItems,
    required this.userProfile,
    this.collapsedTitle = 'Medident',
    this.expandedHeight = 420.0,
    this.autoPlayInterval = const Duration(seconds: 6),
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.isLoading = false,
    this.useGradientAppBar = true,
    this.notificationBadgeCount = 0,
    this.scrollController,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.onScannerPressed,
    this.showCreatePost = false,
    this.onCreatePostPressed,
    this.onCarouselItemTapped,
    this.onProfileCardTapped,
  });

  @override
  State<MedidentCollapsingBar> createState() => _MedidentCollapsingBarState();
}

class _MedidentCollapsingBarState extends State<MedidentCollapsingBar> {
  late final PageController _pageController;
  Timer? _autoPlay;
  int _index = 0;

  int get _itemCount => widget.carouselItems.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant MedidentCollapsingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlayInterval != widget.autoPlayInterval ||
        oldWidget.carouselItems.length != widget.carouselItems.length) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlay?.cancel();
    if (_itemCount < 2) return;
    _autoPlay = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_index + 1) % _itemCount;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: widget.pinned,
      floating: widget.floating,
      snap: widget.snap,
      elevation: 0.8,
      centerTitle: true,
      expandedHeight: widget.expandedHeight,
      backgroundColor: AppColors.primaryDark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: _BarAction(
        icon: Icons.search_rounded,
        onTap: widget.onSearchPressed,
      ),
      actions: [
        if (widget.showCreatePost)
          _BarAction(
            icon: Icons.add_box_rounded,
            onTap: widget.onCreatePostPressed,
          )
        else
          _BarAction(
            icon: Icons.qr_code_scanner_rounded,
            onTap: widget.onScannerPressed,
          ),
        _BarAction(
          icon: Icons.notifications_none_rounded,
          onTap: widget.onNotificationPressed,
          badgeCount: widget.notificationBadgeCount,
        ),
        const SizedBox(width: 6),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
          final maxExtent = settings?.maxExtent ?? widget.expandedHeight;
          final minExtent = settings?.minExtent ?? kToolbarHeight;
          final currentExtent = settings?.currentExtent ?? maxExtent;
          final collapseT = maxExtent <= minExtent
              ? 0.0
              : ((maxExtent - currentExtent) / (maxExtent - minExtent)).clamp(
                  0.0,
                  1.0,
                );

          return Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(context, collapseT),
              if (widget.useGradientAppBar)
                IgnorePointer(
                  child: Opacity(
                    opacity: collapseT,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryDark.withValues(alpha: 0.95),
                            AppColors.primary.withValues(alpha: 0.90),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Titulo colapsado centrado (aparece al colapsar).
              Positioned(
                top: 0,
                height: kToolbarHeight,
                left: 64,
                right: 64,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: collapseT,
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(0, 3 * (1 - collapseT)),
                        child: Text(
                          widget.collapsedTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground(BuildContext context, double collapseT) {
    if (widget.isLoading && _itemCount == 0) {
      return Opacity(
        opacity: (1 - collapseT).clamp(0.0, 1.0),
        child: const _MedidentCollapsingSkeleton(),
      );
    }
    if (_itemCount == 0) {
      // Al colapsar, ocultamos el contenido vacio para que su texto no quede
      // fijado sobre la barra de herramientas.
      return Opacity(
        opacity: (1 - collapseT).clamp(0.0, 1.0),
        child: _EmptyHeader(name: widget.userProfile.storeOrUserName),
      );
    }
    return PageView.builder(
      controller: _pageController,
      itemCount: _itemCount,
      onPageChanged: (i) => setState(() => _index = i),
      itemBuilder: (context, i) {
        final item = widget.carouselItems[i];
        final profile =
            item.promoterUid.isNotEmpty ||
                item.promoterName.isNotEmpty ||
                item.promoterAvatar.isNotEmpty
            ? MedidentBrandProfile(
                storeOrUserName: item.promoterName.isNotEmpty
                    ? item.promoterName
                    : widget.userProfile.storeOrUserName,
                roleOrCity: item.promoterRole,
                avatarUrl: item.promoterAvatar,
                uid: item.promoterUid,
              )
            : widget.userProfile;
        return _CarouselSlide(
          item: item,
          profile: profile,
          index: i,
          count: _itemCount,
          onItemTap: widget.onCarouselItemTapped,
          onProfileTap: widget.onProfileCardTapped,
        );
      },
    );
  }
}

class _CarouselSlide extends StatelessWidget {
  final MedidentCarouselItem item;
  final MedidentBrandProfile profile;
  final int index;
  final int count;
  final ValueChanged<MedidentCarouselItem>? onItemTap;
  final ValueChanged<MedidentBrandProfile>? onProfileTap;

  const _CarouselSlide({
    required this.item,
    required this.profile,
    required this.index,
    required this.count,
    this.onItemTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onItemTap?.call(item),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const ColoredBox(color: AppColors.primaryDark),
              errorWidget: (_, __, ___) =>
                  const ColoredBox(color: AppColors.primaryDark),
            )
          else
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.blueGradientColor),
            ),
          if (item.videoUrl.isNotEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          // Degradado superior (para toolbar/pastilla).
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0xCC003B52), Color(0x00003B52)],
              ),
            ),
          ),
          // Degradado inferior (para textos/CTA).
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Color(0x00003B52), Color(0xE6002C3D)],
              ),
            ),
          ),
          // Pastilla del publicador.
          Positioned(
            top: kToolbarHeight + 8,
            left: 14,
            right: 80,
            child: _PromoterPill(
              profile: profile,
              onTap: () => onProfileTap?.call(profile),
            ),
          ),
          // Dots verticales.
          Positioned(
            right: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(count > 6 ? 6 : count, (i) {
                  final active = i == (index % (count > 6 ? 6 : count));
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    width: 3,
                    height: active ? 22 : 10,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Contenido inferior.
          Positioned(
            left: 16,
            right: 24,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Badge(text: item.badgeText),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item.discountPrice != null) ...[
                      _Price(
                        value: item.discountPrice!,
                        color: Colors.white,
                        fontSize: 28,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (item.originalPrice != null &&
                        (!item.hasDiscount || item.discountPrice != null))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _Price(
                          value: item.originalPrice!,
                          color: Colors.white70,
                          fontSize: 12,
                          strike: item.hasDiscount,
                        ),
                      ),
                    const Spacer(),
                    _CtaButton(label: item.ctaLabel, onTap: item.onCtaPressed),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoterPill extends StatelessWidget {
  final MedidentBrandProfile profile;
  final VoidCallback onTap;

  const _PromoterPill({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 5, 8, 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SizedBox(
                width: 32,
                height: 32,
                child: profile.avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: profile.avatarUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const _AvatarFallback(),
                      )
                    : const _AvatarFallback(),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile.storeOrUserName.isNotEmpty
                        ? profile.storeOrUserName
                        : 'Medident',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    profile.roleOrCity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_rounded, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Price extends StatelessWidget {
  final double value;
  final Color color;
  final double fontSize;
  final bool strike;

  const _Price({
    required this.value,
    required this.color,
    required this.fontSize,
    this.strike = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(
      locale: 'es',
      symbol: '\$',
      decimalDigits: 0,
    ).format(value);
    return Text(
      formatted,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        decoration: strike ? TextDecoration.lineThrough : null,
        decorationColor: color,
        height: 1,
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _CtaButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryDark,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int badgeCount;

  const _BarAction({required this.icon, this.onTap, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          if (badgeCount > 0)
            Positioned(
              right: -4,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.white24,
      child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
    );
  }
}

class _EmptyHeader extends StatelessWidget {
  final String name;
  const _EmptyHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.blueGradientColor),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_hospital_outlined,
                color: Colors.white,
                size: 54,
              ),
              const SizedBox(height: 10),
              Text(
                name.isNotEmpty ? name : 'Medident',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Aun no hay promociones disponibles',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedidentCollapsingSkeleton extends StatelessWidget {
  const _MedidentCollapsingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
      ),
    );
  }
}
