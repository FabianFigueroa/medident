
// Modelo para las tarjetas RFID (leídas por el RC522)
class DentistRfidCardModel {
  final String cardId; // El UID de la tarjeta
  final String assignedTo; // A quién está asignada (ej: 'Dr. Juan Perez')
  final String type; // Tipo de tarjeta (ej: 'employee', 'patient', 'guest')
  final String status; // Estado de la tarjeta (ej: 'active', 'inactive', 'lost')

  DentistRfidCardModel({
    required this.cardId,
    this.assignedTo = '',
    this.type = 'employee', // Valor por defecto
    this.status = 'active', // Valor por defecto
  });

  factory DentistRfidCardModel.fromMap(Map<String, dynamic> map) {
    return DentistRfidCardModel(
      cardId: map['cardId'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      type: map['type'] ?? 'employee',
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'assignedTo': assignedTo,
      'type': type,
      'status': status,
    };
  }
}
