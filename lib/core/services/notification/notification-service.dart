import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  static String? _currentUserId;
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    _initAsync();
  }

  static Future<void> _initAsync() async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      if (!kIsWeb) {
        _localNotifications = FlutterLocalNotificationsPlugin();
        const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosSettings = DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        const settings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );
        await _localNotifications!.initialize(
          settings,
          onDidReceiveNotificationResponse: (response) {
            _handleNotificationTap(response.payload);
          },
        );
      }
    } catch (_) {}

    try {
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    } catch (_) {}
    try {
      FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);
    } catch (_) {}
    try {
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    } catch (_) {}

    try {
      await _getAndSaveToken();
    } catch (_) {}

    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
      );
    } catch (_) {}
  }

  static Future<void> setUserId(String userId) async {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    try {
      await _getAndSaveToken();
    } catch (_) {}
  }

  static Future<void> _getAndSaveToken() async {
    final token = await _messaging.getToken();
    if (token != null && _currentUserId != null) {
      await _saveToken(_currentUserId!, token);
    }
    try {
      _messaging.onTokenRefresh.listen((newToken) {
        if (_currentUserId != null) {
          _saveToken(_currentUserId!, newToken);
        }
      });
    } catch (_) {}
  }

  static Future<void> _saveToken(String userId, String token) async {
    try {
      final data = {'fcmToken': token};
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(data, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection('riders')
          .doc(userId)
          .set(data, SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    if (kIsWeb || _localNotifications == null) return;
    try {
      final title = message.notification?.title ?? 'Medident';
      final body = message.notification?.body ?? '';
      const androidDetails = AndroidNotificationDetails(
        'delivery_channel',
        'Entregas',
        channelDescription: 'Notificaciones de estado de entregas',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _localNotifications!.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: message.data.toString(),
      );
    } catch (_) {}
  }

  @pragma('vm:entry-point')
  static Future<void> _onBackgroundMessage(RemoteMessage message) async {}

  static Future<void> _onNotificationTap(RemoteMessage message) async {
    _handleNotificationTap(message.data.toString());
  }

  static void _handleNotificationTap(String? payload) {}

  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (_) {}
  }
}
