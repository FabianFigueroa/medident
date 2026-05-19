import 'package:flutter/material.dart';

class PostInteractions extends StatefulWidget {
  final String postId;
  final bool initialLiked;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final Future<void> Function()? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostInteractions({
    super.key,
    required this.postId,
    this.initialLiked = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  State<PostInteractions> createState() => _PostInteractionsState();
}

class _PostInteractionsState extends State<PostInteractions>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeCtrl;
  late Animation<double> _likeAnim;
  late bool _isLiked;
  late int _likesCount;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _likeCtrl, curve: Curves.elasticOut),
    );
    _isLiked = widget.initialLiked;
    _likesCount = widget.likesCount;
    if (_isLiked) _likeCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _likeCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
      if (_isLiked) { _likeCtrl.forward(); } else { _likeCtrl.reverse(); }
    });
    try {
      if (widget.onLike != null) await widget.onLike!();
    } catch (_) {
      if (mounted) setState(() {
        _isLiked = wasLiked;
        _likesCount += _isLiked ? 1 : -1;
      });
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('$_likesCount Me gusta', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const Spacer(),
            Text('${widget.commentsCount} comentarios', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: _toggleLike,
                child: AnimatedBuilder(
                  animation: _likeAnim,
                  builder: (context, child) => Transform.scale(
                    scale: _likeAnim.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_outline,
                          color: _isLiked ? Colors.red[400] : Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isLiked ? 'Te gusta' : 'Me gusta',
                          style: TextStyle(fontSize: 11, color: _isLiked ? Colors.red[400] : Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onComment,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 6),
                    Text('Comentar', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onShare,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share_outlined, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 6),
                    Text('Compartir', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
