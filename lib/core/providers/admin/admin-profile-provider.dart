import 'package:flutter/material.dart';
import 'package:medident/core/services/admin/admin-profile-service.dart';

class AdminProfileProvider with ChangeNotifier {
  final AdminProfileService _service;
  final String userId;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _profile = {};
  List<Map<String, dynamic>> _auditLog = [];

  AdminProfileProvider({required this.userId, AdminProfileService? service}) : _service = service ?? AdminProfileService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get profile => _profile;
  List<Map<String, dynamic>> get auditLog => _auditLog;

  Future<void> loadInitialData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([_service.getProfile(), _service.getAuditLog()]);
      _profile = results[0] as Map<String, dynamic>;
      _auditLog = results[1] as List<Map<String, dynamic>>;
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminProfileProvider.loadInitialData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _service.updateProfile(data);
    _profile.addAll(data);
    notifyListeners();
  }

  Future<void> refreshData() async {
    _error = null;
    notifyListeners();
    await loadInitialData();
  }
}
