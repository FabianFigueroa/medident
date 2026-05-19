import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/comment-model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _comments =>
      _firestore.collection('comments');

  Stream<List<CommentModel>> streamCommentsByPost(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CommentModel.fromJson(d.data(), d.id)).toList());
  }

  Future<String> addComment({
    required String postId,
    required String sourceId,
    required String sourceName,
    String? sourcePhoto,
    required String content,
  }) async {
    try {
      final ref = _comments.doc();
      await ref.set({
        'postId': postId,
        'sourceType': 'user',
        'sourceId': sourceId,
        'sourceName': sourceName,
        'sourcePhoto': sourcePhoto,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      debugPrint('CommentService.addComment error: $e');
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _comments.doc(commentId).delete();
    } catch (e) {
      debugPrint('CommentService.deleteComment error: $e');
      rethrow;
    }
  }
}
