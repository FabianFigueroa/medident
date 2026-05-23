import 'package:flutter/material.dart';
import 'package:medident/core/services/patient/patient-profile-service.dart';

class PatientProfileProvider with ChangeNotifier {
  final PatientProfileService _service;
  final String userId;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userProfile;

  PatientProfileProvider({
    required this.userId,
    PatientProfileService? service,
  }) : _service = service ?? PatientProfileService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userProfile => _userProfile;

  Future<void> initialize() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userProfile = await _service.getProfile(userId);
      if (_userProfile == null || _userProfile!.isEmpty) {
        _error = 'Perfil no encontrado';
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('PatientProfileProvider.initialize error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
