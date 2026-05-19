import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  NetworkProvider() {
    _checkInitialConnection();
    _connectivitySub = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnection() async {
    await Future.delayed(Duration.zero);
    final result = await _connectivity.checkConnectivity();
    _updateStatusFromResult(result);
    Future.microtask(notifyListeners);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _updateStatusFromResult(result);

    if (wasOnline != _isOnline) {
      notifyListeners();
    }
  }

  void _updateStatusFromResult(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none) || result.isEmpty) {
      _isOnline = false;
    } else {
      _isOnline = true;
    }
  }
}
