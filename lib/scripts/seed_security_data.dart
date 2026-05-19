import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Script para llenar Firebase con datos de prueba de seguridad
Future<void> seedSecurityData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    debugPrint('ERROR: No hay usuario autenticado');
    return;
  }

  final uid = user.uid;
  final firestore = FirebaseFirestore.instance;

  debugPrint('Iniciando seed de datos de seguridad...  UserId: $uid');


  try {
    // 1. Crear documento de seguridad
    await firestore.collection('security').doc(uid).set({
      'userId': uid,
      'locationId': 'clinic_001',
      'dentistName': 'Dr. Juan Pérez',
      'dentistEmail': user.email ?? '',
      'contract-status': 'trial',
      'address': 'Calle Dental 123, Centro Médico',
      'employeeCount': 3,
      'contractStartDate': Timestamp.now(),
      'contractEndDate': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 30)),
      ),
      'cards': [
        {'cardId': 'RFID-001-DR', 'assignedTo': 'Dr. Juan Pérez', 'type': 'employee', 'status': 'active'},
        {'cardId': 'RFID-002-AUX', 'assignedTo': 'Aux. María López', 'type': 'employee', 'status': 'active'},
        {'cardId': 'RFID-003-PAT', 'assignedTo': 'Paciente Carlos Ruiz', 'type': 'patient', 'status': 'active'},
        {'cardId': 'RFID-004-VIS', 'assignedTo': 'Visitante', 'type': 'guest', 'status': 'inactive'},
      ],
      'sensors': [
        {'sensorId': 'sensor_001', 'sensorName': 'Humo Consultorio 1', 'type': 'smoke', 'location': 'Consultorio 1', 'isOnline': true, 'value': 0},
        {'sensorId': 'sensor_002', 'sensorName': 'Movimiento Entrada', 'type': 'motion', 'location': 'Entrada', 'isOnline': true, 'value': 0},
        {'sensorId': 'sensor_003', 'sensorName': 'Temp Refrigerador', 'type': 'temperature', 'location': 'Esterilización', 'isOnline': true, 'value': 5.2},
      ],
      'lights': [
        {'id': 'light_001', 'name': 'Luz Entrada', 'room': 'Entrada', 'isOn': true},
        {'id': 'light_002', 'name': 'Luz Consultorio 1', 'room': 'Consultorio 1', 'isOn': false},
      ],
      'fans': [
        {'id': 'fan_001', 'name': 'Extractor', 'room': 'Esterilización', 'isOn': true},
      ],
      'airs': [
        {'id': 'air_001', 'name': 'A/C Principal', 'room': 'Central', 'isOn': true},
      ],
      'tvs': [],
      'voices': [],
      'doors': [
        {'id': 'door_001', 'name': 'Puerta Entrada', 'room': 'Entrada', 'isOn': false},
      ],
      'cameras': [
        {'camId': 'cam_001', 'name': 'Cámara Entrada', 'room': 'Entrada', 'ipAddress': '192.168.1.101', 'isActive': true},
        {'camId': 'cam_002', 'name': 'Cámara Consultorio 1', 'room': 'Consultorio 1', 'ipAddress': '192.168.1.102', 'isActive': false},
      ],
      'readers': [
        {'readerId': 'reader_001', 'location': 'Entrada', 'hasCamera': true, 'cameraId': 'cam_001', 'isOnline': true, 'type': 'entrance'},
        {'readerId': 'reader_002', 'location': 'Consultorio 1', 'hasCamera': false, 'cameraId': null, 'isOnline': true, 'type': 'office'},
      ],
      'esp32CamIp': '192.168.1.101',
      'isCameraActive': true,
      'securityLogs': [],
    });

    debugPrint('✅ Documento security creado');

    // 2. Crear logs RFID de prueba
    final rfidLogs = [
      {
        'userId': uid,
        'cardId': 'RFID-001-DR',
        'readerId': 'reader_001',
        'granted': true,
        'photoUrl': null,
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        'location': 'Entrada',
        'patientId': null,
        'description': 'Acceso concedido: Dr. Juan Pérez',
      },
      {
        'userId': uid,
        'cardId': 'RFID-002-AUX',
        'readerId': 'reader_001',
        'granted': true,
        'photoUrl': null,
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))),
        'location': 'Entrada',
        'patientId': null,
        'description': 'Acceso concedido: Aux. María López',
      },
      {
        'userId': uid,
        'cardId': 'UNKNOWN',
        'readerId': 'reader_001',
        'granted': false,
        'photoUrl': null,
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
        'location': 'Entrada',
        'patientId': null,
        'description': '¡ACCESO DENEGADO! Tarjeta desconocida',
      },
    ];

    for (var i = 0; i < rfidLogs.length; i++) {
      await firestore.collection('rfid_logs').doc('seed_log_00${i + 1}').set(rfidLogs[i]);
    }

    debugPrint('✅ 3 RFID logs creados');

    // 3. Crear alertas de prueba
    final alerts = [
      {
        'userId': uid,
        'clinicId': 'clinic_001',
        'type': 'rfid_scan',
        'severity': 'low',
        'title': 'Acceso: Dr. Juan Pérez',
        'description': 'Acceso concedido: Dr. Juan Pérez en Entrada',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        'room': 'Entrada',
        'deviceId': 'reader_001',
        'cardId': 'RFID-001-DR',
        'photoUrl': null,
        'read': false,
        'handled': false,
        'metadata': {'granted': true},
      },
      {
        'userId': uid,
        'clinicId': 'clinic_001',
        'type': 'rfid_scan',
        'severity': 'high',
        'title': '¡ACCESO DENEGADO!',
        'description': '¡ACCESO DENEGADO! Tarjeta desconocida en Entrada',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
        'room': 'Entrada',
        'deviceId': 'reader_001',
        'cardId': 'UNKNOWN',
        'photoUrl': null,
        'read': false,
        'handled': false,
        'metadata': {'granted': false},
      },
      {
        'userId': uid,
        'clinicId': 'clinic_001',
        'type': 'sensor_trigger',
        'severity': 'medium',
        'title': 'Movimiento detectado',
        'description': 'Sensor de movimiento activado en Entrada',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 15))),
        'room': 'Entrada',
        'deviceId': 'sensor_002',
        'cardId': null,
        'photoUrl': null,
        'read': false,
        'handled': false,
        'metadata': {'sensorType': 'motion'},
      },
    ];

    for (var i = 0; i < alerts.length; i++) {
      await firestore.collection('alerts').doc('seed_alert_00${i + 1}').set(alerts[i]);
    }

    debugPrint('✅ 3 alertas creadas');

    // 4. Crear clínica
    await firestore.collection('clinics').doc('clinic_001').set({
      'name': 'Clínica Dental Pérez',
      'address': 'Calle Dental 123, Centro Médico',
      'ownerId': uid,
      'employeeIds': [
        uid,
        'emp_seed_001',
        'emp_seed_002',
        'emp_seed_003',
        'emp_seed_004',
        'emp_seed_005',
      ],
      'employees': [
        {'uid': 'emp_001', 'name': 'Aux. María López', 'rfidCardId': 'RFID-002-AUX'},
      ],
      'professionals': [
        {'uid': uid, 'specialty': 'Odontología', 'rfidCardId': 'RFID-001-DR'},
      ],
      'subscription': {
        'status': 'trial',
        'type': 'free_trial',
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      },
    });

    debugPrint('✅ Clínica creada');

    // 5. Crear 5 empleados de prueba (3 activos en clínica, 2 pendientes)
    final testEmployees = [
      {
        'uid': 'emp_seed_001',
        'fullName': 'Dr. Roberto Silva',
        'email': 'roberto.silva@test.com',
        'role': 'dentist',
        'clinicId': 'clinic_001',
        'assignedCardCode': 'RFID-001-DR',
        'isInClinic': true,
        'isActive': true,
      },
      {
        'uid': 'emp_seed_002',
        'fullName': 'Dra. Laura Martínez',
        'email': 'laura.martinez@test.com',
        'role': 'dentist',
        'clinicId': 'clinic_001',
        'assignedCardCode': 'RFID-005-LM',
        'isInClinic': true,
        'isActive': true,
      },
      {
        'uid': 'emp_seed_003',
        'fullName': 'María López',
        'email': 'maria.lopez@test.com',
        'role': 'employee',
        'clinicId': 'clinic_001',
        'assignedCardCode': 'RFID-002-AUX',
        'isInClinic': true,
        'isActive': true,
      },
      {
        'uid': 'emp_seed_004',
        'fullName': 'Carlos García',
        'email': 'carlos.garcia@test.com',
        'role': 'employee',
        'clinicId': 'clinic_001',
        'assignedCardCode': 'RFID-006-CG',
        'isInClinic': false,
        'isActive': true,
      },
      {
        'uid': 'emp_seed_005',
        'fullName': 'Ana Rodríguez',
        'email': 'ana.rodriguez@test.com',
        'role': 'employee',
        'clinicId': 'clinic_001',
        'assignedCardCode': 'RFID-007-AR',
        'isInClinic': false,
        'isActive': true,
      },
    ];

    for (final emp in testEmployees) {
      await firestore.collection('users').doc(emp['uid'] as String).set({
        ...emp,
        'servicesCount': 0,
        'followersCount': 0,
        'followingCount': 0,
        'isClinicOwner': false,
        'imageUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    debugPrint('✅ 5 empleados de prueba creados (3 activos, 2 pendientes)');

    // 6. Crear access_logs de prueba para hoy (empleados activos)
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    for (var i = 0; i < 3; i++) {
      final emp = testEmployees[i];
      await firestore.collection('access_logs').add({
        'clinicId': 'clinic_001',
        'employeeId': emp['uid'],
        'employeeName': emp['fullName'],
        'cardUid': emp['assignedCardCode'],
        'action': 'entry',
        'deviceId': 'reader_001',
        'timestamp': Timestamp.fromDate(todayStart.add(Duration(hours: 7 + i))),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    debugPrint('✅ 3 access_logs de entrada creados para hoy');

    debugPrint('═══════════════════════════════════════');
    debugPrint('✅ SEED COMPLETADO EXITOSAMENTE');
    debugPrint('═══════════════════════════════════════');
  } catch (e) {
    debugPrint('❌ ERROR en seed: $e');
  }
}

/// Limpiar datos de prueba
Future<void> cleanupSecurityData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final uid = user.uid;
  final firestore = FirebaseFirestore.instance;

  debugPrint('Limpiando datos de prueba...');

  try {
    // Eliminar logs RFID
    final logs = await firestore
        .collection('rfid_logs')
        .where('userId', isEqualTo: uid)
        .get();

    for (var doc in logs.docs) {
      if (doc.id.startsWith('seed_')) {
        await doc.reference.delete();
      }
    }

    // Eliminar alertas
    final alerts = await firestore
        .collection('alerts')
        .where('userId', isEqualTo: uid)
        .get();

    for (var doc in alerts.docs) {
      if (doc.id.startsWith('seed_')) {
        await doc.reference.delete();
      }
    }

    // Resetear security
    await firestore.collection('security').doc(uid).update({
      'contract-status': 'none',
      'readers': [],
    });

    debugPrint('✅ Limpieza completada');
  } catch (e) {
    debugPrint('❌ Error en limpieza: $e');
  }
}
