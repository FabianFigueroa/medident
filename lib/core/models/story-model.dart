import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/media-item.dart';

/// Modelo ligero para stories del home
class StoryModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String imageUrl;
  final String? text;
  final String? status;
  final bool isActive;
  final bool isWorking;
  final bool isViewed;
  final List<String> viewedBy;
  final List<String> likedBy;
  final int likesCount;
  final DateTime createdAt;

  // Source
  final String sourceType;
  final String sourceId;
  final String sourceName;
  final String? sourcePhoto;

  List<MediaItem> get media => imageUrl.isNotEmpty
      ? [MediaItem.fromUrl(imageUrl)]
      : [];

  const StoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.imageUrl,
    this.text,
    this.status,
    this.isActive = false,
    this.isWorking = false,
    this.isViewed = false,
    this.viewedBy = const [],
    this.likedBy = const [],
    this.likesCount = 0,
    required this.createdAt,
    this.sourceType = 'user',
    this.sourceId = '',
    this.sourceName = '',
    this.sourcePhoto,
  });

  factory StoryModel.fromJson(Map<String, dynamic> map, String id) {
    final viewedByList = map['viewedBy'] is List ? List<String>.from(map['viewedBy']) : <String>[];
    final likedByList = map['likedBy'] is List ? List<String>.from(map['likedBy']) : <String>[];
    return StoryModel(
      id: id,
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      userPhoto: map['userPhoto']?.toString(),
      imageUrl: map['imageUrl']?.toString() ?? '',
      text: map['text']?.toString(),
      status: map['status']?.toString(),
      isActive: map['isActive'] ?? true,
      isWorking: map['isWorking'] ?? false,
      isViewed: map['isViewed'] ?? false,
      viewedBy: viewedByList,
      likedBy: likedByList,
      likesCount: map['likesCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sourceType: map['sourceType']?.toString() ?? 'user',
      sourceId: map['sourceId']?.toString() ?? map['userId']?.toString() ?? '',
      sourceName: map['sourceName']?.toString() ?? map['userName']?.toString() ?? '',
      sourcePhoto: map['sourcePhoto']?.toString() ?? map['userPhoto']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'imageUrl': imageUrl,
      'text': text,
      'status': status,
      'isActive': isActive,
      'isWorking': isWorking,
      'isViewed': isViewed,
      'viewedBy': viewedBy,
      'likedBy': likedBy,
      'likesCount': likesCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  StoryModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhoto,
    String? imageUrl,
    String? text,
    String? status,
    bool? isActive,
    bool? isWorking,
    bool? isViewed,
    List<String>? viewedBy,
    List<String>? likedBy,
    int? likesCount,
    DateTime? createdAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      imageUrl: imageUrl ?? this.imageUrl,
      text: text ?? this.text,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isWorking: isWorking ?? this.isWorking,
      isViewed: isViewed ?? this.isViewed,
      viewedBy: viewedBy ?? this.viewedBy,
      likedBy: likedBy ?? this.likedBy,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
