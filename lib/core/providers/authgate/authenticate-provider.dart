import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/auth/authgate.dart';
import 'package:medident/core/enums/user-gender.dart';
import 'package:medident/core/models/roles/user_role.dart';
import 'package:medident/core/services/cache/user-cache-service.dart';
import '../../models/user-model.dart';
import '../../services/firebase/firebase-services.dart';
import '../../utils/app-logger.dart';

class AuthenticateProvider with ChangeNotifier {
  final FirebaseServices _firebaseService;
  StreamSubscription<UserModel?>? _userSubscription;
  Completer<void>? _userCompleter;
  String? _listeningUid;
  UserModel? _user;
  bool _disposed = false;
  UserModel? get user => _user;

  AuthenticateProvider(this._firebaseService);

  bool shouldListenTo(String uid) => _listeningUid != uid && _user?.uid != uid;

  /// Arranque rápido (patrón tenderos): si el perfil está cacheado (memoria o
  /// SharedPreferences) se aplica de inmediato y el home puede pintarse sin
  /// esperar al handshake de Firestore. El stream sigue vivo y refresca detrás.
  Future<void> listenToUser(String uid) async {
    if (_listeningUid == uid) {
      if (_user?.uid == uid) {
        AppLogger.logWithRole(
          tag: 'AUTH_PROVIDER',
          role: AppLogger.roleName(_user?.role),
          message: 'Perfil para UID $uid ya estaba cargado. Reutilizando estado.',
        );
        return Future.value();
      }
      final pendingFuture = _userCompleter?.future;
      if (pendingFuture != null) {
        AppLogger.logWithRole(
          tag: 'AUTH_PROVIDER',
          role: 'guest',
          message: 'Ya existe una escucha activa para UID $uid. Reutilizando espera.',
        );
        return pendingFuture;
      }
    }

    final completer = Completer<void>();
    _userCompleter = completer;
    _listeningUid = uid;
    await _userSubscription?.cancel();

    // 1) Fast path: perfil local, sin red.
    final cachedUser = await UserCacheService.loadUser(uid);
    if (cachedUser != null && _listeningUid == uid && !_disposed) {
      _user = cachedUser;
      AppLogger.logWithRole(
        tag: 'AUTH_PROVIDER',
        role: AppLogger.roleName(cachedUser.role),
        message: 'Perfil de caché aplicado para UID $uid (home instantáneo).',
      );
      notifyListeners();
    }

    // 2) Stream en vivo (cache-first de Firestore → red).
    _listenUserStream(uid, completer);

    if (cachedUser != null) {
      // Con caché no esperamos la red: máximo 150 ms para el primer snapshot.
      return completer.future.timeout(
        const Duration(milliseconds: 150),
        onTimeout: () {
          debugPrint('[Auth] listenToUser con caché — sigue con perfil local');
        },
      );
    }
    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        debugPrint('[Auth] listenToUser sin caché — timeout, sigo con el stream');
      },
    );
  }

  void _listenUserStream(String uid, Completer<void> completer) {
    _userSubscription = _firebaseService.userStream(uid).listen(
      (newUser) {
        if (uid != _listeningUid || _disposed) return;
        _user = newUser;
        if (newUser == null) {
          AppLogger.logWithRole(
            tag: 'AUTH_PROVIDER',
            role: 'guest',
            message: 'Firestore aun no devuelve perfil para UID $uid.',
          );
        } else {
          AppLogger.logWithRole(
            tag: 'AUTH_PROVIDER',
            role: AppLogger.roleName(newUser.role),
            message: 'Perfil recibido para UID $uid.',
          );
          // Guardamos para el próximo arranque instantáneo.
          unawaited(UserCacheService.saveUser(newUser));
          if (!completer.isCompleted) {
            completer.complete();
          }
          if (_userCompleter == completer) {
            _userCompleter = null;
          }
        }
        notifyListeners();
      },
      onError: (error) {
        debugPrint('..................Error en el stream de usuario: $error');
        if (uid != _listeningUid || _disposed) return;
        // NO se cierra sesión por un error transitorio (red/índice): se
        // conserva la sesión y se reintenta la suscripción.
        if (!completer.isCompleted) {
          completer.complete();
        }
        if (_userCompleter == completer) {
          _userCompleter = null;
        }
        _retryUserStream(uid, completer);
      },
    );
  }

  Future<void> _retryUserStream(String uid, Completer<void> completer) async {
    await Future.delayed(const Duration(seconds: 2));
    if (uid != _listeningUid || _disposed) return;
    _listenUserStream(uid, completer);
  }

  Future<void> _stopListeningToUser() async {
    await _userSubscription?.cancel();
    _userSubscription = null;
    _userCompleter = null;
    _listeningUid = null;
    _user = null;
  }

  Future<void> signOut() async {
    final uid = _user?.uid;
    await _firebaseService.signOut();
    if (uid != null) {
      await UserCacheService.clearUser(uid);
    }
    await _stopListeningToUser();
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _userSubscription?.cancel();
    super.dispose();
  }

  // Usuario demo para desarrollo
  Future<void> setDemoUser() async {
    _user = UserModel(
      uid: 'user_dentist_1',
      email: 'dentista1@test.com',
      fullName: 'Dra. Ana García',
      userName: 'anagarcia',
      imageUrl: '',
      role: UserRole.dentist,
      gender: UserGender.femenino,
      isActive: true,
      followersCount: 150,
      followingCount: 45,
      servicesCount: 12,
    );
    notifyListeners();
  }
}
