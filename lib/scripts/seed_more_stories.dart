import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/// Script to add more test stories for testing
/// Run with: flutter run lib/scripts/seed_more_stories.dart
void main() async {
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  
  final testStories = [
    {
      'userId': 'user_dentist_1',
      'userName': 'Dra. Ana García',
      'userPhoto': 'https://randomuser.me/api/portraits/women/1.jpg',
      'imageUrl': 'https://picsum.photos/400/700?random=101',
      'status': 'active',
      'isActive': true,
      'isWorking': true,
      'isViewed': false,
      'viewedBy': <String>[],
      'likedBy': <String>[],
      'likesCount': 12,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))),
    },
    {
      'userId': 'user_dentist_2',
      'userName': 'Dr. Roberto Silva',
      'userPhoto': 'https://randomuser.me/api/portraits/men/2.jpg',
      'imageUrl': 'https://picsum.photos/400/700?random=102',
      'status': 'active',
      'isActive': true,
      'isWorking': false,
      'isViewed': false,
      'viewedBy': <String>[],
      'likedBy': <String>[],
      'likesCount': 8,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
    },
    {
      'userId': 'user_dentist_3',
      'userName': 'Dra. Laura Martínez',
      'userPhoto': 'https://randomuser.me/api/portraits/women/3.jpg',
      'imageUrl': 'https://picsum.photos/400/700?random=103',
      'status': 'busy',
      'isActive': true,
      'isWorking': true,
      'isViewed': false,
      'viewedBy': <String>[],
      'likedBy': <String>[],
      'likesCount': 15,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 3))),
    },
    {
      'userId': 'user_dentist_4',
      'userName': 'Aux. Carlos García',
      'userPhoto': 'https://randomuser.me/api/portraits/men/4.jpg',
      'imageUrl': 'https://picsum.photos/400/700?random=104',
      'status': 'active',
      'isActive': true,
      'isWorking': true,
      'isViewed': false,
      'viewedBy': <String>[],
      'likedBy': <String>[],
      'likesCount': 5,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 4))),
    },
    {
      'userId': 'user_dentist_5',
      'userName': 'Aux. María López',
      'userPhoto': 'https://randomuser.me/api/portraits/women/5.jpg',
      'imageUrl': 'https://picsum.photos/400/700?random=105',
      'status': 'active',
      'isActive': true,
      'isWorking': false,
      'isViewed': false,
      'viewedBy': <String>[],
      'likedBy': <String>[],
      'likesCount': 20,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
    },
    {
      'userId': 'user_dentist_1',
      'userName': 'Dra. Ana García',
      'userPhoto': 'https://randomuser.me/api/portraits/women/1.jpg',
      'imageUrl': 'https://picsum.photos/400/700?random=106',
      'status': 'active',
      'isActive': true,
      'isWorking': true,
      'isViewed': false,
      'viewedBy': <String>[],
      'likedBy': <String>[],
      'likesCount': 9,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
    },
    {
      'userId': 'user_dentist_2',
      'userName': 'Dr. Roberto Silva',
      'userPhoto': 'https://randomuser.me/api/portraits/men/2.jpg',
      'imageUrl': 'https://picsum.photos/400/700?random=107',
      'status': 'active',
      'isActive': true,
      'isWorking': true,
      'isViewed': false,
      'viewedBy': <String>[],
      'likedBy': <String>[],
      'likesCount': 11,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 45))),
    },
    {
      'userId': 'user_dentist_3',
      'userName': 'Dra. Laura Martínez',
      'userPhoto': 'https://randomuser.me/api/portraits/women/3.jpg',
      'imageUrl': 'https://picsum.photos/400/700?random=108',
      'status': 'busy',
      'isActive': true,
      'isWorking': false,
      'isViewed': false,
      'viewedBy': <String>[],
      'likedBy': <String>[],
      'likesCount': 7,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 50))),
    },
  ];

  try {
    final batch = firestore.batch();
    
    for (final storyData in testStories) {
      final docRef = firestore.collection('stories').doc();
      batch.set(docRef, storyData);
    }
    
    await batch.commit();
    debugPrint('✅ Added ${testStories.length} test stories successfully');
  } catch (e) {
    debugPrint('❌ Error adding stories: $e');
  }
}
