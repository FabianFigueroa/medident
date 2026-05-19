import 'package:cloud_firestore/cloud_firestore.dart';

/// Test data for stories during development
class TestStories {
  static List<Map<String, dynamic>> get sampleStories => [
    {
      'id': 'test_story_1',
      'sourceType': 'user',
      'sourceId': 'user_dentist_1',
      'sourceName': 'Dra. Ana García',
      'sourcePhoto': '',
      'createdBy': 'user_dentist_1',
      'imageUrl': '',
      'text': '¡Bienvenidos a nuestra clínica!',
      'isActive': true,
      'viewedBy': [],
      'likedBy': [],
      'likesCount': 0,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'test_story_2',
      'sourceType': 'clinic',
      'sourceId': 'clinic_test_1',
      'sourceName': 'Clínica Medident',
      'sourcePhoto': '',
      'createdBy': 'user_dentist_1',
      'imageUrl': '',
      'text': 'Nuevos horarios disponibles',
      'isActive': true,
      'viewedBy': [],
      'likedBy': [],
      'likesCount': 0,
      'createdAt': Timestamp.now(),
    },
  ];
}
