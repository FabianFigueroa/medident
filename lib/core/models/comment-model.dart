import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String sourceType;
  final String sourceId;
  final String sourceName;
  final String? sourcePhoto;
  final String content;
  final Timestamp createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    this.sourceType = 'user',
    required this.sourceId,
    required this.sourceName,
    this.sourcePhoto,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json, String id) {
    return CommentModel(
      id: id,
      postId: json['postId'] ?? '',
      sourceType: json['sourceType'] ?? 'user',
      sourceId: json['sourceId'] ?? '',
      sourceName: json['sourceName'] ?? '',
      sourcePhoto: json['sourcePhoto'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'sourceType': sourceType,
      'sourceId': sourceId,
      'sourceName': sourceName,
      'sourcePhoto': sourcePhoto,
      'content': content,
      'createdAt': createdAt,
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? sourceType,
    String? sourceId,
    String? sourceName,
    String? sourcePhoto,
    String? content,
    Timestamp? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
      sourcePhoto: sourcePhoto ?? this.sourcePhoto,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
