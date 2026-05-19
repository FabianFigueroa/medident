import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Servicio para integrar ESP32 y ESP32-CAM-S con la app
/// mediante Firebase Realtime Database.
///
/// Flujo:
/// 1. ESP32 escribe un RFID tag en RTDB: /clinics/{apiKey}/devices/{id}/rfid_logs/
/// 2. ESP32-CAM-S toma foto y la sube a RTDB como base64
/// 3. Este servicio detecta el evento, cruza con Firestore, y archiva
class RtdbEsp32Service {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  StreamSubscription? _rfidSub;
  StreamSubscription? _configSub;

  /// Iniciar escucha de eventos RFID para una clínica
  void startListening(String apiKey) {
    _rfidSub?.cancel();

    final ref = _rtdb.ref('clinics/$apiKey/devices');
    _rfidSub = ref.onChildAdded.listen((event) {
      final deviceId = event.snapshot.key;
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      _handleDeviceEvent(apiKey, deviceId!, data);
    });
  }

  void _handleDeviceEvent(String apiKey, String deviceId, Map data) {
    // Detectar nuevo log RFID
    if (data['rfid_logs'] is Map) {
      final logs = data['rfid_logs'] as Map;
      for (final logId in logs.keys) {
        final log = logs[logId] as Map;
        if (log['processed'] == true) continue;
        _processRfidLog(apiKey, deviceId, logId, log);
      }
    }
  }

  Future<void> _processRfidLog(
    String apiKey,
    String deviceId,
    String logId,
    Map log,
  ) async {
    try {
      final cardUid = log['cardUid'] as String?;
      final action = log['action'] as String?; // "entry" | "exit"
      final timestamp = log['timestamp'] as int?;
      final photoBase64 = log['photo'] as String?;

      if (cardUid == null) return;

      // Buscar usuario por cardUid en Firestore
      final userSnap = await _firestore
          .collection('users')
          .where('assignedCardCode', isEqualTo: cardUid)
          .limit(1)
          .get();

      String? employeeId;
      String? employeeName;
      String? photoUrl;

      if (userSnap.docs.isNotEmpty) {
        final userData = userSnap.docs.first.data();
        employeeId = userSnap.docs.first.id;
        employeeName = userData['fullName'] ?? 'Desconocido';

        // Si hay foto base64 de ESP32-CAM, subir a Storage
        if (photoBase64 != null && photoBase64.isNotEmpty) {
          photoUrl = await _uploadPhoto(
            employeeId,
            deviceId,
            photoBase64,
            timestamp ?? DateTime.now().millisecondsSinceEpoch,
          );
        }

        // Registrar en Firestore
        await _firestore.collection('access_logs').add({
          'clinicId': apiKey,
          'deviceId': deviceId,
          'employeeId': employeeId,
          'employeeName': employeeName,
          'cardUid': cardUid,
          'action': action ?? 'entry',
          'photoUrl': photoUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Actualizar último registro en el usuario
        await _firestore.collection('users').doc(employeeId).update({
          'lastAccess': {
            'action': action ?? 'entry',
            'deviceId': deviceId,
            'timestamp': FieldValue.serverTimestamp(),
          },
          'isInClinic': action == 'entry',
        });

        // Marcar como procesado en RTDB
        await _rtdb
            .ref('clinics/$apiKey/devices/$deviceId/rfid_logs/$logId')
            .update({'processed': true, 'employeeId': employeeId});
      } else {
        // Tarjeta no reconocida: registrar acceso denegado
        await _firestore.collection('access_logs').add({
          'clinicId': apiKey,
          'deviceId': deviceId,
          'cardUid': cardUid,
          'action': action ?? 'entry',
          'status': 'denied',
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _rtdb
            .ref('clinics/$apiKey/devices/$deviceId/rfid_logs/$logId')
            .update({'processed': true, 'status': 'denied'});
      }
    } catch (e) {
      debugPrint('Error processing RFID log: $e');
    }
  }

  Future<String> _uploadPhoto(
    String employeeId,
    String deviceId,
    String base64Photo,
    int timestamp,
  ) async {
    try {
      final bytes = _base64ToBytes(base64Photo);
      final ref = _storage.ref(
        'access_photos/$employeeId/${deviceId}_$timestamp.jpg',
      );
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      return '';
    }
  }

  Uint8List _base64ToBytes(String base64) {
    final clean = base64.contains(',')
        ? base64.split(',').last
        : base64;
    return Uint8List.fromList(
      _base64Decode(clean),
    );
  }

  List<int> _base64Decode(String input) {
    final lookup = {
      for (int i = 0; i < 64; i++)
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'[i]: i,
    };
    final output = <int>[];
    int buffer = 0;
    int bitsCollected = 0;
    for (final char in input.runes) {
      if (char == 0x3D) break; // '='
      final value = lookup[String.fromCharCode(char)];
      if (value == null) continue;
      buffer = (buffer << 6) | value;
      bitsCollected += 6;
      if (bitsCollected >= 8) {
        bitsCollected -= 8;
        output.add((buffer >> bitsCollected) & 0xFF);
      }
    }
    return output;
  }

  /// Escribir configuración de dispositivo en RTDB
  Future<void> updateDeviceConfig({
    required String apiKey,
    required String deviceId,
    required Map<String, dynamic> config,
  }) async {
    await _rtdb
        .ref('clinics/$apiKey/devices/$deviceId/config')
        .update(config);
  }

  /// Enviar comando a ESP32 (abrir puerta, activar relay, etc.)
  Future<void> sendCommand({
    required String apiKey,
    required String deviceId,
    required String command,
    Map<String, dynamic>? params,
  }) async {
    final cmdRef = _rtdb.ref(
      'clinics/$apiKey/devices/$deviceId/commands',
    );
    await cmdRef.push().set({
      'command': command,
      'params': params ?? {},
      'timestamp': ServerValue.timestamp,
    });
  }

  void stopListening() {
    _rfidSub?.cancel();
    _configSub?.cancel();
  }

  void dispose() {
    stopListening();
  }
}
