import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:medident/core/auth/authgate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app-logger.dart';
import '../../enums/user-authgate.dart';
import '../../services/firebase/firebase-services.dart';
import 'authenticate-provider.dart';

class AuthGateProvider with ChangeNotifier {
  final FirebaseServices _firebaseService;
  final AuthenticateProvider _authProvider;

  AuthGateStatus _status = AuthGateStatus.uninitialized;
  AuthGateStatus get status => _status;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  StreamSubscription<User?>? _authSubscription;
  bool _isInitialized = false;
  bool _isProcessingAuth = false;
  bool _disposed = false;

  AuthGateProvider(this._firebaseService, this._authProvider) {
    if (!_isInitialized) {
      _isInitialized = true;
      checkAuthStatus();
    }
  }

  void completeOnboarding() {
    AppLogger.logWithRole(
      tag: 'AUTH_GATE_PROVIDER',
      role: 'guest',
      message:
          'Onboarding completado. Cambiando estado a login sin crear otra ruta.',
    );
    _status = AuthGateStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _status = AuthGateStatus.loadingSplash;
    _errorMessage = null;
    AppLogger.logWithRole(
      tag: 'AUTH_GATE_PROVIDER',
      role: 'guest',
      message: 'Inicializando compuerta de autenticacion.',
    );
    notifyListeners();

    // Escuchar auth de inmediato evita esperas fijas despues del login.
    _authSubscription = _firebaseService.authStateChanges.listen((
      firebaseUser,
    ) async {
      if (_isProcessingAuth) return;
      _isProcessingAuth = true;
      if (firebaseUser != null) {
        try {
          _errorMessage = null;
          AppLogger.logWithRole(
            tag: 'AUTH_GATE_PROVIDER',
            role: 'guest',
            message:
                'Firebase entrego UID ${firebaseUser.uid}. Esperando perfil de Firestore.',
          );
          await _authProvider
              .listenToUser(firebaseUser.uid)
              .timeout(
                const Duration(seconds: 12),
                onTimeout: () {
                  throw TimeoutException(
                    'Firestore no entrego el perfil del usuario a tiempo.',
                  );
                },
              );
          if (_authProvider.user == null) {
            throw StateError(
              'Firebase autentico el usuario, pero Firestore devolvio perfil null.',
            );
          }
          AppLogger.logWithRole(
            tag: 'AUTH_GATE_PROVIDER',
            role: AppLogger.roleName(_authProvider.user?.role),
            message: 'Perfil cargado correctamente. Estado authenticated.',
          );
          _status = AuthGateStatus.authenticated;
          _isProcessingAuth = false;
          if (!_disposed) notifyListeners();
        } catch (e) {
          if (kDebugMode) {
            debugPrint("Error al obtener el perfil del usuario, deslogueando: $e");
          }
          _isProcessingAuth = false;
          _errorMessage = e.toString();
          await _firebaseService.signOut();
          _status = AuthGateStatus.unauthenticated;
        }
      } else {
        _errorMessage = null;
        
        // BYPASS TEMPORAL PARA DESARROLLO -可以直接跳过 onboarding
        // TODO: Quitar esto en producción
        final debugBypass = false; // Cambiar a false para producción
        
        if (debugBypass) {
          // Crear usuario demo para desarrollo
          await _authProvider.setDemoUser();
          _status = AuthGateStatus.authenticated;
          AppLogger.logWithRole(
            tag: 'AUTH_GATE_PROVIDER',
            role: 'guest',
            message: '🔓 BYPASS: Usuario demo configurado',
          );
          if (!_disposed) notifyListeners();
          return;
        }
        
        final onboardCompleted = await _checkOnboardingStatus();
        AppLogger.logWithRole(
          tag: 'AUTH_GATE_PROVIDER',
          role: 'guest',
          message:
              'Sin usuario Firebase. Onboarding completado: $onboardCompleted.',
        );
        _status = onboardCompleted
            ? AuthGateStatus.unauthenticated
            : AuthGateStatus.onboarding;
        _isProcessingAuth = false;
      }
      if (!_disposed) notifyListeners();
    });
  }

   Future<bool> _checkOnboardingStatus() async {
     final prefs = await SharedPreferences.getInstance();
     return prefs.getBool('onboard_completed') ?? false;
   }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}
