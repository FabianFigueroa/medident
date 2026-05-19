import 'package:cloud_firestore/cloud_firestore.dart';

enum DeliveryStatus { pending, accepted, inTransit, delivered, cancelled }

class DeliveryModel {
  final String id;
  final String orderId;
  final String patientName;
  final String patientPhone;
  final String patientAddress;
  final String originAddress;
  final GeoPoint originLocation;
  final GeoPoint destinationLocation;
  final String items;
  final double total;
  final DeliveryStatus status;
  final String? riderId;
  final String? riderName;
  final String? riderPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryModel({
    required this.id,
    required this.orderId,
    required this.patientName,
    this.patientPhone = '',
    this.patientAddress = '',
    this.originAddress = '',
    required this.originLocation,
    required this.destinationLocation,
    this.items = '',
    this.total = 0,
    this.status = DeliveryStatus.pending,
    this.riderId,
    this.riderName,
    this.riderPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case DeliveryStatus.pending: return 'Pendiente';
      case DeliveryStatus.accepted: return 'Aceptado';
      case DeliveryStatus.inTransit: return 'En tránsito';
      case DeliveryStatus.delivered: return 'Entregado';
      case DeliveryStatus.cancelled: return 'Cancelado';
    }
  }

  bool get isActive => status == DeliveryStatus.accepted || status == DeliveryStatus.inTransit;

  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'patientName': patientName,
    'patientPhone': patientPhone,
    'patientAddress': patientAddress,
    'originAddress': originAddress,
    'originLocation': originLocation,
    'destinationLocation': destinationLocation,
    'items': items,
    'total': total,
    'status': status.name,
    'riderId': riderId,
    'riderName': riderName,
    'riderPhone': riderPhone,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory DeliveryModel.fromMap(String id, Map<String, dynamic> map) => DeliveryModel(
    id: id,
    orderId: map['orderId'] ?? '',
    patientName: map['patientName'] ?? '',
    patientPhone: map['patientPhone'] ?? '',
    patientAddress: map['patientAddress'] ?? '',
    originAddress: map['originAddress'] ?? '',
    originLocation: map['originLocation'] ?? const GeoPoint(0, 0),
    destinationLocation: map['destinationLocation'] ?? const GeoPoint(0, 0),
    items: map['items'] ?? '',
    total: (map['total'] ?? 0).toDouble(),
    status: DeliveryStatus.values.firstWhere(
      (e) => e.name == map['status'], orElse: () => DeliveryStatus.pending,
    ),
    riderId: map['riderId'],
    riderName: map['riderName'],
    riderPhone: map['riderPhone'],
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  DeliveryModel copyWith({
    DeliveryStatus? status,
    String? riderId,
    String? riderName,
    String? riderPhone,
    GeoPoint? originLocation,
    GeoPoint? destinationLocation,
    DateTime? updatedAt,
  }) => DeliveryModel(
    id: id,
    orderId: orderId,
    patientName: patientName,
    patientPhone: patientPhone,
    patientAddress: patientAddress,
    originAddress: originAddress,
    originLocation: originLocation ?? this.originLocation,
    destinationLocation: destinationLocation ?? this.destinationLocation,
    items: items,
    total: total,
    status: status ?? this.status,
    riderId: riderId ?? this.riderId,
    riderName: riderName ?? this.riderName,
    riderPhone: riderPhone ?? this.riderPhone,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );
}
