import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/user-model.dart';

class DentistProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene el perfil de un usuario una sola vez desde Firestore.
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      } else {
        throw Exception('User profile not found.');
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Crea un stream para escuchar cambios en tiempo real en el perfil de un usuario.
  Stream<UserModel> streamUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!, snapshot.id);
      } else {
        throw Exception('User profile not found in stream.');
      }
    });
  }

  /// Crea un stream para escuchar cambios en los miembros del equipo.
  /// NOTA: Esta es una implementación de ejemplo. Deberás ajustar la consulta
  /// a cómo tengas estructurados los equipos en tu base de datos.
  Stream<List<UserModel>> streamTeamMembers(String userId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'dentist')
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) => user.uid != userId)
          .toList();
    });
  }

  /// Obtiene las promociones de un usuario una sola vez desde Firestore.
  /// Maneja el caso donde la colección aún no existe o está vacía.
  Future<List<Map<String, dynamic>>> getPromotions(String userId) async {
    try {
      // Primero verificamos si la colección existe intentando obtener un documento límite 1
      final collectionExists = await _firestore
          .collection('promotions')
          .limit(1)
          .get()
          .then((snapshot) => !snapshot.docs.isEmpty)
          .catchError((e) => false);
      
      if (!collectionExists) {
        return [];
      }
      
      final snapshot = await _firestore
          .collection('promotions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error getting promotions: $e');
      // En caso de cualquier error, retornamos lista vacía para no romper la UI
      return [];
    }
  }

  /// Crea un stream para escuchar cambios en tiempo real en las promociones de un usuario.
  Stream<List<Map<String, dynamic>>> streamPromotions(String userId) {
    return _firestore
        .collection('promotions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
        .handleError((e) {
          debugPrint('Error in promotions stream: $e');
          return []; // Retornamos lista vacía en caso de error en el stream
        });
  }

  /// Obtiene los posts destacados de un usuario una sola vez desde Firestore.
  /// Maneja el caso donde la colección aún no existe o está vacía.
  Future<List<Map<String, dynamic>>> getFeaturedPosts(String userId) async {
    try {
      // Primero verificamos si la colección existe
      final collectionExists = await _firestore
          .collection('featured_posts')
          .limit(1)
          .get()
          .then((snapshot) => !snapshot.docs.isEmpty)
          .catchError((e) => false);
      
      if (!collectionExists) {
        return [];
      }
      
      final snapshot = await _firestore
          .collection('featured_posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error getting featured posts: $e');
      // En caso de cualquier error, retornamos lista vacía para no romper la UI
      return [];
    }
  }

  /// Crea un stream para escuchar cambios en tiempo real en los posts destacados de un usuario.
  Stream<List<Map<String, dynamic>>> streamFeaturedPosts(String userId) {
    return _firestore
        .collection('featured_posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
        .handleError((e) {
          debugPrint('Error in featured posts stream: $e');
          return []; // Retornamos lista vacía en caso de error en el stream
        });
  }
}