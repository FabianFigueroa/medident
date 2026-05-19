import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/screens/widgets/avatar/global_avatar_widget.dart';

class Reels_One_Widget extends StatefulWidget {
  final List<dynamic> reels;
  final Function(dynamic)? onTap;
  final Function(dynamic)? onLike;
  final Function(dynamic)? onComment;
  final Function(dynamic)? onShare;
  final bool isLoading;

  const Reels_One_Widget({
    super.key,
    required this.reels,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
    this.isLoading = false,
  });

  @override
  State<Reels_One_Widget> createState() => _Reels_One_WidgetState();
}

class _Reels_One_WidgetState extends State<Reels_One_Widget> {
  final Set<String> _playingReels = {};
  final Set<String> _likedReels = {};

  void _togglePlay(String reelId) {
    setState(() {
      if (_playingReels.contains(reelId)) {
        _playingReels.remove(reelId);
      } else {
        _playingReels.add(reelId);
      }
    });
  }

  void _handleLike(dynamic reel) {
    final reelId = reel['id'] ?? '';
    if (reelId.isEmpty) return;
    setState(() {
      if (_likedReels.contains(reelId)) {
        _likedReels.remove(reelId);
      } else {
        _likedReels.add(reelId);
      }
    });
    widget.onLike?.call(reel);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reels.isEmpty && !widget.isLoading) {
      return _buildEmpty();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (tu diseño original)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Reels',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.reels.length} videos',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFEC4899),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista horizontal de reels (tu diseño original)
            widget.isLoading
                ? _buildShimmer()
                : SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.reels.take(5).length,
                      itemBuilder: (context, index) {
                        final reel = widget.reels[index];
                        return _buildReelItem(context, reel);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildReelItem(BuildContext context, dynamic reel) {
    final String? thumbnailUrl = reel['thumbnailUrl'];
    final String description = reel['description'] ?? '';
    final int likesCount = reel['likesCount'] ?? 0;
    final int commentsCount = reel['commentsCount'] ?? 0;
    final String reelId = reel['id'] ?? '';
    final bool isPlaying = _playingReels.contains(reelId);
    final bool isLiked = _likedReels.contains(reelId);

    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap?.call(reel);
        } else {
          _togglePlay(reelId);
        }
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Stack(
          children: [
            // Thumbnail (tu diseño original)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Global_Avatar_Widget(
                    imageUrl: thumbnailUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (thumbnailUrl == null || thumbnailUrl.isEmpty)
                    const Center(
                      child: Icon(Icons.video_file, size: 30, color: Colors.grey),
                    ),
                ],
              ),
            ),

            // ✅ Play/Pause overlay
            if (!isPlaying)
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ),

            // Info abajo (tu diseño original)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // ✅ Like button
                        GestureDetector(
                          onTap: () => _handleLike(reel),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${isLiked ? likesCount + 1 : likesCount}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // ✅ Comment button
                        GestureDetector(
                          onTap: () => widget.onComment?.call(reel),
                          child: const Icon(
                            Icons.chat_bubble,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$commentsCount',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // ✅ Share button
                        GestureDetector(
                          onTap: () => widget.onShare?.call(reel),
                          child: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.play_circle_fill_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'No hay reels disponibles',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
