import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
    debugPrint('📡 Llamando Firebase.initializeApp()...');
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(_timeout, onTimeout: () {
      debugPrint('⛔ TIMEOUT: Firebase no respondió después de ${_timeout.inSeconds} segundos');
      throw TimeoutException('Firebase no respondió después de ${_timeout.inSeconds} segundos');
    });
  }
  
  /// Configura la persistencia según plataforma
  static Future<void> configurePersistence(FirebaseApp app) async {
    if (kIsWeb) {
      await FirebaseAuth.instanceFor(app: app).setPersistence(Persistence.LOCAL);
      debugPrint('🌐 Persistencia LOCAL configurada para Web');
    } else {
      debugPrint('📱 Persistencia por defecto para móvil/desktop');
    }
  }
}
