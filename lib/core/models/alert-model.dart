import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String userId;
  final String clinicId;
  final String type;
  final String severity;
  final String emoji;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? room;
  final String? deviceId;
  final String? cardId;
  final String? photoUrl;
  final bool read;
  final bool handled;
  final String? handledBy;
  final Map<String, dynamic>? metadata;

  const AlertModel({
    required this.id,
    required this.userId,
    this.clinicId = '',
    required this.type,
    required this.severity,
    this.emoji = '',
    required this.title,
    required this.description,
    required this.timestamp,
    this.room,
    this.deviceId,
    this.cardId,
    this.photoUrl,
    this.read = false,
    this.handled = false,
    this.handledBy,
    this.metadata,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      clinicId: data['clinicId'] ?? '',
      type: data['type'] ?? 'unknown',
      severity: data['severity'] ?? 'low',
      emoji: data['emoji'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      room: data['room'],
      deviceId: data['deviceId'],
      cardId: data['cardId'],
      photoUrl: data['photoUrl'],
      read: data['read'] ?? false,
      handled: data['handled'] ?? false,
      handledBy: data['handledBy'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clinicId': clinicId,
      'type': type,
      'severity': severity,
      'emoji': emoji,
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'room': room,
      'deviceId': deviceId,
      'cardId': cardId,
      'photoUrl': photoUrl,
      'read': read,
      'handled': handled,
      'handledBy': handledBy,
      'metadata': metadata,
    };
  }
}
