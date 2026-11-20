import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePostsGrid extends StatelessWidget {
  final String userId;
  final int limit;
  final String title;

  const ProfilePostsGrid({
    super.key,
    required this.userId,
    this.limit = 30,
    this.title = 'Publicaciones',
  });

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('createdBy', isEqualTo: userId)
          .limit(limit)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];
        if (snapshot.connectionState == ConnectionState.waiting && docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final posts = docs.map((d) {
          final data = Map<String, dynamic>.from(d.data());
          data['id'] = d.id;
          return data;
        }).toList()
          ..sort((a, b) {
            DateTime parse(dynamic v) {
              if (v is Timestamp) return v.toDate();
              if (v is DateTime) return v;
              return DateTime.fromMillisecondsSinceEpoch(0);
            }

            return parse(b['createdAt']).compareTo(parse(a['createdAt']));
          });

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.grid_on_rounded, size: 18, color: Color(0xFF0EA5A4)),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return _PostThumb(data: posts[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PostThumb extends StatelessWidget {
  final Map<String, dynamic> data;

  const _PostThumb({required this.data});

  String get _imageUrl {
    final urls = data['imageUrls'];
    if (urls is List && urls.isNotEmpty) {
      final first = urls.first?.toString() ?? '';
      if (first.isNotEmpty) return first;
    }
    final media = data['media'];
    if (media is List && media.isNotEmpty) {
      final first = media.first;
      if (first is Map) {
        final url = first['url']?.toString() ?? first['thumbnailUrl']?.toString() ?? '';
        if (url.isNotEmpty) return url;
      }
    }
    for (final key in const ['imageUrl', 'thumbnailUrl', 'photoUrl']) {
      final value = data[key]?.toString() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final url = _imageUrl;
    final type = data['type']?.toString() ?? 'penser';
    final description = data['description']?.toString() ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: const Color(0xFFF1F5F9),
        child: url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFFE2E8F0)),
                errorWidget: (_, __, ___) => _fallback(type, description),
              )
            : _fallback(type, description),
      ),
    );
  }

  Widget _fallback(String type, String description) {
    IconData icon;
    switch (type) {
      case 'video':
        icon = Icons.play_circle_fill_rounded;
        break;
      case 'event':
        icon = Icons.event_rounded;
        break;
      case 'poll':
        icon = Icons.poll_rounded;
        break;
      case 'link':
        icon = Icons.link_rounded;
        break;
      case 'promo':
      case 'promotion':
        icon = Icons.local_offer_rounded;
        break;
      default:
        icon = Icons.article_rounded;
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF0EA5A4)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
            ),
          ],
        ],
      ),
    );
  }
}
