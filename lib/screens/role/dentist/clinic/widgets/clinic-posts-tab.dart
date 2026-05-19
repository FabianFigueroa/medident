import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/clinic/clinic-provider.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/services/clinic-service.dart';
import 'package:medident/screens/widgets/new-post/create_newposts_widget.dart';
import 'package:medident/screens/widgets/post-actions/post-actions-widget.dart';

class ClinicPostsTab extends StatelessWidget {
  const ClinicPostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
    final clinicId = context.select<ClinicProvider, String>((p) => p.clinic?.id ?? '');
    final user = context.watch<AuthenticateProvider>().user;
    final isOwner = context.select<ClinicProvider, bool>((p) => p.isOwner);

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(handle: handle),
        SliverToBoxAdapter(
          child: SizedBox(height: 30.0),
        ),
        if (clinicId.isNotEmpty)
          _UnifiedGrid(clinicId: clinicId, isOwner: isOwner, userUid: user?.uid ?? ''),
        const SliverToBoxAdapter(child: SizedBox(height: 60)),
      ],
    );
  }
}

class _UnifiedGrid extends StatelessWidget {
  final String clinicId;
  final bool isOwner;
  final String userUid;
  const _UnifiedGrid({required this.clinicId, required this.isOwner, required this.userUid});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthenticateProvider>().user;
    final userName = user?.fullName ?? '';
    final userPhoto = user?.imageUrl ?? '';
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ClinicService().streamClinicContent(clinicId),
      builder: (context, snap) {
        if (!snap.hasData) return const SliverToBoxAdapter(child: SizedBox.shrink());
        final docs = snap.data!;
        if (docs.isEmpty) {
          return SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(40),
            child: Center(child: Column(children: [
              Icon(Icons.grid_view, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text('Sin contenido aún', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            ])),
          ));
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final data = docs[index];
              final type = data['type'] as String? ?? 'penser';
              final imageUrls = (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
              final hasImage = imageUrls.isNotEmpty;
              final postId = data['_id'] as String? ?? '';
              final postType = data['_type'] as String? ?? 'posts';
              final createdBy = data['createdBy'] as String? ?? '';

              return GestureDetector(
                onTap: () => _showDetail(context, data, postId, userUid, userName, userPhoto),
                onLongPress: isOwner || createdBy == userUid
                    ? () => _deletePost(context, postId, postType)
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: hasImage
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(imageUrls.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  foregroundDecoration: hasImage ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.black.withOpacity(0.05), Colors.transparent],
                    ),
                  ) : null,
                  alignment: hasImage ? Alignment.topLeft : Alignment.center,
                  child: hasImage
                      ? Padding(
                          padding: const EdgeInsets.all(4),
                          child: _TypeBadge(type: type),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _TypeIcon(type: type, size: 18),
                              const SizedBox(height: 4),
                              Text(
                                data['description'] ?? data['name'] ?? data['title'] ?? type,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                ),
              );
            }, childCount: docs.length),
          ),
        );
      },
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> data, String postId, String userId, String userName, String userPhoto) {
    final type = data['type'] as String? ?? 'penser';
    final imageUrls = (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    final description = data['description'] as String? ?? '';
    final name = data['name'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(children: [
                _TypeIcon(type: type),
                const SizedBox(width: 8),
                Text(_typeLabel(type), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _typeColor(type))),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(ctx), child: Icon(Icons.close, color: Colors.grey[400])),
              ]),
            ),
            if (imageUrls.isNotEmpty)
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(imageUrl: imageUrls.first, fit: BoxFit.contain, width: double.infinity, height: 250,
                    placeholder: (_, __) => Container(color: Colors.grey[200], height: 250),
                    errorWidget: (_, __, ___) => Container(color: Colors.grey[200], height: 250, child: const Icon(Icons.broken_image)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (name.isNotEmpty) Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (name.isNotEmpty && description.isNotEmpty) const SizedBox(height: 8),
                if (description.isNotEmpty) Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4)),
              ]),
            ),
            PostActionsWidget(postId: postId, userId: userId, userName: userName, userPhoto: userPhoto),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePost(BuildContext context, String postId, String postType) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Eliminar'),
      content: const Text('¿Eliminar esta publicación?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
      ],
    ));
    if (ok == true) {
      try {
        if (postType == 'promotions') {
          await FirebaseFirestore.instance.collection('promotions').doc(postId).update({'isActive': false});
        } else {
          await FirebaseFirestore.instance.collection(postType).doc(postId).delete();
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publicación eliminada')));
        }
      } catch (_) {}
    }
  }
}

Widget _TypeBadge({required String type}) {
  final Color color = _typeColor(type);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.85),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_typeIconData(type), size: 10, color: Colors.white),
        const SizedBox(width: 3),
        Text(_typeShortLabel(type), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

Widget _TypeIcon({required String type, double size = 20}) {
  return Icon(_typeIconData(type), size: size, color: _typeColor(type));
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
    default: return 'Publicación';
  }
}

String _typeShortLabel(String type) {
  switch (type) {
    case 'photo': return 'FOTO';
    case 'event': return 'EVENTO';
    case 'video': return 'REEL';
    case 'poll': return 'ENCUESTA';
    case 'link': return 'ENLACE';
    case 'apoyo': return 'APOYO';
    case 'grupo': return 'GRUPO';
    case 'streaming': return 'EN VIVO';
    default: return 'POST';
  }
}

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
