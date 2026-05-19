import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String tag, String message) {
    debugPrint('[$tag] $message');
  }
  static void logWithRole({
    required String tag,
    required String message,
    String? role,
  }) {
    final roleStr = role ?? 'sin_rol';
    debugPrint('[$tag][$roleStr] $message');
  }
  static String roleName(Object? role) {
    if (role == null) return 'sin_rol';
    final value = role.toString();
    return value.contains('.') ? value.split('.').last : value;
  }
}
