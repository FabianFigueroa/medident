import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/delivery/delivery-model.dart';
import 'package:medident/core/models/delivery/delivery-track-model.dart';
import 'package:medident/core/services/delivery/osrm-route-service.dart';

class DeliveryTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DeliveryModel?> streamDelivery(String deliveryId) {
    return _firestore
        .collection('deliveries')
        .doc(deliveryId)
        .snapshots()
        .map((snap) => snap.exists ? DeliveryModel.fromMap(snap.id, Map<String, dynamic>.from(snap.data() ?? {})) : null);
  }

  Stream<List<DeliveryModel>> streamActiveDeliveries({String? riderId}) {
    var query = _firestore
        .collection('deliveries')
        .where('status', whereIn: ['accepted', 'inTransit'])
        .orderBy('updatedAt', descending: true);

    if (riderId != null) {
      query = query.where('riderId', isEqualTo: riderId);
    }

    return query.snapshots().map((snap) =>
        snap.docs.map((d) => DeliveryModel.fromMap(d.id, Map<String, dynamic>.from(d.data()))).toList());
  }

  Stream<List<DeliveryModel>> streamPendingDeliveries() {
    return _firestore
        .collection('deliveries')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DeliveryModel.fromMap(d.id, Map<String, dynamic>.from(d.data()))).toList());
  }

  Future<void> acceptDelivery(String deliveryId, {required String riderId, required String riderName, required String riderPhone}) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'status': 'accepted',
      'riderId': riderId,
      'riderName': riderName,
      'riderPhone': riderPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> startDelivery(String deliveryId) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'status': 'inTransit',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeDelivery(String deliveryId) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'status': 'delivered',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelDelivery(String deliveryId) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setRiderActive(String userId, bool isActive) async {
    await _firestore.collection('riders').doc(userId).update({'isActive': isActive});
  }

  Future<void> createRider(String userId) async {
    final riderRef = _firestore.collection('riders').doc(userId);
    final riderDoc = await riderRef.get();
    if (!riderDoc.exists) {
      await riderRef.set({
        'userId': userId,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await riderRef.update({'isActive': true});
    }
  }

  Future<void> updateRiderLocation(String deliveryId, GeoPoint location) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'currentLocation': location,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setRoute(String deliveryId, List<DeliveryTrackPoint> route) async {
    await _firestore.collection('deliveryRoutes').doc(deliveryId).set({
      'deliveryId': deliveryId,
      'route': route.map((p) => p.toMap()).toList(),
      'currentIndex': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> advanceRoute(String deliveryId, int nextIndex) async {
    await _firestore.collection('deliveryRoutes').doc(deliveryId).update({
      'currentIndex': nextIndex,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DeliveryTrack?> streamDeliveryRoute(String deliveryId) {
    return _firestore
        .collection('deliveryRoutes')
        .doc(deliveryId)
        .snapshots()
        .map((snap) => snap.exists
            ? DeliveryTrack.fromMap(snap.id, Map<String, dynamic>.from(snap.data() ?? {}))
            : null);
  }

  Future<List<DeliveryTrackPoint>> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final osrm = OsrmRouteService();
      return await osrm.getRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );
    } catch (e) {
      final points = <DeliveryTrackPoint>[];
      final steps = 20;
      for (var i = 0; i <= steps; i++) {
        final t = i / steps;
        points.add(DeliveryTrackPoint(
          latitude: originLat + (destLat - originLat) * t,
          longitude: originLng + (destLng - originLng) * t,
          timestamp: DateTime.now(),
        ));
      }
      return points;
    }
  }
}
