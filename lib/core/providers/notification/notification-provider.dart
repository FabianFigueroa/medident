import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/notification-model.dart';
import 'package:medident/core/services/notification/notification-data-service.dart';

class NotificationProvider with ChangeNotifier {
  final String userId;
  final NotificationDataService _service = NotificationDataService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StreamSubscription? _subscription;

  NotificationProvider({required this.userId}) {
    _init();
  }

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  List<NotificationModel> get followRequests =>
      _notifications.where((n) => n.type == 'follow_request').toList();

  void _init() {
    _isLoading = true;
    notifyListeners();
    _subscription = _service.streamNotifications(userId).listen(
      (list) {
        _notifications = list;
        _unreadCount = list.where((n) => !n.isRead).length;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead(userId);
  }

  Future<void> refresh() async {
    _subscription?.cancel();
    _init();
  }

  Future<void> createFollowRequestNotification({
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhoto,
  }) async {
    await _service.createNotification(
      userId: fromUserId,
      type: 'follow_request',
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserPhoto: fromUserPhoto,
      title: 'Solicitud de seguimiento',
      body: '$fromUserName quiere seguirte',
      data: {'status': 'pending'},
    );
  }

  Future<void> acceptFollowRequest(String fromUserId, String notificationId) async {
    try {
      final fs = FirebaseFirestore.instance;
      final batch = fs.batch();
      final followRef = fs.collection('follows').doc('${fromUserId}_$userId');
      batch.update(followRef, {'status': 'accepted', 'acceptedAt': FieldValue.serverTimestamp()});
      batch.update(fs.collection('users').doc(fromUserId), {'followingCount': FieldValue.increment(1)});
      batch.update(fs.collection('users').doc(userId), {'followersCount': FieldValue.increment(1)});
      batch.delete(fs.collection('notifications').doc(notificationId));
      await batch.commit();
    } catch (e) {
      debugPrint('Error accepting follow request: $e');
      rethrow;
    }
  }

  Future<void> rejectFollowRequest(String fromUserId, String notificationId) async {
    try {
      final fs = FirebaseFirestore.instance;
      final batch = fs.batch();
      batch.delete(fs.collection('follows').doc('${fromUserId}_$userId'));
      batch.delete(fs.collection('notifications').doc(notificationId));
      await batch.commit();
    } catch (e) {
      debugPrint('Error rejecting follow request: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
