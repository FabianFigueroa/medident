import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/comment-model.dart';
import 'package:medident/core/services/reaction-service.dart';
import 'package:medident/core/services/comment-service.dart';

class PostActionsWidget extends StatefulWidget {
  final String postId;
  final String userId;
  final String userName;
  final String userPhoto;

  const PostActionsWidget({
    super.key,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userPhoto = '',
  });

  @override
  State<PostActionsWidget> createState() => _PostActionsWidgetState();
}

class _PostActionsWidgetState extends State<PostActionsWidget> {
  final ReactionService _reactionService = ReactionService();
  bool _showEmojiPicker = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).snapshots(),
      builder: (context, postSnap) {
        if (!postSnap.hasData || !postSnap.data!.exists) return const SizedBox.shrink();
        final postData = postSnap.data!.data() as Map<String, dynamic>;
        final likesCount = postData['likesCount'] as int? ?? 0;
        final likedBy = List<String>.from(postData['likedBy'] ?? []);
        final isLiked = likedBy.contains(widget.userId);
        final reactions = Map<String, dynamic>.from(postData['reactions'] ?? {});
        final userReactions = Map<String, dynamic>.from(postData['userReactions'] ?? {});
        final myReaction = userReactions[widget.userId] as String?;
        final commentsCount = postData['commentsCount'] as int? ?? 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionRow(
              isLiked: isLiked,
              likesCount: likesCount,
              reactions: reactions,
              myReaction: myReaction,
              commentsCount: commentsCount,
              onLike: () => _reactionService.toggleLike(widget.postId, widget.userId),
              onReactionTapped: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
              onComment: () => _showCommentSheet(context),
            ),
            if (_showEmojiPicker)
              _EmojiPicker(
                myReaction: myReaction,
                onSelected: (emoji) {
                  _reactionService.setReaction(widget.postId, widget.userId, emoji);
                  setState(() => _showEmojiPicker = false);
                },
              ),
          ],
        );
      },
    );
  }

  void _showCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CommentSheet(
        postId: widget.postId,
        userId: widget.userId,
        userName: widget.userName,
        userPhoto: widget.userPhoto,
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final bool isLiked;
  final int likesCount;
  final Map<String, dynamic> reactions;
  final String? myReaction;
  final int commentsCount;
  final VoidCallback onLike;
  final VoidCallback onReactionTapped;
  final VoidCallback onComment;

  const _ActionRow({
    required this.isLiked,
    required this.likesCount,
    required this.reactions,
    required this.myReaction,
    required this.commentsCount,
    required this.onLike,
    required this.onReactionTapped,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final hasReactions = reactions.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasReactions || likesCount > 0 || commentsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(children: [
                if (hasReactions)
                  Row(children: reactions.entries.map((e) {
                    final emoji = ReactionService.emojiMap[e.key] ?? '';
                    if (emoji.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Text(emoji, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList()),
                if (likesCount > 0 && !hasReactions)
                  Icon(Icons.favorite, size: 14, color: isLiked ? Colors.red[300] : Colors.grey[300]),
                if (likesCount > 0) ...[
                  const SizedBox(width: 4),
                  Text('$likesCount', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
                const Spacer(),
                if (commentsCount > 0)
                  Text('$commentsCount comentarios', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ]),
            ),
          Divider(height: 1, color: Colors.grey[200]),
          SizedBox(
            height: 40,
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: onLike,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_outline,
                          size: 18,
                          color: isLiked ? Colors.red[300] : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(isLiked ? 'Te gusta' : 'Me gusta',
                            style: TextStyle(fontSize: 12, color: isLiked ? Colors.red[300] : Colors.grey[500])),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 20, color: Colors.grey[200]),
              Expanded(
                child: GestureDetector(
                  onTap: onReactionTapped,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (myReaction != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Text(ReactionService.emojiMap[myReaction] ?? '', style: const TextStyle(fontSize: 16)),
                          ),
                        Icon(Icons.emoji_emotions_outlined, size: 18, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text('Reaccionar', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 20, color: Colors.grey[200]),
              Expanded(
                child: GestureDetector(
                  onTap: onComment,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text('Comentar', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  final String? myReaction;
  final ValueChanged<String> onSelected;

  const _EmojiPicker({required this.myReaction, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ReactionService.emojiTypes.map((type) {
          final emoji = ReactionService.emojiMap[type]!;
          final isActive = myReaction == type;
          return GestureDetector(
            onTap: () => onSelected(type),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(emoji, style: TextStyle(fontSize: isActive ? 26 : 22)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CommentSheet extends StatefulWidget {
  final String postId;
  final String userId;
  final String userName;
  final String userPhoto;

  const _CommentSheet({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userPhoto,
  });

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final CommentService _commentService = CommentService();
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              const Text('Comentarios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.close, color: Colors.grey[400])),
            ]),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: _commentService.streamCommentsByPost(widget.postId),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                final comments = snap.data!;
                if (comments.isEmpty) {
                  return Center(child: Text('Sin comentarios', style: TextStyle(color: Colors.grey[400], fontSize: 14)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: comments.length,
                  itemBuilder: (ctx, i) {
                    final c = comments[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        CircleAvatar(radius: 14,
                          backgroundImage: (c.sourcePhoto != null && c.sourcePhoto!.isNotEmpty) ? NetworkImage(c.sourcePhoto!) : null,
                          child: Text((c.sourceName.isNotEmpty ? c.sourceName[0] : '?').toUpperCase(), style: const TextStyle(fontSize: 11))),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.sourceName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(c.content, style: const TextStyle(fontSize: 13)),
                        ])),
                      ]),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 8, top: 4),
              child: Row(children: [
                CircleAvatar(radius: 16,
                  backgroundImage: widget.userPhoto.isNotEmpty ? NetworkImage(widget.userPhoto) : null,
                  child: Text((widget.userName.isNotEmpty ? widget.userName[0] : '?').toUpperCase(), style: const TextStyle(fontSize: 11))),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      filled: true, fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onSubmitted: _sending ? null : _sendComment,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendComment(String v) async {
    if (v.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await _commentService.addComment(
        postId: widget.postId,
        sourceId: widget.userId,
        sourceName: widget.userName,
        sourcePhoto: widget.userPhoto.isNotEmpty ? widget.userPhoto : null,
        content: v.trim(),
      );
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'commentsCount': FieldValue.increment(1),
      });
      _controller.clear();
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }
}
