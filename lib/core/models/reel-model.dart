import 'package:cloud_firestore/cloud_firestore.dart';

class ReelModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? description;
  final String? musicTitle;
  final String? musicArtist;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<String>? likedBy;
  final int viewsCount;
  final double? duration; // duración en segundos
  final DateTime createdAt;
  final bool isPromoted;

  ReelModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.videoUrl,
    this.thumbnailUrl,
    this.description,
    this.musicTitle,
    this.musicArtist,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.likedBy,
    this.viewsCount = 0,
    this.duration,
    required this.createdAt,
    this.isPromoted = false,
  });

  factory ReelModel.fromMap(Map<String, dynamic> map, String id) {
    return ReelModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhoto: map['userPhoto'],
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      description: map['description'],
      musicTitle: map['musicTitle'],
      musicArtist: map['musicArtist'],
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      sharesCount: map['sharesCount'] ?? 0,
      likedBy: map['likedBy'] != null ? List<String>.from(map['likedBy']) : null,
      viewsCount: map['viewsCount'] ?? 0,
      duration: map['duration']?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPromoted: map['isPromoted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'musicTitle': musicTitle,
      'musicArtist': musicArtist,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'likedBy': likedBy,
      'viewsCount': viewsCount,
      'duration': duration,
      'createdAt': FieldValue.serverTimestamp(),
      'isPromoted': isPromoted,
    };
  }
}
