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
  List<Map<String, dynamic>> _promotions = []; // Lista de promociones
  List<Map<String, dynamic>> _featuredPosts = []; // Nuevo: Lista de posts destacados
  
  bool _isLoading = true; // Empezamos en loading hasta que tengamos datos iniciales
  String? _error;

  // Subscripciones a los streams de Firebase para datos en tiempo real.
  StreamSubscription? _profileSubscription;
  StreamSubscription? _teamSubscription;
  StreamSubscription? _promotionsSubscription; // Suscripción a promociones
  StreamSubscription? _featuredPostsSubscription; // Nuevo: Suscripción a posts destacados

  DentistProfileProvider({required this.userId});

  // Getters públicos para que la UI acceda a los datos y estados.
  UserModel? get userProfile => _userProfile;
  List<UserModel> get teamMembers => _teamMembers;
  List<Map<String, dynamic>> get promotions => _promotions; // Getter para promociones
  List<Map<String, dynamic>> get featuredPosts => _featuredPosts; // Nuevo: Getter para posts destacados
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Inicializa la carga de datos desde Firebase.
  Future<void> initialize() async {
    if (_isLoading == false) return; // Ya inicializado
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Escucha los cambios en el perfil del usuario.
      _profileSubscription?.cancel();
      _profileSubscription = _dentistProfileService.streamUserProfile(userId).listen((profile) {
        _userProfile = profile;
        // Verificamos si ya tenemos todos los datos iniciales para salir del loading state
        _checkIfInitialDataComplete();
      }, onError: (e) {
        _error = "Error en el stream del perfil: $e";
        _isLoading = false;
        notifyListeners();
      });

      // Escucha los cambios en el equipo.
      _teamSubscription?.cancel();
      _teamSubscription = _dentistProfileService.streamTeamMembers(userId).listen((team) {
        _teamMembers = team;
        _checkIfInitialDataComplete();
      }, onError: (e) {
        _error = "Error en el stream del equipo: $e";
        _isLoading = false;
        notifyListeners();
      });

      // Nuevo: Escucha los cambios en las promociones del usuario.
      _promotionsSubscription?.cancel();
      _promotionsSubscription = _dentistProfileService.streamPromotions(userId).listen((promotions) {
        _promotions = promotions;
        _checkIfInitialDataComplete();
      }, onError: (e) {
        _error = "Error en el stream de promociones: $e";
        _isLoading = false;
        notifyListeners();
      });

      // Nuevo: Escucha los cambios en los posts destacados del usuario.
      _featuredPostsSubscription?.cancel();
      _featuredPostsSubscription = _dentistProfileService.streamFeaturedPosts(userId).listen((featuredPosts) {
        _featuredPosts = featuredPosts;
        _checkIfInitialDataComplete();
      }, onError: (e) {
        _error = "Error en el stream de posts destacados: $e";
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Error al inicializar suscripciones: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifica si hemos recibido datos iniciales de todas las fuentes para salir del estado de loading.
  void _checkIfInitialDataComplete() {
    // Consideramos que tenemos datos iniciales cuando:
    // 1. Tenemos el perfil del usuario (esencial)
    // 2. Hemos recibido al menos una emisión de cada stream (aunque sea lista vacía)
    if (_userProfile != null) {
      // En este punto, asumimos que si el perfil llegó, los otros streams también han emitido al menos una vez
      // Esto es porque Firebase streams emiten el valor inmediato al suscribirse
      _isLoading = false;
      notifyListeners();
    }
    // Nota: Si el perfil nunca llega, el onError del perfil subscription nos encargará de marcar error y salir de loading
  }

  /// Recarga datos sin reiniciar streams (útil para pull-to-refresh)
  Future<void> refreshProfile() async {
    // Para refresh, forzamos una nueva emisión de los streams
    // En Firebase, podemos hacer esto volviendo a suscribirnos o usando otras técnicas
    // Pero lo más simple es: si ya estamos suscrito, confiamos en que los streams eventualmente emitirán
    // Para un refresh inmediato, podríamos hacer un get() una vez, pero manteneremos los streams para updates
    
    // Como alternativa segura: hacemos get() una vez para refresh inmediato, pero mantenemos streams para updates en tiempo real
    _error = null;
    notifyListeners(); // Mostramos estado de refresh
    
    try {
      // Intentamos obtener datos frescos una vez para refresh inmediato
      final results = await Future.wait([
        _dentistProfileService.getUserProfile(userId),
        _dentistProfileService.getPromotions(userId),
        _dentistProfileService.getFeaturedPosts(userId),
      ]);
      
      // Actualizamos con los datos frescos
      _userProfile = results[0] as UserModel?;
      _promotions = results[1] as List<Map<String, dynamic>>;
      _featuredPosts = results[2] as List<Map<String, dynamic>>;
      
      // Los teamMembers son más difíciles de refresh sin suscribirse, así que dejamos que el stream los actualice
      // o podríamos hacer getTeamMembers() si existe en el service
      
      if (_userProfile != null) {
        _error = null; // Limpiamos cualquier error previo si logramos obtener el perfil
      }
    } catch (e) {
      _error = 'Error al refrescar datos: $e';
    } finally {
      notifyListeners(); // Ocultamos estado de refresh y mostramos nuevos datos o error
    }
  }

  /// Limpia los recursos (subscripciones) cuando el provider ya no se necesita.
  @override
  void dispose() {
    _profileSubscription?.cancel();
    _teamSubscription?.cancel();
    _promotionsSubscription?.cancel();
    _featuredPostsSubscription?.cancel();
    super.dispose();
  }
}