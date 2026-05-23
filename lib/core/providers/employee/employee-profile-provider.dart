import 'package:flutter/material.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/services/employee/employee-profile-service.dart';

class EmployeeProfileProvider with ChangeNotifier {
  final EmployeeProfileService _service;
  final String userId;

  UserModel? _userProfile;
  bool _isLoading = false;
  String? _error;

  EmployeeProfileProvider({
    required this.userId,
    EmployeeProfileService? service,
  }) : _service = service ?? EmployeeProfileService();

  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userProfile = await _service.getProfile(userId);
    } catch (e) {
      _error = e.toString();
      debugPrint('EmployeeProfileProvider.initialize error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
