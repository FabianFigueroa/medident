import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/models/post-model.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';
import 'package:medident/screens/role/dentist/posts/post-detail-screen.dart';
import 'package:medident/screens/widgets/media/media_grid.dart';

class Post_One_Widget extends StatefulWidget {
  final PostModel post;
  final String currentUserId;

  const Post_One_Widget({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  State<Post_One_Widget> createState() => _Post_One_WidgetState();
}

class _Post_One_WidgetState extends State<Post_One_Widget>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  late Animation<double> _likeAnimation;
  bool _isLiked = false;
  bool _isLoadingAction = false;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );
    _isLiked = widget.post.likedBy?.contains(widget.currentUserId) ?? false;
    
    if (_isLiked) {
      _likeController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    if (_isLoadingAction) return;
    
    setState(() => _isLoadingAction = true);
    
    final provider = context.read<DentistHomeProvider>();
    final wasLiked = _isLiked;
    
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeController.forward();
      } else {
        _likeController.reverse();
      }
    });
    
    try {
      await provider.likePost(widget.post.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          if (_isLiked) {
            _likeController.forward();
          } else {
            _likeController.reverse();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAction = false);
    }
  }

  void _openDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: widget.post,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    final isOwner = widget.post.userId == widget.currentUserId;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (!isOwner) ...[
                _buildOptionTile(
                  icon: Icons.share_outlined,
                  label: 'Compartir',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<DentistHomeProvider>().sharePost(widget.post.id);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.bookmark_border,
                  label: 'Guardar',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<DentistHomeProvider>().savePost(widget.post.id);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.flag,
                  label: 'Reportar',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showReportDialog();
                  },
                ),
                _buildOptionTile(
                  icon: Icons.block,
                  label: 'Bloquear usuario',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<DentistHomeProvider>().blockUser(widget.post.userId);
                  },
                ),
              ] else ...[
                _buildOptionTile(
                  icon: Icons.visibility_off,
                  label: 'Ocultar post',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<DentistHomeProvider>().hidePost(widget.post.id);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.delete,
                  label: 'Eliminar',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDelete();
                  },
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700]),
      title: Text(
        label,
        style: TextStyle(color: color ?? Colors.grey[700]),
      ),
      onTap: onTap,
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Reportar contenido'),
        content: const Text('¿Por qué quieres reportar este contenido?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DentistHomeProvider>().reportContent(
                contentId: widget.post.id,
                contentType: 'post',
                reason: 'Contenido inapropiado',
              );
            },
            child: const Text('Contenido inapropiado'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DentistHomeProvider>().reportContent(
                contentId: widget.post.id,
                contentType: 'post',
                reason: 'Spam',
              );
            },
            child: const Text('Spam'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Eliminar post'),
        content: const Text('¿Estás seguro de eliminar este post? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DentistHomeProvider>().deletePost(widget.post.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.post.media;
    final hasMedia = media.isNotEmpty;
    
    return GestureDetector(
      onTap: _openDetail,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header moderno
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar_${widget.post.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1877F2).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: widget.post.userPhoto != null && widget.post.userPhoto!.isNotEmpty
                          ? CachedNetworkImageProvider(widget.post.userPhoto!)
                          : null,
                      child: widget.post.userPhoto == null || widget.post.userPhoto!.isEmpty
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.title.isNotEmpty ? widget.post.title : 'Usuario',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (widget.post.city.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 2),
                              Text(
                                widget.post.city,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Text(
                    widget.post.timeAgo,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz, size: 20, color: Colors.grey[700]),
                    onPressed: _showOptionsMenu,
                  ),
                ],
              ),
            ),

            // Description
            if (widget.post.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Text(
                  widget.post.description,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),

            if (hasMedia) ...[
              const SizedBox(height: 10),
              MediaGrid(
                items: media,
                borderRadius: 12,
                onItemTap: (item, index) => _openDetail(),
              ),
            ],

            // Engagement stats
            if (widget.post.likesCount > 0 || widget.post.commentsCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(children: [
                  if (widget.post.likesCount > 0) ...[
                    Icon(Icons.favorite, size: 14, color: Colors.red[400]),
                    const SizedBox(width: 4),
                    Text('${widget.post.likesCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                  ],
                  if (widget.post.commentsCount > 0) ...[
                    Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${widget.post.commentsCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ]),
              ),

            const Divider(height: 1, thickness: 0.5),

            // Action Buttons modernos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                    label: 'Me gusta',
                    color: _isLiked ? Colors.red : null,
                    onTap: _toggleLike,
                  ),
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Comentar',
                    onTap: _openDetail,
                  ),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: 'Compartir',
                    onTap: () {
                      context.read<DentistHomeProvider>().sharePost(widget.post.id);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ScaleTransition(
              scale: icon == Icons.favorite || icon == Icons.favorite_border
                  ? _likeAnimation
                  : const AlwaysStoppedAnimation(1.0),
              child: Icon(icon, size: 20, color: color ?? Colors.grey[700]),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
