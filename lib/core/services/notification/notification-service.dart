import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef NotificationTapCallback = void Function(Map<String, dynamic> data);

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  static String? _currentUserId;
  static bool _initialized = false;
  static NotificationTapCallback? _onTapCallback;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    _initAsync();
  }

  static void setOnTapCallback(NotificationTapCallback callback) {
    _onTapCallback = callback;
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
      final channelId = _resolveChannel(message.data);
      final androidDetails = AndroidNotificationDetails(
        channelId,
        _channelName(channelId),
        channelDescription: _channelDescription(channelId),
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails();
      final details = NotificationDetails(
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

  static String _resolveChannel(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    if (type == 'appointment' || type == 'appointment_reminder') return 'appointments_channel';
    if (type == 'delivery_status' || type == 'new_order') return 'delivery_channel';
    if (type == 'security' || type == 'rfid_alert') return 'security_channel';
    return 'general_channel';
  }

  static String _channelName(String channel) {
    switch (channel) {
      case 'appointments_channel': return 'Citas';
      case 'delivery_channel': return 'Entregas';
      case 'security_channel': return 'Seguridad';
      default: return 'General';
    }
  }

  static String _channelDescription(String channel) {
    switch (channel) {
      case 'appointments_channel': return 'Notificaciones de citas y agenda';
      case 'delivery_channel': return 'Notificaciones de estado de entregas';
      case 'security_channel': return 'Alertas de seguridad';
      default: return 'Notificaciones generales';
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    try {
      final data = message.data;
      if (data.isNotEmpty && _currentUserId != null) {
        await _saveNotificationToFirestore(data);
      }
    } catch (_) {}
  }

  static Future<void> _saveNotificationToFirestore(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': _currentUserId,
        'type': data['type'] ?? 'system',
        'title': data['title'] ?? 'Medident',
        'body': data['body'] ?? '',
        'data': data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  static Future<void> _onNotificationTap(RemoteMessage message) async {
    _handleNotificationTap(message.data.toString());
  }

  static void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        const JsonDecoder().convert(payload),
      );
      _onTapCallback?.call(data);
    } catch (_) {}
  }

  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (_) {}
  }
}
