import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medident/core/models/user-model.dart';

class UserCacheService {
  static const String _prefix = 'user_cache_';

  static Future<void> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix${user.uid}', jsonEncode(user.toMap()));
    } catch (_) {}
  }

  static Future<UserModel?> loadUser(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$uid');
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromMap(json, uid);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUser(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$uid');
    } catch (_) {}
  }

  static Future<bool> hasCache(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('$_prefix$uid');
    } catch (_) {
      return false;
    }
  }
}
