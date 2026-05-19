import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/roles/dentist/dentist-rfid-model.dart';
import 'package:medident/core/models/roles/dentist/dentist-sensor-model.dart';
import 'package:medident/core/models/rfid-reader-model.dart';

// Modelo principal que representa el contrato de seguridad de un usuario (dentista)
class DentistSecurityModel {
  final String userId; // ID del usuario de Firebase
  final String locationId; // ID del local o clínica
  final String dentistName; // Nombre del dentista para fácil referencia en admin
  final String dentistEmail; // Email del dentista para fácil referencia en admin
  final String contractStatus;
  final String address;
  final int employeeCount;
  final DateTime? contractStartDate; // Fecha de inicio del contrato
  final DateTime? contractEndDate; // Fecha de fin del contrato
  final DateTime? lastActivityDate; // Última actividad registrada
  final int totalSensors; // Conteo de sensores activos
  final int totalCards; // Conteo de tarjetas RFID
  final List<DentistRfidCardModel> cards;
  final List<DentistSensorModel> sensors;
  
  // Propiedades para dispositivos IoT
  final List<Device> lights;
  final List<Device> fans;
  final List<Device> airs;
  final List<Device> tvs;
  final List<Device> voices;
  final List<Device> doors;
  
  // Propiedades para gestión de tarjetas RFID
  bool isRegisteringCard = false;
  String? scannedRfidCardId;
  bool isAssigningRfidCard = false;
  
  // Propiedades para control LED
  String? activeLedOption;
  
  // Propiedades para cámara ESP32
  String? esp32CamIp;
  bool isCameraActive = false;
  
   // Propiedades para bitácora
  List<SecurityLog> securityLogs;

  // Propiedades para lectores RFID
  List<RfidReaderModel> readers;

  // Getters de alias para compatibilidad con el widget
  List<DentistRfidCardModel> get rfidCards => cards;

  DentistSecurityModel({
    required this.userId,
    required this.locationId,
    this.dentistName = '',
    this.dentistEmail = '',
    this.contractStatus = 'inactive', // Valor por defecto
    this.address = '',
    this.employeeCount = 0,
    this.contractStartDate,
    this.contractEndDate,
    this.lastActivityDate,
    this.totalSensors = 0,
    this.totalCards = 0,
    this.cards = const [],
    this.sensors = const [],
    this.lights = const [],
    this.fans = const [],
    this.airs = const [],
    this.tvs = const [],
    this.voices = const [],
    this.doors = const [],
       this.securityLogs = const [],
       this.readers = const [],
       this.activeLedOption,
       this.esp32CamIp,
     });

  // Convertir un Documento de Firestore a nuestro modelo
  factory DentistSecurityModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DentistSecurityModel(
      userId: data['userId'] ?? '',
      locationId: data['locationId'] ?? '',
      dentistName: data['dentistName'] ?? '',
      dentistEmail: data['dentistEmail'] ?? '',
      contractStatus: data['contract-status'] ?? 'inactive',
      address: data['address'] ?? '',
      employeeCount: data['employeeCount'] ?? 0,
      contractStartDate: (data['contractStartDate'] as Timestamp?)?.toDate(),
      contractEndDate: (data['contractEndDate'] as Timestamp?)?.toDate(),
      lastActivityDate: (data['lastActivityDate'] as Timestamp?)?.toDate(),
      totalSensors: data['totalSensors'] ?? 0,
      totalCards: data['totalCards'] ?? 0,
      cards: (data['cards'] as List<dynamic>?)
              ?.map((cardData) => DentistRfidCardModel.fromMap(cardData))
              .toList() ??
          [],
      sensors: (data['sensors'] as List<dynamic>?)
              ?.map((sensorData) => DentistSensorModel.fromMap(sensorData))
              .toList() ??
          [],
      lights: (data['lights'] as List<dynamic>?)
              ?.map((d) => Device.fromMap(d))
              .toList() ??
          [],
      fans: (data['fans'] as List<dynamic>?)
              ?.map((d) => Device.fromMap(d))
              .toList() ??
          [],
      airs: (data['airs'] as List<dynamic>?)
              ?.map((d) => Device.fromMap(d))
              .toList() ??
          [],
      tvs: (data['tvs'] as List<dynamic>?)
              ?.map((d) => Device.fromMap(d))
              .toList() ??
          [],
      voices: (data['voices'] as List<dynamic>?)
              ?.map((d) => Device.fromMap(d))
              .toList() ??
          [],
       doors: (data['doors'] as List<dynamic>?)
               ?.map((d) => Device.fromMap(d))
               .toList() ??
           [],
       activeLedOption: data['activeLedOption'],
       esp32CamIp: data['esp32CamIp'],
       readers: (data['readers'] as List<dynamic>?)
               ?.map((r) => RfidReaderModel.fromMap(r))
               .toList() ??
           [],
     );
   }

  // Convertir nuestro modelo a un Map para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'locationId': locationId,
      'dentistName': dentistName,
      'dentistEmail': dentistEmail,
      'contract-status': contractStatus,
      'address': address,
      'employeeCount': employeeCount,
      'contractStartDate': contractStartDate != null ? Timestamp.fromDate(contractStartDate!) : null,
      'contractEndDate': contractEndDate != null ? Timestamp.fromDate(contractEndDate!) : null,
      'lastActivityDate': lastActivityDate != null ? Timestamp.fromDate(lastActivityDate!) : null,
      'totalSensors': totalSensors,
      'totalCards': totalCards,
      'cards': cards.map((card) => card.toMap()).toList(),
      'sensors': sensors.map((sensor) => sensor.toMap()).toList(),
      'lights': lights.map((light) => light.toMap()).toList(),
      'fans': fans.map((fan) => fan.toMap()).toList(),
      'airs': airs.map((air) => air.toMap()).toList(),
      'tvs': tvs.map((tv) => tv.toMap()).toList(),
      'voices': voices.map((voice) => voice.toMap()).toList(),
      'doors': doors.map((door) => door.toMap()).toList(),
      'activeLedOption': activeLedOption,
       'esp32CamIp': esp32CamIp,
       'readers': readers.map((r) => r.toMap()).toList(),
     };
  }
}

// Modelo para un dispositivo IoT genérico
class Device {
  final String id;
  final String name;
  final String room;
  bool isOn;

  Device({
    required this.id,
    required this.name,
    required this.room,
    this.isOn = false,
  });

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      room: map['room'] ?? '',
      isOn: map['isOn'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'room': room,
      'isOn': isOn,
    };
  }
}

// Modelo para un evento de seguridad
class SecurityLog {
  final String id;
  final String type; // 'card_scan', 'sensor_trigger', 'alarm', etc.
  final String description;
  final DateTime timestamp;
  final String? userId;

  SecurityLog({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.userId,
  });

  factory SecurityLog.fromMap(Map<String, dynamic> map) {
    return SecurityLog(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
    };
  }
}
