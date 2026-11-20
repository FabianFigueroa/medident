import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/employee-model.dart';
import 'package:medident/core/services/notification/notification-data-service.dart';

/// Gestiona la vinculación de empleados a una clínica.
///
/// Dos caminos:
/// 1. La persona ya tiene cuenta -> se le envía una solicitud (o se vincula
///    directamente si el dueño lo decide).
/// 2. La persona no tiene cuenta -> se crea el registro y se vincula
///    directamente a la clínica (queda pendiente de activar su acceso).
class EmployeeLinkService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationDataService _notifications = NotificationDataService();

  static const _doctorPositions = {
    'jefe_de_clinica',
    'odontologo_planta',
    'medico_turno',
    'endodoncista',
    'medico_general',
    'cardiologo',
    'intensivista',
    'psiquiatra',
    'cirujano_oral',
    'ortodoncista',
    'anestesiologo',
    'bacteriologo',
  };

  String _roleForPosition(String position) =>
      _doctorPositions.contains(position) ? 'doctor' : 'employee';

  /// Busca cuentas registradas por nombre, correo, usuario o teléfono.
  Future<List<Map<String, dynamic>>> searchAccounts(String query) async {
    final raw = query.trim();
    if (raw.isEmpty) return [];
    final q = raw.toLowerCase();
    try {
      final snap = await _db.collection('users').limit(300).get();
      final results = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final fullName = (data['fullName'] ?? '').toString().toLowerCase();
        final email = (data['email'] ?? '').toString().toLowerCase();
        final userName = (data['userName'] ?? '').toString().toLowerCase();
        final phone =
            (data['phoneNumber'] ?? data['phone'] ?? '').toString();
        if (fullName.contains(q) ||
            email.contains(q) ||
            userName.contains(q) ||
            phone.contains(raw)) {
          results.add({'id': doc.id, ...data});
        }
      }
      results.sort((a, b) => (a['fullName'] ?? '')
          .toString()
          .toLowerCase()
          .compareTo((b['fullName'] ?? '').toString().toLowerCase()));
      return results.take(30).toList();
    } catch (e) {
      debugPrint('EmployeeLinkService.searchAccounts: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> findAccountByEmail(String email) async {
    final q = email.trim();
    if (q.isEmpty) return null;
    try {
      final snap = await _db
          .collection('users')
          .where('email', isEqualTo: q)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return {'id': snap.docs.first.id, ...snap.docs.first.data()};
    } catch (e) {
      debugPrint('EmployeeLinkService.findAccountByEmail: $e');
      return null;
    }
  }

  /// Envía una solicitud de vinculación al usuario (debe tener cuenta).
  Future<String> sendLinkRequest({
    required String clinicId,
    required String clinicName,
    required String ownerId,
    required String ownerName,
    required String userId,
    required String userName,
    required String userEmail,
    required String position,
    String? userPhoto,
    String? message,
    bool canManageAgenda = false,
  }) async {
    final docId = '${clinicId}_$userId';
    final ref = _db.collection('clinic_link_requests').doc(docId);
    final existing = await ref.get();
    if (existing.exists && existing.data()?['status'] == 'pending') {
      throw Exception('Ya existe una solicitud pendiente para este usuario.');
    }

    await ref.set({
      'clinicId': clinicId,
      'clinicName': clinicName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhoto': userPhoto,
      'position': position,
      'message': message,
      'canManageAgenda': canManageAgenda,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'respondedAt': null,
    });

    await _notifications.createNotification(
      userId: userId,
      type: 'clinic_link_request',
      fromUserId: ownerId,
      fromUserName: ownerName,
      title: 'Invitación a $clinicName',
      body:
          '$ownerName te invita a unirte al equipo como ${EmployeePositions.displayName(position)}.',
      data: {
        'clinicId': clinicId,
        'requestId': docId,
        'position': position,
        'screen': 'clinic_link_request',
      },
    );

    return docId;
  }

  /// Vincula directamente una cuenta existente sin pedir aprobación.
  Future<void> linkDirectly({
    required String clinicId,
    required String clinicName,
    required String ownerId,
    required String ownerName,
    required String userId,
    required String userName,
    required String position,
    String? userPhoto,
    bool canManageAgenda = false,
  }) async {
    await _applyLink(
      clinicId: clinicId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      position: position,
      canManageAgenda: canManageAgenda,
    );

    await _notifications.createNotification(
      userId: userId,
      type: 'clinic_linked',
      fromUserId: ownerId,
      fromUserName: ownerName,
      title: 'Vinculado a $clinicName',
      body:
          '$ownerName te vinculó al equipo como ${EmployeePositions.displayName(position)}.',
      data: {'clinicId': clinicId, 'position': position},
    );
  }

  /// Crea un empleado sin cuenta y lo vincula a la clínica.
  Future<String> createAndLinkEmployee({
    required String clinicId,
    required String clinicName,
    required String ownerId,
    required String fullName,
    required String position,
    String? email,
    String? phone,
    String? gender,
    DateTime? birthDate,
    String? address,
    String? contractType,
    DateTime? hiredAt,
    num? salary,
    String? notes,
    bool canManageAgenda = false,
  }) async {
    final uid = _db.collection('users').doc().id;
    final now = FieldValue.serverTimestamp();
    final role = _roleForPosition(position);

    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email ?? '',
      'phoneNumber': phone,
      'role': role,
      'clinicId': clinicId,
      'gender': gender,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate) : null,
      'address': address,
      'isActive': true,
      'isClinicOwner': false,
      'pendingRegistration': true,
      'createdBy': ownerId,
      'createdAt': now,
      'updatedAt': now,
    });

    await _applyLink(
      clinicId: clinicId,
      userId: uid,
      userName: fullName,
      position: position,
      contractType: contractType,
      hiredAt: hiredAt,
      salary: salary,
      notes: notes,
      canManageAgenda: canManageAgenda,
      extra: {
        'email': email ?? '',
        'phoneNumber': phone,
        'gender': gender,
        'address': address,
        'pendingRegistration': true,
      },
    );

    return uid;
  }

  Stream<List<Map<String, dynamic>>> streamOwnerRequests(String clinicId) {
    return _db
        .collection('clinic_link_requests')
        .where('clinicId', isEqualTo: clinicId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList();
      list.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
        return 0;
      });
      return list;
    });
  }

  Stream<List<Map<String, dynamic>>> streamUserRequests(String userId) {
    return _db
        .collection('clinic_link_requests')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList());
  }

  Future<void> respondRequest({
    required String requestId,
    required bool accept,
  }) async {
    final ref = _db.collection('clinic_link_requests').doc(requestId);
    final snap = await ref.get();
    final data = snap.data();
    if (data == null) throw Exception('Solicitud no encontrada.');

    if (accept) {
      await _applyLink(
        clinicId: data['clinicId'] as String,
        userId: data['userId'] as String,
        userName: (data['userName'] ?? '') as String,
        userPhoto: data['userPhoto'] as String?,
        position: (data['position'] ?? 'medico_general') as String,
        canManageAgenda: data['canManageAgenda'] as bool? ?? false,
      );
    }

    await ref.update({
      'status': accept ? 'accepted' : 'rejected',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    final ownerId = data['ownerId'] as String?;
    if (ownerId != null) {
      await _notifications.createNotification(
        userId: ownerId,
        type: accept ? 'clinic_link_accepted' : 'clinic_link_rejected',
        fromUserId: (data['userId'] ?? '') as String,
        fromUserName: (data['userName'] ?? 'Usuario') as String,
        title: accept ? 'Solicitud aceptada' : 'Solicitud rechazada',
        body: accept
            ? '${data['userName']} aceptó unirse a ${data['clinicName']}.'
            : '${data['userName']} rechazó la invitación a ${data['clinicName']}.',
        data: {'clinicId': data['clinicId']},
      );
    }
  }

  Future<void> cancelRequest(String requestId) async {
    await _db
        .collection('clinic_link_requests')
        .doc(requestId)
        .update({'status': 'cancelled'});
  }

  Future<void> _applyLink({
    required String clinicId,
    required String userId,
    required String userName,
    required String position,
    String? userPhoto,
    String? contractType,
    DateTime? hiredAt,
    num? salary,
    String? notes,
    bool canManageAgenda = false,
    Map<String, dynamic>? extra,
  }) async {
    final batch = _db.batch();

    batch.set(
      _db.collection('users').doc(userId),
      {
        'clinicId': clinicId,
        'isClinicOwner': false,
        'updatedAt': FieldValue.serverTimestamp(),
        if (extra != null) ...extra,
      },
      SetOptions(merge: true),
    );

    batch.set(
      _db.collection('clinics').doc(clinicId),
      {
        'employeeIds': FieldValue.arrayUnion([userId]),
      },
      SetOptions(merge: true),
    );

    batch.set(
      _db
          .collection('clinics')
          .doc(clinicId)
          .collection('employees')
          .doc(userId),
      {
        'uid': userId,
        'fullName': userName,
        if (userPhoto != null && userPhoto.isNotEmpty) 'imageUrl': userPhoto,
        'position': position,
        'isActive': true,
        'hasSecurityAccess': false,
        'canManageAgenda': canManageAgenda,
        if (contractType != null) 'contractType': contractType,
        if (hiredAt != null) 'hiredAt': Timestamp.fromDate(hiredAt),
        if (salary != null) 'salary': salary,
        if (notes != null) 'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
