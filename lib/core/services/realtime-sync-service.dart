import 'package:firebase_database/firebase_database.dart';

/// Servicio para sincronizacion con Realtime Database (ESP32)
class RealtimeSyncService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Escuchar ultimo scan RFID
  Stream<Map<dynamic, dynamic>?> listenToRfidScan(String userId) {
    return _database
        .ref('devices/$userId/rfid/lastScan')
        .onValue
        .map((event) => event.snapshot.value as Map<dynamic, dynamic>?);
  }

  /// Escribir comando de captura de camara
  Future<void> triggerCameraCapture(String userId, String camId) async {
    await _database.ref('devices/$userId/cameras/$camId/capture').set({
      'command': true,
      'timestamp': ServerValue.timestamp,
    });
  }

  /// Leer ultima foto capturada
  Stream<Map<dynamic, dynamic>?> listenToCameraSnapshot(String userId, String camId) {
    return _database
        .ref('devices/$userId/cameras/$camId/lastCapture')
        .onValue
        .map((event) => event.snapshot.value as Map<dynamic, dynamic>?);
  }

  /// Controlar dispositivo (puerta, luz, etc.)
  Future<void> controlDevice(String userId, String deviceType, String deviceId, Map<String, dynamic> state) async {
    final data = Map<String, dynamic>.from(state);
    data['lastUpdate'] = ServerValue.timestamp;
    await _database.ref('devices/$userId/controls/$deviceType/$deviceId').update(data);
  }

  /// Escuchar estado de dispositivo
  Stream<Map<dynamic, dynamic>?> listenToDeviceState(String userId, String deviceId) {
    return _database
        .ref('devices/$userId/controls/$deviceId')
        .onValue
        .map((event) => event.snapshot.value as Map<dynamic, dynamic>?);
  }

  /// Verificar si ESP32 esta online
  Stream<bool>? listenToHeartbeat(String userId) {
    return _database
        .ref('devices/$userId/heartbeat/status')
        .onValue
        .map((event) {
      final status = event.snapshot.value as String?;
      return status == 'online';
    });
  }

  /// Escribir estado de alarma
  Future<void> setAlarmState(String userId, String state) async {
    await _database.ref('devices/$userId/alarm/state').set({
      'value': state,
      'timestamp': ServerValue.timestamp,
    });
  }
}
