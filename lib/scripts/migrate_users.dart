/// ───────────────────────────────────────────────────────────
///  MIGRATE USERS — Separa users/{uid} en subcolecciones
/// ───────────────────────────────────────────────────────────
///  Lee cada documento de la colección 'users' y:
///    - Copia perfil a:  userprofiles/{uid}
///    - Si tiene clinicId, copia empleo a: clinics/{clinicId}/employees/{uid}
///    - NO elimina nada del user original (backward compat)
///  Luego de ejecutar, verifica y limpia manual.
/// ───────────────────────────────────────────────────────────
///  Uso:
///    flutter run lib/scripts/migrate_users.dart
/// ───────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MigrateUsers {
  static Future<void> run() async {
    final db = FirebaseFirestore.instance;
    debugPrint('🚀 MigrateUsers: iniciando...');

    try {
      final usersSnap = await db.collection('users').get();
      debugPrint('📊 Usuarios encontrados: ${usersSnap.docs.length}');

      for (final doc in usersSnap.docs) {
        final uid = doc.id;
        final data = doc.data();

        // 1) Migrar perfil a userprofiles/{uid}
        final profileData = <String, dynamic>{
          if (data['address'] != null) 'address': data['address'],
          if (data['birthDate'] != null) 'birthDate': data['birthDate'],
          if (data['gender'] != null) 'gender': data['gender'],
          if (data['identificationNumber'] != null) 'identificationNumber': data['identificationNumber'],
          if (data['emergencyContactName'] != null) 'emergencyContactName': data['emergencyContactName'],
          if (data['emergencyContactPhone'] != null) 'emergencyContactPhone': data['emergencyContactPhone'],
          if (data['emergencyContactRelationship'] != null) 'emergencyContactRelationship': data['emergencyContactRelationship'],
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (profileData.length > 1) {
          await db.collection('userprofiles').doc(uid).set(profileData);
          debugPrint('  ✅ userprofiles/$uid creado');
        }

        // 2) Migrar empleo a clinics/{clinicId}/employees/{uid}
        final clinicId = data['clinicId'] as String?;
        if (clinicId != null && clinicId.isNotEmpty) {
          final employeeData = <String, dynamic>{
            'uid': uid,
            'fullName': data['fullName'] ?? '',
            'imageUrl': data['imageUrl'],
            'position': data['jobTitle'] is String && (data['jobTitle'] as String).isNotEmpty
                ? _normalizePosition(data['jobTitle'] as String)
                : 'medico_general',
            'isActive': data['isActive'] ?? true,
            'hasSecurityAccess': data['rfidUid'] != null,
            if (data['rfidUid'] != null) 'rfidUid': data['rfidUid'],
            if (data['contractType'] != null) 'contractType': data['contractType'],
            if (data['hiringDate'] != null) 'hiredAt': data['hiringDate'],
            if (data['salary'] != null) 'salary': data['salary'],
          };
          await db.collection('clinics').doc(clinicId).collection('employees').doc(uid).set(employeeData);
          debugPrint('  ✅ clinics/$clinicId/employees/$uid creado');
        }
      }

      debugPrint('✅ MigrateUsers COMPLETADO — ${usersSnap.docs.length} usuarios procesados.');
    } catch (e) {
      debugPrint('❌ MigrateUsers ERROR: $e');
    }
  }

  static String _normalizePosition(String position) {
    final map = {
      'jefe': 'jefe_de_clinica',
      'odontologo': 'odontologo_planta',
      'medico': 'medico_general',
      'limpiadora': 'limpiadora',
      'higienista': 'higienista',
      'recepcionista': 'recepcionista',
      'endodoncista': 'endodoncista',
      'bacteriologo': 'bacteriologo',
      'asesor': 'asesor',
      'cardiologo': 'cardiologo',
      'intensivista': 'intensivista',
      'psiquiatra': 'psiquiatra',
      'cirujano': 'cirujano_oral',
      'ortodoncista': 'ortodoncista',
      'anestesiologo': 'anestesiologo',
      'auxiliar': 'auxiliar_odontologia',
      'enfermero': 'enfermero',
      'director': 'director_medico',
      'coordinador': 'coordinador',
    };
    final lower = position.toLowerCase();
    for (final entry in map.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return 'medico_general';
  }
}
