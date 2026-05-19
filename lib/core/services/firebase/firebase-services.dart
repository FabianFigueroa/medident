import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/main_export.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseFirestore _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseServices() {
    // ✅ CORREGIDO: Habilitar persistencia para todas las plataformas
    _firestore = FirebaseFirestore.instance;
    
    // Configuración específica por plataforma
    if (kIsWeb) {
      // ⚠️ Web: persistencia local (evita múltiples conexiones)
      _firestore.settings = const Settings(
        persistenceEnabled: true,  // ✅ CAMBIADO a true
      );
    } else {
      // Móvil/Desktop: persistencia en disco
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  }

  // ✅ NUEVO: Getter para firestore (lazy loading seguro)
  FirebaseFirestore get firestore => _firestore;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  CollectionReference<Map<String, dynamic>> get _usersCollection => _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _securityCollection => _firestore.collection('security');
  
   // Placeholder para evitar errores de referencia

   Stream<UserModel?> userStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data()!, uid);
      }
      return null;
    });
  }

  //////////////////////////////////////////////////////////////////////// Método de login con email y password 
  Future<UserCredential> createUserWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  try {
    if (kDebugMode) {
      debugPrint('FIREBASE_SERVICE: Intentando crear usuario con email: $email');
    }
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (kDebugMode) {
      debugPrint('FIREBASE_SERVICE: Creación de usuario exitosa para UID: ${userCredential.user?.uid}');
    }
    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (kDebugMode) {
      debugPrint('!!!!!!!!!!!!!! ERROR DE FIREBASE AUTH !!!!!!!!!!!!!!');
      debugPrint('FIREBASE_SERVICE: Codigo de error: ${e.code}');
      debugPrint('FIREBASE_SERVICE: Mensaje de error: ${e.message}');
      debugPrint('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    }
    rethrow;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('!!!!!!!!!!!!!! ERROR DESCONOCIDO EN REGISTRO !!!!!!!!!!!!!!');
      debugPrint('FIREBASE_SERVICE: Ocurrio un error inesperado: $e');
      debugPrint('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    }
    rethrow;
  }
}
  ///////////////////////////////////////////////////////////////////////
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('FIREBASE_SERVICE: Intentando iniciar sesion con email: $email');
      }
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        debugPrint('FIREBASE_SERVICE: Inicio de sesion exitoso para UID: ${userCredential.user?.uid}');
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('!!!!!!!!!!!!!! ERROR DE FIREBASE AUTH !!!!!!!!!!!!!!');
        debugPrint('FIREBASE_SERVICE: Codigo de error: ${e.code}');
        debugPrint('FIREBASE_SERVICE: Mensaje de error: ${e.message}');
        debugPrint('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('!!!!!!!!!!!!!! ERROR DESCONOCIDO EN LOGIN !!!!!!!!!!!!!!');
        debugPrint('FIREBASE_SERVICE: Ocurrio un error inesperado: $e');
        debugPrint('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      }
      rethrow;
    }
  }

  ///////////////////////////////////////////////////////////////////////
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid );
      }
      return null;
    } on FirebaseException catch (e) {
      debugPrint('Error de Firestore al obtener datos del usuario: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error inesperado en getUserData: $e');
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////// send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
   /////////////////////////////////////////////////////////////////////// Crear datos iniciales de usuario en Firestore después del registro
  Future<UserModel> createInitialUserData(User firebaseUser, {UserRole role = UserRole.patient}) async {
    final displayName =
        firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'Usuario';

    final newUser = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      fullName: displayName,
      role: role,
      phoneNumber: '',
      imageUrl: firebaseUser.photoURL ?? '',
    );

    await _usersCollection.doc(newUser.uid).set(newUser.toMap());

    // ── Escribir también en la colección del role ──
    final roleCollection = _firestore.collection('${role.name}s');
    final roleData = <String, dynamic>{
      'fullName': displayName,
      'email': firebaseUser.email!,
      'phoneNumber': '',
      'imageUrl': firebaseUser.photoURL ?? '',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (role == UserRole.dentist) {
      roleData['specialty'] = '';
      roleData['licenseNumber'] = '';
      roleData['yearsOfExperience'] = 0;
    } else if (role == UserRole.patient) {
      roleData['bloodType'] = null;
      roleData['allergies'] = [];
      roleData['medications'] = [];
    } else if (role == UserRole.admin) {
      roleData['permissions'] = ['dashboard', 'users', 'promotions'];
    }
    await roleCollection.doc(newUser.uid).set(roleData);

    return newUser;
  }

  /////////////////////////////////////////////////////////////////////// Crear datos iniciales de seguridad en Firestore
  Future<void> createInitialSecurityData(String userId, {String? dentistName, String? dentistEmail}) async {
    final securityDocRef = _securityCollection.doc(userId);
    final doc = await securityDocRef.get();
    if (!doc.exists) {
      await securityDocRef.set({
        'userId': userId,
        'dentistName': dentistName ?? '',
        'dentistEmail': dentistEmail ?? '',
        'contract-status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'contractStartDate': null, // Se establecerá al aceptar el contrato
        'contractEndDate': null,
        'lastActivityDate': null,
        'totalSensors': 0,
        'totalCards': 0,
        'cards': [],
        'sensors': [],
      });
      debugPrint('FIREBASE_SERVICE: Documento de seguridad inicial creado para $userId');
    } else {
      debugPrint('FIREBASE_SERVICE: Documento de seguridad para $userId ya existe, no se creó.');
    }
  }
  
  /////////////////////////////////////////////////////////////////////// Subir imagen a Firebase Storage
   Future<String> uploadImage(Uint8List imageBytes, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  ////////////////////////////////////////////////////////////////////////// Método para limpiar caché (útil para web)
  Future<void> clearPersistence() async {
    if (kIsWeb) {
      try {
        await _firestore.clearPersistence();
        debugPrint('FirebaseService: Persistencia limpiada');
      } catch (e) {
        debugPrint('FirebaseService: Error limpiando persistencia: $e');
      }
    }
  }

  //////////////////////////////////////////////////////////// sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  ////////////////////////////////////////////////////////////////////////////////// 
  ///                      Metodos para las tarjetas RFiD
  /// ////////////////////////////////////////////////////////////////////////////// 
  Future<List<String>> getFreeCardCodesForStore(String storeNit) async {
    try {
      final docRef = _firestore.collection('stores').doc(storeNit);
      final doc = await docRef.get();
      if (doc.exists && doc.data() != null) {
        final cardsData = doc.data()!['cards'] as List<dynamic>? ?? [];
        final freeCards = cardsData
            .where((card) => card is Map && !(card['isAssigned'] ?? false))
            .map((card) => card['code'].toString())
            .toList();
        return freeCards;
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener tarjetas libres para NIT $storeNit: $e');
      return [];
    }
  }

  ////////////////////////////////////////////////////////////////////////////////// Asignar una tarjeta a un empleado y marcarla como asignada en la tienda
  Future<void> assignCardToEmployee({
    required String storeNit,
    required String employeeUid,
    required String cardCode,
  }) async {
    final storeDocRef = _firestore.collection('stores').doc(storeNit);
    final userDocRef = _usersCollection.doc(employeeUid);
    await _firestore.runTransaction((transaction) async {
      final storeDoc = await transaction.get(storeDocRef);
      if (!storeDoc.exists) {
        throw Exception('Tienda con NIT $storeNit no encontrada para asignar tarjeta.');
      }
      final cardsData = List<Map<String, dynamic>>.from(storeDoc.data()?['cards'] ?? []);
      final cardIndex = cardsData.indexWhere((card) => card['code'] == cardCode);
      if (cardIndex == -1 || cardsData[cardIndex]['isAssigned'] == true) {
        throw Exception('Tarjeta con codigo $cardCode no disponible o ya asignada.');
      }
      cardsData[cardIndex]['isAssigned'] = true;
      transaction.update(storeDocRef, {'cards': cardsData});
    });

    await userDocRef.update({
      'assignedCardCode': cardCode,
      'storeNit': storeNit,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  ////////////////////////////////////////////////////////////////////////////////// Quitar una tarjeta de un empleado y marcarla como desasignada en la tienda
   Future<void> unassignCardFromEmployee({
    required String storeNit,
    required String employeeUid,
    required String cardCode,
  }) async {
    final storeDocRef = _firestore.collection('stores').doc(storeNit);
    final userDocRef = _usersCollection.doc(employeeUid);
    await _firestore.runTransaction((transaction) async {
      final storeDoc = await transaction.get(storeDocRef);
      if (!storeDoc.exists) {
        throw Exception('Tienda con NIT $storeNit no encontrada para desasignar tarjeta.');
      }
      final cardsData = List<Map<String, dynamic>>.from(storeDoc.data()?['cards'] ?? []);
      final cardIndex = cardsData.indexWhere((card) => card['code'] == cardCode);
      if (cardIndex == -1 || cardsData[cardIndex]['isAssigned'] == false) {
        throw Exception('Tarjeta con codigo $cardCode no encontrada o ya desasignada.');
      }
      cardsData[cardIndex]['isAssigned'] = false;
      transaction.update(storeDocRef, {'cards': cardsData});
    });

    await userDocRef.update({
      'assignedCardCode': null,
      'storeNit': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserDeviceState(
    String uid,
    String deviceType,
    String deviceId,
    bool newState,
  ) async {
    final docRef = _firestore.collection('security').doc(uid);
    final doc = await docRef.get();
    if (doc.exists) {
      final List<dynamic> devices = doc.data()?[deviceType] ?? [];
      final deviceIndex = devices.indexWhere((d) => d['id'] == deviceId);
      if (deviceIndex != -1) {
        devices[deviceIndex]['isOn'] = newState;
        await docRef.update({deviceType: devices});
      }
    }
  }

  Future<void> triggerAlarm(String uid, String incidentType) async {
     final alarmData = {'isActive': true, 'incidentType': incidentType, 'timestamp': FieldValue.serverTimestamp()};
     await updateUserDeviceState(uid, 'alarm', '', true);
     await _firestore.collection('security').doc(uid).update({'currentAlarm': alarmData});
   }
  Future<void> resetAlarm(String uid) async {
    await updateUserDeviceState(uid, 'alarm', '', false);
    await _firestore.collection('security').doc(uid).update({'currentAlarm': null});  
  }

  Future<Object?> signInWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
  if (googleUser == null) {
    return null; // Cancelled by the user
  }

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    //accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  try {
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    debugPrint('Error de FirebaseAuth durante el inicio de sesión con Google: ${e.code} - ${e.message}');
    return null;
  } catch (e) {
    debugPrint('Ocurrió un error inesperado durante el inicio de sesión con Google: $e');
    return null;
  }
}

Future<int> adminCount() async {
  final snapshot = await _firestore.collection('admins').get();
  return snapshot.docs.length;
}


  ////
}
