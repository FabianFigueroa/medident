import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medident/core/models/delivery/delivery-model.dart';
import 'package:medident/core/models/delivery/delivery-track-model.dart';
import 'package:medident/core/services/delivery/delivery-tracking-service.dart';

const int _bidDurationSeconds = 30;

class DeliveryProvider extends ChangeNotifier {
  final DeliveryTrackingService _service = DeliveryTrackingService();
  final String userId;

  bool _isServiceActive = false;
  bool _isLoading = false;
  String? _error;
  String? userName;

  List<DeliveryModel> _pendingOrders = [];
  List<DeliveryModel> _activeDeliveries = [];
  DeliveryModel? _selectedOrder;
  DeliveryTrack? _currentTrack;

  StreamSubscription? _pendingSub;
  StreamSubscription? _activeSub;
  StreamSubscription? _trackSub;
  StreamSubscription<Position>? _gpsSub;

  final Map<String, Timer> _bidTimers = {};
  final Map<String, int> _bidRemaining = {};

  double _riderLat = 8.7481;
  double _riderLng = -75.8814;

  DeliveryProvider({required this.userId}) {
    _init();
  }

  bool get isServiceActive => _isServiceActive;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DeliveryModel> get pendingOrders => _pendingOrders;
  List<DeliveryModel> get activeDeliveries => _activeDeliveries;
  DeliveryModel? get selectedOrder => _selectedOrder;
  DeliveryTrack? get currentTrack => _currentTrack;
  double get riderLatitude => _riderLat;
  double get riderLongitude => _riderLng;

  int remainingSeconds(String orderId) => _bidRemaining[orderId] ?? _bidDurationSeconds;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _activeSub = _service.streamActiveDeliveries(riderId: userId).listen(
        (deliveries) {
          _activeDeliveries = deliveries;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleService() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.setRiderActive(userId, !_isServiceActive);
      _isServiceActive = !_isServiceActive;

      if (_isServiceActive) {
        _startPendingStream();
        _startGpsTracking();
      } else {
        _pendingSub?.cancel();
        _pendingOrders = [];
        _selectedOrder = null;
        _currentTrack = null;
        _stopGpsTracking();
        _cancelAllTimers();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> activateService() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createRider(userId);
      _isServiceActive = true;
      _startPendingStream();
      _startGpsTracking();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _startPendingStream() {
    _pendingSub?.cancel();
    _pendingSub = _service.streamPendingDeliveries().listen(
      (orders) {
        _pendingOrders = orders;
        for (final order in orders) {
          if (!_bidTimers.containsKey(order.id)) {
            _startBidTimer(order.id);
          }
        }
        _bidTimers.keys.toList().forEach((id) {
          if (!orders.any((o) => o.id == id)) {
            _bidTimers[id]?.cancel();
            _bidTimers.remove(id);
            _bidRemaining.remove(id);
          }
        });
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void _startBidTimer(String orderId) {
    _bidTimers[orderId]?.cancel();
    _bidRemaining[orderId] = _bidDurationSeconds;

    _bidTimers[orderId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = _bidRemaining[orderId] ?? 0;
      if (remaining <= 1) {
        timer.cancel();
        _bidTimers.remove(orderId);
        _bidRemaining.remove(orderId);
        _pendingOrders.removeWhere((o) => o.id == orderId);
        notifyListeners();
      } else {
        _bidRemaining[orderId] = remaining - 1;
        notifyListeners();
      }
    });
  }

  Future<void> _startGpsTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      _riderLat = pos.latitude;
      _riderLng = pos.longitude;
      if (_selectedOrder != null) {
        _service.updateRiderLocation(
          _selectedOrder!.id,
          GeoPoint(pos.latitude, pos.longitude),
        );
      }
      notifyListeners();
    });
  }

  void _stopGpsTracking() {
    _gpsSub?.cancel();
    _gpsSub = null;
  }

  void selectOrder(DeliveryModel order) {
    _selectedOrder = order;
    notifyListeners();
  }

  Future<bool> bidOnOrder(DeliveryModel order) async {
    try {
      await _service.acceptDelivery(
        order.id,
        riderId: userId,
        riderName: 'Domiciliario',
        riderPhone: '',
      );
      _selectedOrder = order;
      _pendingOrders.removeWhere((o) => o.id == order.id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void startTracking(String deliveryId) {
    _trackSub?.cancel();
    _trackSub = _service.streamDeliveryRoute(deliveryId).listen(
      (track) {
        if (track != null) {
          _currentTrack = track;
          if (track.currentLocation != null) {
            _riderLat = track.currentLocation!.latitude;
            _riderLng = track.currentLocation!.longitude;
          }
          notifyListeners();
        }
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void _cancelAllTimers() {
    for (final timer in _bidTimers.values) {
      timer.cancel();
    }
    _bidTimers.clear();
    _bidRemaining.clear();
  }

  void updateRiderPosition(double lat, double lng) {
    _riderLat = lat;
    _riderLng = lng;
    if (_selectedOrder != null) {
      _service.updateRiderLocation(
        _selectedOrder!.id,
        GeoPoint(lat, lng),
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _pendingSub?.cancel();
    _activeSub?.cancel();
    _trackSub?.cancel();
    _stopGpsTracking();
    _cancelAllTimers();
    super.dispose();
  }
}
