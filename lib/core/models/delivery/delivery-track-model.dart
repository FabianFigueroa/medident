import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryTrackPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const DeliveryTrackPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  GeoPoint get geoPoint => GeoPoint(latitude, longitude);

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory DeliveryTrackPoint.fromMap(Map<String, dynamic> map) => DeliveryTrackPoint(
    latitude: (map['latitude'] ?? 0).toDouble(),
    longitude: (map['longitude'] ?? 0).toDouble(),
    timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  factory DeliveryTrackPoint.fromGeoPoint(GeoPoint gp, {DateTime? timestamp}) =>
    DeliveryTrackPoint(
      latitude: gp.latitude,
      longitude: gp.longitude,
      timestamp: timestamp ?? DateTime.now(),
    );
}

class DeliveryTrack {
  final String deliveryId;
  final List<DeliveryTrackPoint> route;
  final int currentIndex;
  final DeliveryTrackPoint? currentLocation;

  const DeliveryTrack({
    required this.deliveryId,
    this.route = const [],
    this.currentIndex = 0,
    this.currentLocation,
  });

  bool get isMoving => currentIndex < route.length - 1;
  DeliveryTrackPoint? get nextPoint => isMoving ? route[currentIndex + 1] : null;
  DeliveryTrackPoint? get origin => route.isNotEmpty ? route.first : null;
  DeliveryTrackPoint? get destination => route.isNotEmpty ? route.last : null;

  Map<String, dynamic> toMap() => {
    'deliveryId': deliveryId,
    'route': route.map((p) => p.toMap()).toList(),
    'currentIndex': currentIndex,
    if (currentLocation != null) 'currentLocation': currentLocation!.toMap(),
  };

  factory DeliveryTrack.fromMap(String deliveryId, Map<String, dynamic> map) {
    final routeList = (map['route'] as List<dynamic>?)
        ?.map((e) => DeliveryTrackPoint.fromMap(e as Map<String, dynamic>))
        .toList() ?? [];
    final currentLoc = map['currentLocation'] != null
        ? DeliveryTrackPoint.fromMap(map['currentLocation'] as Map<String, dynamic>)
        : null;
    return DeliveryTrack(
      deliveryId: deliveryId,
      route: routeList,
      currentIndex: (map['currentIndex'] ?? 0) as int,
      currentLocation: currentLoc,
    );
  }
}
