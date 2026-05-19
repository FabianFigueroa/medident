import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/media-item.dart';

class PostModel {
  final String id;
  final String title;
  final String description;
  final List<String>? imageUrls;
  final List<MediaItem> media;
  final String userId;
  final List<String>? likedBy;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  final String city;
  final String? userPhoto;
  final String? userName;
  final String? clinicId;

  // Source (dueño del contenido: user o clinic)
  final String sourceType;      // "user" | "clinic"
  final String sourceId;        // uid o clinicId
  final String sourceName;      // nombre a mostrar
  final String? sourcePhoto;    // foto a mostrar

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrls,
    List<MediaItem>? media,
    required this.userId,
    this.likedBy,
    required this.likesCount,
    this.commentsCount = 0,
    this.sharesCount = 0,
    required this.createdAt,
    required this.city,
    this.userPhoto,
    this.userName,
    this.clinicId,
    this.sourceType = 'user',
    this.sourceId = '',
    this.sourceName = '',
    this.sourcePhoto,
  }) : media = media ?? (imageUrls != null ? MediaItem.fromLegacyUrls(imageUrls) : []);

  factory PostModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    final imageUrls = json['imageUrls'] != null
        ? List<String>.from(json['imageUrls'])
        : null;

    return PostModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrls: imageUrls,
      media: MediaItem.fromFirestore(json),
      userId: json['userId'] ?? '',
      likedBy: json['likedBy'] != null 
          ? List<String>.from(json['likedBy']) 
          : null,
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      createdAt: parseDate(json['createdAt']),
      city: json['city'] ?? '',
      userPhoto: json['userPhoto'],
      userName: json['userName'],
      clinicId: json['clinicId'],
      sourceType: json['sourceType'] ?? 'user',
      sourceId: json['sourceId'] ?? json['userId'] ?? '',
      sourceName: json['sourceName'] ?? json['userName'] ?? '',
      sourcePhoto: json['sourcePhoto'] ?? json['userPhoto'],
    );
  }

  PostModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? imageUrls,
    List<MediaItem>? media,
    String? userId,
    List<String>? likedBy,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    DateTime? createdAt,
    String? city,
    String? userPhoto,
    String? userName,
    String? clinicId,
    String? sourceType,
    String? sourceId,
    String? sourceName,
    String? sourcePhoto,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      media: media ?? this.media,
      userId: userId ?? this.userId,
      likedBy: likedBy ?? this.likedBy,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      createdAt: createdAt ?? this.createdAt,
      city: city ?? this.city,
      userPhoto: userPhoto ?? this.userPhoto,
      userName: userName ?? this.userName,
      clinicId: clinicId ?? this.clinicId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
      sourcePhoto: sourcePhoto ?? this.sourcePhoto,
    );
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Ahora';
    if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes}m';
    if (difference.inHours < 24) return 'Hace ${difference.inHours}h';
    if (difference.inDays < 30) return 'Hace ${difference.inDays}d';
    return 'Hace ${(difference.inDays / 30).floor()} meses';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'userId': userId,
      'likedBy': likedBy,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'createdAt': createdAt.toIso8601String(),
      'city': city,
      'clinicId': clinicId,
    };
  }
}
