import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app-logger.dart';
import '../../enums/user-authgate.dart';
import '../../services/firebase/firebase-services.dart';
import '../../services/notification/notification-service.dart';
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
  bool _disposed = false;
  bool _fcmScheduled = false;

  /// Splash mínimo solo para evitar el destello blanco cuando el perfil viene
  /// de caché (patrón tenderos). No añade espera perceptible.
  static const Duration _minSplashDuration = Duration(milliseconds: 120);

  AuthGateProvider(this._firebaseService, this._authProvider) {
    if (!_isInitialized) {
      _isInitialized = true;
      _authProvider.addListener(_onAuthProviderChanged);
      checkAuthStatus();
    }
  }

  void completeOnboarding() {
    AppLogger.logWithRole(
      tag: 'AUTH_GATE_PROVIDER',
      role: 'guest',
      message: 'Onboarding completado. Cambiando estado a login sin crear otra ruta.',
    );
    _status = AuthGateStatus.unauthenticated;
    unawaited(_persistOnboardingCompleted());
    notifyListeners();
  }

  /// Si el perfil llega por el stream DESPUÉS del timeout (red lenta / sin
  /// caché), la compuerta avanza sola en cuanto aparece el usuario.
  void _onAuthProviderChanged() {
    if (_disposed) return;
    if ((_status == AuthGateStatus.loadingSplash ||
            _status == AuthGateStatus.uninitialized) &&
        _authProvider.user != null) {
      _setAuthenticated(_authProvider.user!.uid);
    }
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

    // Calienta la conexión Firestore mientras el usuario ve el splash. Es
    // best-effort y NO bloquea (no se hace await aquí).
    unawaited(_warmFirestore());

    await _authSubscription?.cancel();
    bool isFirstAuthEvent = true;

    _authSubscription = _firebaseService.authStateChanges.listen(
      (firebaseUser) async {
        if (_disposed) return;

        if (isFirstAuthEvent) {
          isFirstAuthEvent = false;
          await Future.delayed(_minSplashDuration);
          if (_disposed) return;
        }

        if (firebaseUser != null) {
          try {
            _errorMessage = null;
            AppLogger.logWithRole(
              tag: 'AUTH_GATE_PROVIDER',
              role: 'guest',
              message:
                  'Firebase entrego UID ${firebaseUser.uid}. Esperando perfil.',
            );
            await _authProvider.listenToUser(firebaseUser.uid);
          } catch (e) {
            // Error transitorio: NO se cierra sesión (patrón tenderos).
            debugPrint('Error al obtener el perfil del usuario: $e');
            _errorMessage = e.toString();
          }
          if (_disposed) return;
          if (_authProvider.user != null) {
            _setAuthenticated(firebaseUser.uid);
          } else {
            // Sin perfil todavía: el listener _onAuthProviderChanged avanzará
            // en cuanto el stream entregue el usuario.
            _status = AuthGateStatus.loadingSplash;
            notifyListeners();
          }
        } else {
          _errorMessage = null;
          final onboardCompleted = await _checkOnboardingStatus();
          if (_disposed) return;
          AppLogger.logWithRole(
            tag: 'AUTH_GATE_PROVIDER',
            role: 'guest',
            message:
                'Sin usuario Firebase. Onboarding completado: $onboardCompleted.',
          );
          _status = onboardCompleted
              ? AuthGateStatus.unauthenticated
              : AuthGateStatus.onboarding;
          notifyListeners();
        }
      },
    );
  }

  void _setAuthenticated(String uid) {
    if (_disposed) return;
    if (_status == AuthGateStatus.authenticated) return;
    _status = AuthGateStatus.authenticated;
    _errorMessage = null;
    _scheduleFcm(uid);
    notifyListeners();
  }

  /// Registro de FCM diferido 2.5 s: no compite con el primer frame del home
  /// (getToken + escritura del token en Firestore).
  void _scheduleFcm(String uid) {
    if (_fcmScheduled) return;
    _fcmScheduled = true;
    unawaited(Future<void>(() async {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (_disposed) return;
      try {
        await NotificationService.setUserId(uid);
      } catch (e) {
        debugPrint('FCM register error (best-effort): $e');
      }
    }));
  }

  /// Query mínima para abrir la conexión gRPC/TLS de Firestore durante el
  /// splash. Timeout corto para no alargar el arranque.
  Future<void> _warmFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('promotions')
          .limit(1)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      // best-effort: los streams del home reintentan por su cuenta.
    }
  }

  Future<bool> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(milliseconds: 1500));
      return prefs.getBool('onboard_completed') ?? false;
    } catch (_) {
      // En web un hot-restart puede no registrar el plugin; no bloquear.
      if (kIsWeb) return true;
      return false;
    }
  }

  Future<void> _persistOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(milliseconds: 1500));
      await prefs.setBool('onboard_completed', true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _disposed = true;
    _authProvider.removeListener(_onAuthProviderChanged);
    _authSubscription?.cancel();
    super.dispose();
  }
}
