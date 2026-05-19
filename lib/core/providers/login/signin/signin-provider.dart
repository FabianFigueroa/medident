import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medident/main_export.dart';

class SigninProvider with ChangeNotifier {
  final FirebaseServices _firebaseService;
  final String? initialEmail;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFormValid = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFormValid => _isFormValid;

  String? _lastUserEmail;
  String? get lastUserEmail => _lastUserEmail;
  String? _lastUserPhotoUrl;
  String? get lastUserPhotoUrl => _lastUserPhotoUrl;
  String? _lastUserName;
  String? get lastUserName => _lastUserName;

  SigninProvider(this._firebaseService, {this.initialEmail}) {
    loadLastUser();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    emailController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final bool isValid =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    if (_isFormValid != isValid) {
      _isFormValid = isValid;
      notifyListeners();
    }
  }

  Future<void> loadLastUser() async {
    if (initialEmail != null && initialEmail!.trim().isNotEmpty) {
      _lastUserEmail = null;
      _lastUserPhotoUrl = null;
      _lastUserName = null;
      emailController.text = initialEmail!.trim();
      passwordController.clear();
      _validateForm();
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _lastUserEmail = prefs.getString('last_user_email');
    _lastUserPhotoUrl = prefs.getString('last_user_photo_url');
    _lastUserName = prefs.getString('last_user_name');
    if (_lastUserEmail != null) {
      emailController.text = _lastUserEmail!;
    }
    _validateForm();
    notifyListeners();
  }

  Future<void> clearLastUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_user_email');
    await prefs.remove('last_user_photo_url');
    await prefs.remove('last_user_name');

    _lastUserEmail = null;
    _lastUserPhotoUrl = null;
    _lastUserName = null;
    emailController.clear();
    passwordController.clear();
    _validateForm();
    notifyListeners();
  }

  Future<void> setLastUser(
    String email,
    String? name,
    String? photoUrl, {
    bool notify = true,
  }) async {
    _lastUserEmail = email;
    _lastUserName = name;
    _lastUserPhotoUrl = photoUrl;
    emailController.text = email;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_user_email', email);
    if (name != null) await prefs.setString('last_user_name', name);
    if (photoUrl != null) {
      await prefs.setString('last_user_photo_url', photoUrl);
    }

    _validateForm();
    if (notify) {
      notifyListeners();
    }
  }

  /// Inicia sesión con correo y contraseña y devuelve true si es exitoso.
  Future<bool> signInWithEmailAndPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_isFormValid) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _firebaseService
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException(
                'La conexión ha tardado demasiado en responder.',
              );
            },
          );

      final user = userCredential.user;
      if (user != null) {
        // 1. Intentamos obtener los datos del usuario.
        UserModel? userModel = await _firebaseService.getUserData(user.uid);

        // 2. Si no existen (devuelve null), creamos un registro inicial.
        if (userModel == null) {
          userModel = await _firebaseService.createInitialUserData(user);
        }

        unawaited(
          _firebaseService
              .createInitialSecurityData(
                user.uid,
                dentistName: user.displayName,
                dentistEmail: user.email,
              )
              .catchError((error) {
                debugPrint(
                  'No se pudo preparar el documento de seguridad al iniciar sesion: $error',
                );
              }),
        );

        // We should *not* set the last user here. The quick login mechanism is for returning
        // to the login screen, not for the immediate post-login flow.
        // The AuthGate will handle the initial routing.
        // await setLastUser(user.email!, userModel.fullName, user.photoURL, notify: false);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "No se pudo verificar el usuario después del login.";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'No se encontró ningún usuario con ese correo.';
          break;
        case 'wrong-password':
          _errorMessage = 'La contraseña es incorrecta. Inténtalo de nuevo.';
          break;
        default:
          _errorMessage = 'Error de autenticación: ${e.message}';
      }
    } on PlatformException catch (e) {
      _errorMessage = 'Error de plataforma: ${e.message}. Revisa tu conexión.';
    } on TimeoutException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Ha ocurrido un error inesperado: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
      return "Se ha enviado un enlace de recuperación a tu correo.";
    } catch (e) {
      return e.toString();
    }
  }
}
