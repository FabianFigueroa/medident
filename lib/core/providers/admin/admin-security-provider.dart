import 'package:flutter/material.dart';
import 'package:medident/core/services/admin/admin-security-service.dart';

class AdminSecurityProvider with ChangeNotifier {
  final AdminSecurityService _service;
  final String userId;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _securityOverview = {};
  List<Map<String, dynamic>> _recentAlerts = [];
  List<Map<String, dynamic>> _accessLogs = [];

  AdminSecurityProvider({
    required this.userId,
    AdminSecurityService? service,
  }) : _service = service ?? AdminSecurityService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get securityOverview => _securityOverview;
  List<Map<String, dynamic>> get recentAlerts => _recentAlerts;
  List<Map<String, dynamic>> get accessLogs => _accessLogs;

  Future<void> loadInitialData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getSecurityOverview(),
        _service.getRecentAlerts(),
        _service.getAccessLogs(),
      ]);

      _securityOverview = results[0] as Map<String, dynamic>;
      _recentAlerts = results[1] as List<Map<String, dynamic>>;
      _accessLogs = results[2] as List<Map<String, dynamic>>;
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminSecurityProvider.loadInitialData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    _error = null;
    notifyListeners();
    await loadInitialData();
  }
}
