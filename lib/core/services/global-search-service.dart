import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/clinic-model.dart';
import 'package:medident/core/models/post-model.dart';
import 'package:medident/core/models/user-model.dart';

/// Búsqueda global en tiempo real sobre un conjunto acotado de documentos.
///
/// Estrategia: se abre un stream por colección (usuarios, clínicas y posts)
/// con un límite razonable. El filtrado por texto se hace en memoria para que
/// sea instantáneo (sin una lectura nueva por cada tecla) y case-insensitive.
class GlobalSearchService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<List<UserModel>> streamUsers({int limit = 100}) {
    return _firestore.collection('users').limit(limit).snapshots().map((snap) {
      final users = <UserModel>[];
      for (final doc in snap.docs) {
        try {
          final data = doc.data();
          users.add(UserModel.fromMap(data, doc.id));
        } catch (e) {
          debugPrint('GlobalSearch users: $e');
        }
      }
      return users;
    });
  }

  Stream<List<ClinicModel>> streamClinics({int limit = 100}) {
    return _firestore
        .collection('clinics')
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ClinicModel.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<PostModel>> streamPosts({int limit = 100}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['id'] = d.id;
              return PostModel.fromJson(data, d.id);
            }).toList());
  }
}
