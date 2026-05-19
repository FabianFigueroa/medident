import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:medident/core/models/delivery/delivery-model.dart';
import 'package:medident/core/models/delivery/delivery-track-model.dart';
import 'package:medident/core/services/delivery/delivery-tracking-service.dart';

class DeliveryTrackingProvider extends ChangeNotifier {
  final DeliveryTrackingService _service = DeliveryTrackingService();

  DeliveryModel? _currentDelivery;
  DeliveryTrack? _currentTrack;
  List<DeliveryModel> _activeDeliveries = [];
  List<DeliveryModel> _pendingDeliveries = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _deliverySub;
  StreamSubscription? _routeSub;
  StreamSubscription? _activeSub;

  DeliveryModel? get currentDelivery => _currentDelivery;
  DeliveryTrack? get currentTrack => _currentTrack;
  List<DeliveryModel> get activeDeliveries => _activeDeliveries;
  List<DeliveryModel> get pendingDeliveries => _pendingDeliveries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void trackDelivery(String deliveryId) {
    _deliverySub?.cancel();
    _routeSub?.cancel();
    _deliverySub = _service.streamDelivery(deliveryId).listen((delivery) {
      _currentDelivery = delivery;
      notifyListeners();
    });
    _routeSub = _service.streamDeliveryRoute(deliveryId).listen((track) {
      _currentTrack = track;
      notifyListeners();
    });
  }

  void watchActiveDeliveries({String? riderId}) {
    _activeSub?.cancel();
    _activeSub = _service.streamActiveDeliveries(riderId: riderId).listen((list) {
      _activeDeliveries = list;
      notifyListeners();
    });
  }

  Future<void> loadPendingDeliveries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _pendingDeliveries = await _service.streamPendingDeliveries().first;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> acceptDelivery(String deliveryId, {required String riderId, required String riderName, required String riderPhone}) async {
    try {
      await _service.acceptDelivery(deliveryId, riderId: riderId, riderName: riderName, riderPhone: riderPhone);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> startDelivery(String deliveryId) async {
    try {
      await _service.startDelivery(deliveryId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeDelivery(String deliveryId) async {
    try {
      await _service.completeDelivery(deliveryId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> generateAndSetRoute({
    required String deliveryId,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final route = await _service.getRoute(
      originLat: originLat, originLng: originLng,
      destLat: destLat, destLng: destLng,
    );
    await _service.setRoute(deliveryId, route);
  }

  @override
  void dispose() {
    _deliverySub?.cancel();
    _routeSub?.cancel();
    _activeSub?.cancel();
    super.dispose();
  }
}
