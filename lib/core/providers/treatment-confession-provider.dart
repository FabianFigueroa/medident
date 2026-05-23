import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/models/treatment-confession-model.dart';
import 'package:medident/core/services/treatment-confession-service.dart';

class TreatmentConfessionProvider extends ChangeNotifier {
  final TreatmentConfessionService _service;

  List<TreatmentConfessionModel> _confessions = [];
  bool _isLoading = false;
  StreamSubscription? _sub;

  TreatmentConfessionProvider({TreatmentConfessionService? service})
      : _service = service ?? TreatmentConfessionService();

  List<TreatmentConfessionModel> get confessions => _confessions;
  List<TreatmentConfessionModel> get approvedConfessions =>
      _confessions.where((c) => c.isApproved).toList();
  List<TreatmentConfessionModel> get pendingConfessions =>
      _confessions.where((c) => !c.isApproved).toList();
  bool get isLoading => _isLoading;
  int get pendingCount => _confessions.where((c) => !c.isApproved).length;

  void subscribe(String clinicId) {
    _sub?.cancel();
    _isLoading = true;
    notifyListeners();
    _sub = _service.streamByClinic(clinicId, onlyApproved: false).listen((list) {
      _confessions = list;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<String> create(TreatmentConfessionModel confession) async {
    final id = await _service.create(confession);
    return id;
  }

  Future<void> approve(String id) async {
    await _service.updateApproval(id, true);
  }

  Future<void> reject(String id) async {
    await _service.delete(id);
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
