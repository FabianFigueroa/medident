import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ReactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final ref = _posts.doc(postId);
      final snap = await ref.get();
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      if (likedBy.contains(userId)) {
        await ref.update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        await ref.update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likesCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      debugPrint('ReactionService.toggleLike error: $e');
    }
  }

  Future<void> setReaction(String postId, String userId, String emojiType) async {
    try {
      final ref = _posts.doc(postId);
      final snap = await ref.get();
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final userReactions = Map<String, dynamic>.from(data['userReactions'] ?? {});
      final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});

      final previousEmoji = userReactions[userId] as String?;

      if (previousEmoji == emojiType) {
        userReactions.remove(userId);
        if (reactions.containsKey(emojiType)) {
          final count = reactions[emojiType] as int? ?? 1;
          if (count <= 1) {
            reactions.remove(emojiType);
          } else {
            reactions[emojiType] = count - 1;
          }
        }
      } else {
        if (previousEmoji != null) {
          final prevCount = reactions[previousEmoji] as int? ?? 1;
          if (prevCount <= 1) {
            reactions.remove(previousEmoji);
          } else {
            reactions[previousEmoji] = prevCount - 1;
          }
        }
        userReactions[userId] = emojiType;
        reactions[emojiType] = (reactions[emojiType] as int? ?? 0) + 1;
      }

      await ref.update({
        'userReactions': userReactions,
        'reactions': reactions,
      });
    } catch (e) {
      debugPrint('ReactionService.setReaction error: $e');
    }
  }

  static const Map<String, String> emojiMap = {
    'love': '\u2764\uFE0F',
    'laugh': '\u{1F602}',
    'wow': '\u{1F62E}',
    'sad': '\u{1F622}',
    'angry': '\u{1F620}',
  };

  static const List<String> emojiTypes = ['love', 'laugh', 'wow', 'sad', 'angry'];
}
