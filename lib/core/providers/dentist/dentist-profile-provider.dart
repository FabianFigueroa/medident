import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/services/dentist/dentist-profile-service.dart';

/// Provider para la sección del perfil del dentista, conectado a Firebase.
class DentistProfileProvider with ChangeNotifier {
  final String userId;
  final DentistProfileService _dentistProfileService = DentistProfileService();

  UserModel? _userProfile;
  List<UserModel> _teamMembers = [];
  List<Map<String, dynamic>> _promotions = [];
  List<Map<String, dynamic>> _featuredPosts = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _galleryImages = [];
  bool _isFollowing = false;
  bool _isLoading = false;
  bool _initialDataReceived = false;
  String? _error;

  // Subscripciones a los streams de Firebase para datos en tiempo real.
  StreamSubscription? _profileSubscription;
  StreamSubscription? _teamSubscription;
  StreamSubscription? _promotionsSubscription;
  StreamSubscription? _featuredPostsSubscription;
  StreamSubscription? _servicesSubscription;
  StreamSubscription? _gallerySubscription;

  DentistProfileProvider({required this.userId});

  // Getters públicos
  UserModel? get userProfile => _userProfile;
  List<UserModel> get teamMembers => _teamMembers;
  List<Map<String, dynamic>> get promotions => _promotions;
  List<Map<String, dynamic>> get featuredPosts => _featuredPosts;
  List<Map<String, dynamic>> get services => _services;
  List<Map<String, dynamic>> get galleryImages => _galleryImages;
  bool get isFollowing => _isFollowing;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Alterna el estado de seguir/dejar de seguir
  void toggleFollow() {
    _isFollowing = !_isFollowing;
    notifyListeners();
  }

  /// Inicializa la carga de datos desde Firebase mediante streams.
  Future<void> initialize() async {
    if (_initialDataReceived) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Suscribirse a todos los streams para obtener datos iniciales y actualizaciones
      _profileSubscription?.cancel();
      _profileSubscription = _dentistProfileService.streamUserProfile(userId).listen((profile) {
        _userProfile = profile;
        _markInitialDataReceived();
      }, onError: (e) {
        _error = "Error en el stream del perfil: $e";
        _isLoading = false;
        notifyListeners();
      });

      _teamSubscription?.cancel();
      _teamSubscription = _dentistProfileService.streamTeamMembers(userId).listen((team) {
        _teamMembers = team;
        _markInitialDataReceived();
      }, onError: (e) {
        _error = "Error en el stream del equipo: $e";
        _isLoading = false;
        notifyListeners();
      });

      _promotionsSubscription?.cancel();
      _promotionsSubscription = _dentistProfileService.streamPromotions(userId).listen((promotions) {
        _promotions = promotions;
        _markInitialDataReceived();
      }, onError: (e) {
        _error = "Error en el stream de promociones: $e";
        _isLoading = false;
        notifyListeners();
      });

      _featuredPostsSubscription?.cancel();
      _featuredPostsSubscription = _dentistProfileService.streamFeaturedPosts(userId).listen((featuredPosts) {
        _featuredPosts = featuredPosts;
        _markInitialDataReceived();
      }, onError: (e) {
        _error = "Error en el stream de posts destacados: $e";
        _isLoading = false;
        notifyListeners();
      });

      _servicesSubscription?.cancel();
      _servicesSubscription = _dentistProfileService.streamServices(userId).listen((services) {
        _services = services;
        _markInitialDataReceived();
      }, onError: (e) {
        debugPrint('Error en el stream de servicios: $e');
        _markInitialDataReceived();
      });

      _gallerySubscription?.cancel();
      _gallerySubscription = _dentistProfileService.streamGallery(userId).listen((gallery) {
        _galleryImages = gallery;
        _markInitialDataReceived();
      }, onError: (e) {
        debugPrint('Error en el stream de galería: $e');
        _markInitialDataReceived();
      });
    } catch (e) {
      _error = 'Error al inicializar suscripciones: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marca que se recibieron datos iniciales y sale de loading.
  void _markInitialDataReceived() {
    if (!_initialDataReceived && _userProfile != null) {
      _initialDataReceived = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recarga datos sin reiniciar streams
  Future<void> refreshProfile() async {
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _dentistProfileService.getUserProfile(userId),
        _dentistProfileService.getPromotions(userId),
        _dentistProfileService.getFeaturedPosts(userId),
      ]);

      final userResult = results[0] as UserModel?;
      if (userResult != null) {
        _userProfile = userResult;
      }
      _promotions = results[1] as List<Map<String, dynamic>>;
      _featuredPosts = results[2] as List<Map<String, dynamic>>;

      notifyListeners();
    } catch (e) {
      _error = 'Error al refrescar datos: $e';
      notifyListeners();
    }
  }

  /// Limpia los recursos cuando el provider ya no se necesita.
  @override
  void dispose() {
    _profileSubscription?.cancel();
    _teamSubscription?.cancel();
    _promotionsSubscription?.cancel();
    _featuredPostsSubscription?.cancel();
    _servicesSubscription?.cancel();
    _gallerySubscription?.cancel();
    super.dispose();
  }
}