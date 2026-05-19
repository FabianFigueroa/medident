import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/screens/widgets/post-actions/post-actions-widget.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;
  final String userId;
  final String userName;
  final String userPhoto;

  const PostDetailScreen({
    super.key,
    required this.postId,
    required this.data,
    required this.userId,
    required this.userName,
    this.userPhoto = '',
  });

  @override
  Widget build(BuildContext context) {
    final type = data['type'] as String? ?? 'penser';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypeIcon(type: type, size: 18),
            const SizedBox(width: 6),
            Text(
              _typeLabel(type),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _typeColor(type),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final liveData =
              (snap.data!.data() as Map<String, dynamic>)..['id'] = postId;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildContent(context, type, liveData),
              ),
              SliverToBoxAdapter(
                child: PostActionsWidget(
                  postId: postId,
                  userId: userId,
                  userName: userName,
                  userPhoto: userPhoto,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, String type, Map<String, dynamic> liveData) {
    final imageUrls =
        (liveData['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrls.isNotEmpty)
          _ImageSection(imageUrls: imageUrls),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserHeader(data: liveData),
              const SizedBox(height: 12),
              _buildTypeSpecificContent(type, liveData),
              const SizedBox(height: 16),
              _buildStats(liveData),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSpecificContent(String type, Map<String, dynamic> liveData) {
    switch (type) {
      case 'event':
        return _EventContent(data: liveData);
      case 'video':
        return _VideoContent(data: liveData);
      case 'poll':
        return _PollContent(data: liveData);
      case 'link':
        return _LinkContent(data: liveData);
      case 'apoyo':
        return _ApoyoContent(data: liveData);
      case 'grupo':
        return _GrupoContent(data: liveData);
      case 'streaming':
        return _StreamingContent(data: liveData);
      default:
        return _TextContent(data: liveData);
    }
  }

  Widget _buildStats(Map<String, dynamic> liveData) {
    final reactions =
        Map<String, dynamic>.from(liveData['reactions'] ?? {});
    final likesCount = liveData['likesCount'] as int? ?? 0;
    final commentsCount = liveData['commentsCount'] as int? ?? 0;
    return Row(
      children: [
        if (reactions.isNotEmpty)
          Row(
            children: reactions.entries.map((e) {
              final emoji = _emojiFor(e.key);
              if (emoji.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              );
            }).toList(),
          ),
        if (reactions.isNotEmpty && likesCount > 0)
          const SizedBox(width: 6),
        if (likesCount > 0)
          Text('$likesCount', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        const Spacer(),
        Text(
          '$commentsCount comentarios',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

// ─── IMAGE ──────────────────────────────────────────────

class _ImageSection extends StatelessWidget {
  final List<String> imageUrls;
  const _ImageSection({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: imageUrls.length > 1
          ? PageView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: imageUrls[i],
                fit: BoxFit.contain,
                width: double.infinity,
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            )
          : CachedNetworkImage(
              imageUrl: imageUrls.first,
              fit: BoxFit.contain,
              width: double.infinity,
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image),
              ),
            ),
    );
  }
}

// ─── USER HEADER ────────────────────────────────────────

class _UserHeader extends StatelessWidget {
  final Map<String, dynamic> data;
  const _UserHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    final name =
        data['userName'] as String? ?? data['createdBy'] as String? ?? 'Usuario';
    final photo = data['userPhoto'] as String? ?? '';
    final time = data['createdAt'] != null
        ? _formatTime(data['createdAt'] as Timestamp)
        : '';
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (time.isNotEmpty)
              Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
        ),
      ],
    );
  }

  String _formatTime(Timestamp ts) {
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }
}

// ─── TYPE-SPECIFIC CONTENT ──────────────────────────────

class _TextContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TextContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final desc = data['description'] as String? ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (desc.isNotEmpty)
          Text(desc, style: const TextStyle(fontSize: 15, height: 1.5)),
      ],
    );
  }
}

class _EventContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _EventContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final desc = data['description'] as String? ?? '';
    final date = (data['eventDate'] as Timestamp?)?.toDate();
    final location = data['location'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              Text(
                date != null
                    ? '${date.day}/${date.month}/${date.year}'
                    : 'Fecha por definir',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF59E0B),
                ),
              ),
              if (location != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.location_on, size: 14, color: const Color(0xFFF59E0B).withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(location, style: TextStyle(fontSize: 12, color: const Color(0xFFF59E0B).withOpacity(0.7))),
              ],
            ],
          ),
        ),
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ],
    );
  }
}

class _VideoContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _VideoContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final desc = data['description'] as String? ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (desc.isNotEmpty)
          Text(desc, style: const TextStyle(fontSize: 15, height: 1.5)),
      ],
    );
  }
}

class _PollContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PollContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final question = data['description'] as String? ?? data['question'] as String? ?? '';
    final options = (data['options'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.isNotEmpty)
          Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)),
        const SizedBox(height: 12),
        ...options.map((opt) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(opt['text'] as String? ?? '', style: const TextStyle(fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${opt['votes'] ?? 0} votos',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _LinkContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _LinkContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final url = data['url'] as String? ?? '';
    final desc = data['description'] as String? ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (desc.isNotEmpty)
          Text(desc, style: const TextStyle(fontSize: 15, height: 1.5)),
        if (url.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(url,
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ApoyoContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ApoyoContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? '';
    final desc = data['description'] as String? ?? '';
    final contact = data['contact'] as String? ?? '';
    final members = data['membersCount'] as int? ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty)
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.people, size: 16, color: Color(0xFF06B6D4)),
          const SizedBox(width: 4),
          Text('$members miembros', style: const TextStyle(fontSize: 13, color: Color(0xFF06B6D4))),
          if (contact.isNotEmpty) ...[
            const SizedBox(width: 16),
            const Icon(Icons.contact_phone_outlined, size: 16, color: Color(0xFF06B6D4)),
            const SizedBox(width: 4),
            Text(contact, style: const TextStyle(fontSize: 13, color: Color(0xFF06B6D4))),
          ],
        ]),
      ],
    );
  }
}

class _GrupoContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _GrupoContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? '';
    final desc = data['description'] as String? ?? '';
    final members = data['membersCount'] as int? ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty)
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.people, size: 16, color: Color(0xFFF97316)),
          const SizedBox(width: 4),
          Text('$members miembros', style: const TextStyle(fontSize: 13, color: Color(0xFFF97316))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Unirse', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ]),
      ],
    );
  }
}

class _StreamingContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _StreamingContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? '';
    final desc = data['description'] as String? ?? '';
    final streamUrl = data['streamUrl'] as String? ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('EN VIVO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(width: 8),
          if (name.isNotEmpty)
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
        if (streamUrl.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(children: [
              const Icon(Icons.link, size: 16, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Expanded(child: Text(streamUrl, style: const TextStyle(color: Colors.blue, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ],
      ],
    );
  }
}

// ─── HELPERS ────────────────────────────────────────────

Color _typeColor(String type) {
  switch (type) {
    case 'event': return const Color(0xFFF59E0B);
    case 'video': return const Color(0xFF8B5CF6);
    case 'poll': return const Color(0xFF10B981);
    case 'link': return const Color(0xFF3B82F6);
    case 'apoyo': return const Color(0xFF06B6D4);
    case 'grupo': return const Color(0xFFF97316);
    case 'streaming': return const Color(0xFFEF4444);
    default: return const Color(0xFF6B7280);
  }
}

IconData _typeIconData(String type) {
  switch (type) {
    case 'photo': return Icons.image_rounded;
    case 'event': return Icons.event_rounded;
    case 'video': return Icons.play_circle_rounded;
    case 'poll': return Icons.poll_rounded;
    case 'link': return Icons.link_rounded;
    case 'apoyo': return Icons.group_add_rounded;
    case 'grupo': return Icons.groups_rounded;
    case 'streaming': return Icons.videocam_rounded;
    default: return Icons.article_rounded;
  }
}

String _typeLabel(String type) {
  switch (type) {
    case 'photo': return 'Foto';
    case 'event': return 'Evento';
    case 'video': return 'Reel';
    case 'poll': return 'Encuesta';
    case 'link': return 'Enlace';
    case 'apoyo': return 'Grupo de Apoyo';
    case 'grupo': return 'Grupo';
    case 'streaming': return 'Streaming';
    default: return 'Publicacion';
  }
}

String _emojiFor(String key) {
  switch (key) {
    case 'love': return '\u2764\uFE0F';
    case 'laugh': return '\u{1F602}';
    case 'wow': return '\u{1F62E}';
    case 'sad': return '\u{1F622}';
    case 'angry': return '\u{1F620}';
    default: return '';
  }
}

class _TypeIcon extends StatelessWidget {
  final String type;
  final double size;
  const _TypeIcon({required this.type, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Icon(_typeIconData(type), size: size, color: _typeColor(type));
  }
}
