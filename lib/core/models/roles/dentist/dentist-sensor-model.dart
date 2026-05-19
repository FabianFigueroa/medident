// Modelo para los diferentes tipos de sensores IoT
class DentistSensorModel {
  final String sensorId;
  final String sensorName; 
  final String type; // 'humo', 'movimiento', 'humedad', 'apertura'
  final String location; // 'Recepción', 'Consultorio 1'
  final bool isOnline;
  final dynamic value; // El valor actual del sensor (ej: 23.5 para temp)

  DentistSensorModel({
    required this.sensorId,
    required this.sensorName,
    required this.type,
    this.location = '',
    this.isOnline = false,
    this.value,
  });

  factory DentistSensorModel.fromMap(Map<String, dynamic> map) {
    return DentistSensorModel(
      sensorId: map['sensorId'] ?? '',
      sensorName: map['sensorName'] ?? '',
      type: map['type'] ?? 'unknown',
      location: map['location'] ?? '',
      isOnline: map['isOnline'] ?? false,
      value: map['value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sensorId': sensorId,
      'sensorName': sensorName,
      'type': type,
      'location': location,
      'isOnline': isOnline,
      'value': value,
    };
  }
}
