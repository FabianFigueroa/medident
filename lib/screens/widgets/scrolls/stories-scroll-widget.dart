import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medident/core/models/story-model.dart';
import 'package:medident/screens/widgets/avatar/global_avatar_widget.dart';

class StoriesScroll_Widget extends StatefulWidget {
  final List<StoryModel> stories;
  final String currentUserName;
  final String currentUserPhoto;
  final List<StoryModel> currentUserStories;
  final Function(StoryModel)? onStoryTap;
  final VoidCallback? onAddStoryTap;
  final void Function(String userId)? onAvatarTap;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isLoading;

  const StoriesScroll_Widget({
    super.key,
    required this.stories,
    required this.currentUserName,
    this.currentUserPhoto = '',
    this.currentUserStories = const [],
    this.onStoryTap,
    this.onAddStoryTap,
    this.onAvatarTap,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isLoading = false,
  });

  @override
  State<StoriesScroll_Widget> createState() => _StoriesScroll_WidgetState();
}

class _StoriesScroll_WidgetState extends State<StoriesScroll_Widget> {
  final ScrollController _scrollController = ScrollController();
  static const int _initialBatch = 8;
  static const int _scrollBatch = 4;
  int _visibleCount = _initialBatch;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _visibleCount = min(widget.stories.length, _initialBatch);
    if (widget.currentUserStories.isNotEmpty) {
      _visibleCount = max(_visibleCount, widget.currentUserStories.length + 1);
    }
  }

  @override
  void didUpdateWidget(StoriesScroll_Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stories != widget.stories &&
        _visibleCount < _initialBatch &&
        widget.stories.length > oldWidget.stories.length) {
      _visibleCount = min(widget.stories.length, _initialBatch);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool get hasMyStories => widget.currentUserStories.isNotEmpty;

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasMore && !widget.isLoadingMore && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
      if (_visibleCount < widget.stories.length + 1 + (hasMyStories ? widget.currentUserStories.length : 0)) {
        setState(() => _visibleCount += _scrollBatch);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStories = widget.stories.isNotEmpty;
    final bool hasMyStories = widget.currentUserStories.isNotEmpty;

    return Container(
      height: 195,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.isLoading
            ? 4
            : min(
                1 +
                    (hasMyStories ? widget.currentUserStories.length : 0) +
                    (hasStories ? widget.stories.length : 0) +
                    (widget.hasMore && !widget.isLoadingMore ? 1 : 0),
                _visibleCount,
              ),
        itemBuilder: (context, index) {
          if (widget.isLoading) {
            return _shimmerPlaceholder();
          }
          if (index == 0) return _buildMyStoryCard();
          if (hasMyStories && index <= widget.currentUserStories.length) {
            return _buildStoryCard(
              widget.currentUserStories[index - 1],
              isOwn: true,
            );
          }
          final storiesStart = 1 + (hasMyStories ? widget.currentUserStories.length : 0);
          if (index >= storiesStart &&
              index < storiesStart + widget.stories.length) {
            return _buildStoryCard(
              widget.stories[index - storiesStart],
            );
          }
          return _loadingIndicator();
        },
      ),
    );
  }

  Widget _shimmerPlaceholder() {
    return Container(
      width: 110,
      height: 185,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _loadingIndicator() {
    if (!widget.isLoadingMore) return const SizedBox(width: 0);
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  // ── TARJETA "MI HISTORIA" (2 estados) ────────────────
  Widget _buildMyStoryCard() {
    final hasMyStories = widget.currentUserStories.isNotEmpty;
    final int totalStories = widget.currentUserStories.length;
    final int viewedCount =
        widget.currentUserStories.where((s) => s.viewedBy.isNotEmpty).length;

    // bg: última story, o foto perfil, o null
    String? bgImage;
    if (hasMyStories) {
      bgImage = widget.currentUserStories.last.imageUrl;
    } else if (widget.currentUserPhoto.isNotEmpty) {
      bgImage = widget.currentUserPhoto;
    }

    return GestureDetector(
      onTap: () {
        if (hasMyStories) {
          widget.onStoryTap?.call(widget.currentUserStories.last);
        } else {
          widget.onAddStoryTap?.call();
        }
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fondo
              if (bgImage != null)
                Global_Avatar_Widget(imageUrl: bgImage, fit: BoxFit.cover, errorWidget: _gradientFallback(isOwn: true))
              else
                _gradientFallback(isOwn: true),
              // Onda blanca abajo
              _bottomWave(),
              // Avatar + anillo
              Positioned(
                bottom: 28,
                left: 0,
                right: 0,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Anillo segmentado (solo si tiene stories)
                      if (hasMyStories)
                        CustomPaint(
                          size: const Size(54, 54),
                          painter: SegmentedRingPainter(
                            totalSegments: totalStories,
                            viewedSegments: viewedCount,
                            activeColor: const Color(0xFF1877F2),
                            viewedColor: Colors.grey.shade400,
                          ),
                        ),
                      // Foto de perfil
                      Container(
                        width: hasMyStories ? 40 : 44,
                        height: hasMyStories ? 40 : 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: hasMyStories
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: Global_Avatar_Widget(imageUrl: widget.currentUserPhoto, borderRadius: 40,
                              errorWidget: const Icon(Icons.person, color: Colors.grey, size: 20)),
                        ),
                      ),
                      // Botón "+"
                      Positioned(
                        right: hasMyStories ? 0 : 2,
                        bottom: hasMyStories ? 0 : 2,
                        child: GestureDetector(
                          onTap: widget.onAddStoryTap,
                          child: Container(
                            width: hasMyStories ? 18 : 24,
                            height: hasMyStories ? 18 : 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1877F2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: hasMyStories ? 10 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Texto
              Positioned(
                bottom: 8,
                left: 4,
                right: 4,
                child: Text(
                  hasMyStories ? 'Mi historia' : 'Agregar historia',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TARJETA DE STORY (otros usuarios) ────────────────
  Widget _buildStoryCard(StoryModel story, {bool isOwn = false}) {
    final bool isViewed = story.isViewed || story.viewedBy.isNotEmpty;
    final String? photoUrl = isOwn
        ? widget.currentUserPhoto
        : (story.userPhoto ?? widget.currentUserPhoto);
    final String name = isOwn
        ? widget.currentUserName
        : (story.userName.isNotEmpty ? story.userName : 'Usuario');

    return GestureDetector(
      onTap: () {
        widget.onStoryTap?.call(story);
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fondo
              if (story.imageUrl.isNotEmpty)
                Global_Avatar_Widget(imageUrl: story.imageUrl, fit: BoxFit.cover, errorWidget: _gradientFallback(isOwn: isOwn))
              else
                _gradientFallback(isOwn: isOwn),
              _bottomWave(),
              // Avatar + anillo
              Positioned(
                bottom: 28,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => widget.onAvatarTap?.call(story.userId),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(54, 54),
                          painter: SegmentedRingPainter(
                            totalSegments: 1,
                            viewedSegments: isViewed ? 1 : 0,
                            activeColor: const Color(0xFF1877F2),
                            viewedColor: Colors.grey.shade400,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipOval(
                            child: Global_Avatar_Widget(imageUrl: photoUrl, borderRadius: 40,
                                errorWidget: const Icon(Icons.person, color: Colors.grey, size: 20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Nombre
              Positioned(
                bottom: 8,
                left: 4,
                right: 4,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 11,
                    color: isViewed
                        ? const Color(0xFF64748B)
                        : const Color(0xFF0F172A),
                    fontWeight:
                        isViewed ? FontWeight.w400 : FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── GRADIENTE FALLBACK ──────────────────────────────
  Widget _gradientFallback({bool isOwn = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOwn
              ? [const Color(0xFF94A3B8), const Color(0xFFCBD5E1)]
              : [const Color(0xFF7C3AED), const Color(0xFFEC4899)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // ── ONDA BLANCA INFERIOR ────────────────────────────
  Widget _bottomWave() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: _WaveClipper(),
        child: Container(height: 72, color: Colors.white),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SEGMENTED RING PAINTER (anillo de progreso)
// ═══════════════════════════════════════════════════════════
class SegmentedRingPainter extends CustomPainter {
  final int totalSegments;
  final int viewedSegments;
  final Color activeColor;
  final Color viewedColor;
  final double strokeWidth;
  final double gapDegrees;

  const SegmentedRingPainter({
    required this.totalSegments,
    required this.viewedSegments,
    required this.activeColor,
    required this.viewedColor,
    this.strokeWidth = 2.8,
    this.gapDegrees = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalSegments <= 0) return;

    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = (size.width / 2) - strokeWidth / 2;

    final double totalGapDeg = gapDegrees * totalSegments;
    final double availableDeg = 360.0 - totalGapDeg;
    final double segmentDeg = availableDeg / totalSegments;

    const double startOffsetDeg = -90.0;

    for (int i = 0; i < totalSegments; i++) {
      final bool isViewed = i < viewedSegments;
      final Paint paint = Paint()
        ..color = isViewed ? viewedColor : activeColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final double startDeg = startOffsetDeg + i * (segmentDeg + gapDegrees);
      final double startRad = startDeg * pi / 180.0;
      final double sweepRad = segmentDeg * pi / 180.0;

      final Rect rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
      canvas.drawArc(rect, startRad, sweepRad, false, paint);
    }
  }

  @override
  bool shouldRepaint(SegmentedRingPainter old) =>
      old.totalSegments != totalSegments ||
      old.viewedSegments != viewedSegments ||
      old.activeColor != activeColor ||
      old.viewedColor != viewedColor;
}

// ═══════════════════════════════════════════════════════════
//  WAVE CLIPPER (onda decorativa)
// ═══════════════════════════════════════════════════════════
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.45);
    path.quadraticBezierTo(
      size.width / 2, 0, size.width, size.height * 0.45,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper old) => false;
}
