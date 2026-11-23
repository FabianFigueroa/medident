import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:medident/firebase_options.dart';

/// Inicializador profesional de la aplicación
/// Maneja timeouts, reintentos y errores graceful
class AppInitializer {
  static const _timeout = Duration(seconds: 15);
  static const _maxRetries = 2;
  
  /// Inicializa Firebase con reintentos y timeout
  static Future<FirebaseApp> initializeFirebaseWithRetry() async {
    Exception? lastError;
    
    debugPrint('🚀 Iniciando inicialización de Firebase...');
    debugPrint('⏱️ Timeout: ${_timeout.inSeconds}s, Max reintentos: $_maxRetries');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      debugPrint('🔄 Intento $attempt/$_maxRetries...');
      try {
        final app = await _initializeFirebaseWithTimeout();
        debugPrint('✅ Firebase inicializado correctamente (intento $attempt)');
        return app;
      } on TimeoutException catch (e) {
        lastError = e;
         debugPrint('⏰ Timeout inicializando Firebase (intento $attempt/$_maxRetries)');
        if (attempt == _maxRetries) rethrow;
        await Future.delayed(Duration(seconds: attempt * 3));
      } on FirebaseException catch (e) {
        lastError = e;
        debugPrint('🔥 FirebaseException (intento $attempt/$_maxRetries): ${e.message}');
        debugPrint('   Código: ${e.code}');
        if (attempt == _maxRetries) rethrow;
        await Future.delayed(Duration(seconds: attempt * 2));
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint('❌ Error genérico (intento $attempt/$_maxRetries): $e');
        if (attempt == _maxRetries) rethrow;
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    throw lastError ?? Exception('No se pudo inicializar Firebase después de $_maxRetries intentos');
  }
  
  static Future<FirebaseApp> _initializeFirebaseWithTimeout() async {
    // En Android el plugin nativo ya inicializa la app [DEFAULT] a partir de
    // google-services.json antes de que corra Dart. Volver a llamar
    // initializeApp lanza 'duplicate-app' y la app se quedaba en el splash.
    if (Firebase.apps.isNotEmpty) {
      debugPrint('✅ Firebase ya estaba inicializado por la plataforma');
      return Firebase.app();
    }
    debugPrint('📡 Llamando Firebase.initializeApp()...');
    try {
      return await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(_timeout, onTimeout: () {
        debugPrint('⛔ TIMEOUT: Firebase no respondió después de ${_timeout.inSeconds} segundos');
        throw TimeoutException('Firebase no respondió después de ${_timeout.inSeconds} segundos');
      });
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') return Firebase.app();
      rethrow;
    }
  }

  /// Configura la persistencia según plataforma y, si la app se compiló con
  /// --dart-define=USE_FIREBASE_EMULATOR=true, la conecta al Emulator Suite.
  static Future<void> configurePersistence(FirebaseApp app) async {
    if (EmulatorConfig.enabled) {
      final host = EmulatorConfig.host;
      // Sin mapeo automático a 10.0.2.2: en un celular físico los puertos
      // llegan por `adb reverse` a 127.0.0.1 del propio teléfono.
      await FirebaseAuth.instanceFor(app: app)
          .useAuthEmulator(host, 9099, automaticHostMapping: false);
      FirebaseFirestore.instanceFor(app: app)
          .useFirestoreEmulator(host, 8080, automaticHostMapping: false);
      await FirebaseStorage.instanceFor(app: app)
          .useStorageEmulator(host, 9199, automaticHostMapping: false);
      debugPrint('🧪 Firebase conectado a los emuladores locales ($host)');
    }
    if (kIsWeb) {
      await FirebaseAuth.instanceFor(app: app).setPersistence(Persistence.LOCAL);
      debugPrint('🌐 Persistencia LOCAL configurada para Web');
    } else {
      debugPrint('📱 Persistencia por defecto para móvil/desktop');
    }
  }
}

/// Bandera de compilación para ejecutar las pruebas contra Firebase Emulator Suite.
/// La versión que se entrega se compila sin ella y usa el Firebase real.
class EmulatorConfig {
  static const bool enabled = bool.fromEnvironment('USE_FIREBASE_EMULATOR');
  static const String host =
      String.fromEnvironment('FIREBASE_EMULATOR_HOST', defaultValue: '127.0.0.1');
}
