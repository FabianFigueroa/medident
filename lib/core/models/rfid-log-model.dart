import 'package:cloud_firestore/cloud_firestore.dart';

class RfidLogModel {
  final String id;
  final String userId;
  final String cardId;
  final String readerId;
  final bool granted;
  final String? photoUrl;
  final DateTime timestamp;
  final String location;
  final String? patientId;
  final String? description;

  const RfidLogModel({
    required this.id,
    required this.userId,
    required this.cardId,
    required this.readerId,
    required this.granted,
    this.photoUrl,
    required this.timestamp,
    required this.location,
    this.patientId,
    this.description,
  });

  factory RfidLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RfidLogModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      cardId: data['cardId'] ?? '',
      readerId: data['readerId'] ?? '',
      granted: data['granted'] ?? false,
      photoUrl: data['photoUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: data['location'] ?? '',
      patientId: data['patientId'],
      description: data['description'],
    );
  }

  factory RfidLogModel.fromJson(Map<String, dynamic> json, String id) {
    return RfidLogModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      cardId: json['cardId'] as String? ?? '',
      readerId: json['readerId'] as String? ?? '',
      granted: json['granted'] as bool? ?? false,
      photoUrl: json['photoUrl'] as String?,
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
              : DateTime.parse(json['timestamp'] as String))
          : DateTime.now(),
      location: json['location'] as String? ?? '',
      patientId: json['patientId'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cardId': cardId,
      'readerId': readerId,
      'granted': granted,
      'photoUrl': photoUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location,
      'patientId': patientId,
      'description': description,
    };
  }
}
