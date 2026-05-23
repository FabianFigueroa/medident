import 'package:flutter/material.dart';
import 'package:medident/core/services/doctor/doctor-profile-service.dart';

class DoctorProfileProvider with ChangeNotifier {
  final DoctorProfileService _service;
  final String userId;

  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;

  DoctorProfileProvider({
    required DoctorProfileService service,
    required this.userId,
  }) : _service = service;

  Map<String, dynamic>? get userProfile => _userProfile;
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
