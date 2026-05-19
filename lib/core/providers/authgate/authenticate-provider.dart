import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/auth/authgate.dart';
import 'package:medident/core/enums/user-gender.dart';
import 'package:medident/core/models/roles/user_role.dart';
import 'package:medident/core/services/notification/notification-service.dart';
import '../../models/user-model.dart';
import '../../services/firebase/firebase-services.dart';
import '../../utils/app-logger.dart';

class AuthenticateProvider with ChangeNotifier {
  final FirebaseServices _firebaseService;
  StreamSubscription<UserModel?>? _userSubscription;
  Completer<void>? _userCompleter;
  String? _listeningUid;
  UserModel? _user;
  UserModel? get user => _user;

  AuthenticateProvider(this._firebaseService);

  bool shouldListenTo(String uid) => _listeningUid != uid && _user?.uid != uid;

  Future<void> listenToUser(String uid) {
    if (_listeningUid == uid) {
      if (_user?.uid == uid) {
        AppLogger.logWithRole(
          tag: 'AUTH_PROVIDER',
          role: AppLogger.roleName(_user?.role),
          message:
              'Perfil para UID $uid ya estaba cargado. Reutilizando estado.',
        );
        return Future.value();
      }
      final pendingFuture = _userCompleter?.future;
      if (pendingFuture != null) {
        AppLogger.logWithRole(
          tag: 'AUTH_PROVIDER',
          role: 'guest',
          message:
              'Ya existe una escucha activa para UID $uid. Reutilizando espera.',
        );
        return pendingFuture;
      }
    }

    final completer = Completer<void>();
    _userCompleter = completer;
    _listeningUid = uid;
    _userSubscription?.cancel();
    _userSubscription = _firebaseService
        .userStream(uid)
        .listen(
          (newUser) {
            _user = newUser;
            if (newUser == null) {
              AppLogger.logWithRole(
                tag: 'AUTH_PROVIDER',
                role: 'guest',
                message:
                    'Firestore aun no devuelve perfil para UID $uid. Manteniendo splash de autenticacion.',
              );
            } else {
              AppLogger.logWithRole(
                tag: 'AUTH_PROVIDER',
                role: AppLogger.roleName(newUser.role),
                message: 'Perfil recibido para UID $uid.',
              );
              NotificationService.setUserId(uid);
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
            _user = null;
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
            if (_userCompleter == completer) {
              _userCompleter = null;
            }
            signOut();
          },
        );
    return completer.future;
  }

  Future<void> _stopListeningToUser() async {
    await _userSubscription?.cancel();
    _userSubscription = null;
    _userCompleter = null;
    _listeningUid = null;
    _user = null;
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
    await _stopListeningToUser();
    notifyListeners();
  }

  @override
  void dispose() {
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
