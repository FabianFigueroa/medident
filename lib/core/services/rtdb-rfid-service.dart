import 'package:firebase_database/firebase_database.dart';
import '../models/rfid-log-model.dart';

class RtdbRfidService {
  final FirebaseDatabase _database;
  final String apiKey;
  final String deviceId;

  RtdbRfidService({
    required this.apiKey,
    required this.deviceId,
  }) : _database = FirebaseDatabase.instance;

  Stream<List<RfidLogModel>> getRfidLogsStream() {
    final ref = _database
        .ref()
        .child('clinics/$apiKey/devices/$deviceId/rfid_logs')
        .orderByChild('timestamp')
        .limitToLast(50);

    return ref.onValue.map((event) {
      final Map<dynamic, dynamic>? values =
          event.snapshot.value as Map<dynamic, dynamic>?;
      if (values == null) return [];

      final logs = values.entries
          .map((entry) => RfidLogModel.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
              entry.key as String))
          .toList();
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    });
  }

  Future<void> createRfidLog(RfidLogModel log) async {
    final ref = _database
        .ref()
        .child('clinics/$apiKey/devices/$deviceId/rfid_logs')
        .push();

    await ref.set(log.toMap());
  }
}
