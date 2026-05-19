import 'package:flutter/material.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/core/services/admin/admin-home-service.dart';

class AdminHomeProvider with ChangeNotifier {
  final AdminHomeService _service;
  final String userId;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _moderationQueue = [];
  List<Map<String, dynamic>> _activityFeed = [];
  List<Map<String, dynamic>> _pendingApprovals = [];
  List<ProductModel> _globalPromotions = [];
  List<Map<String, dynamic>> _reels = [];

  AdminHomeProvider({
    required this.userId,
    AdminHomeService? service,
  }) : _service = service ?? AdminHomeService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<Map<String, dynamic>> get moderationQueue => _moderationQueue;
  List<Map<String, dynamic>> get activityFeed => _activityFeed;
  List<Map<String, dynamic>> get pendingApprovals => _pendingApprovals;
  List<ProductModel> get globalPromotions => _globalPromotions;
  List<Map<String, dynamic>> get reels => _reels;

  Future<void> loadInitialData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getDashboardStats(),
        _service.getModerationQueue(),
        _service.getActivityFeed(),
        _service.getPendingApprovals(),
        _service.getGlobalPromotions(),
        _service.getReels(),
      ]);

      _dashboardStats = results[0] as Map<String, dynamic>;
      _moderationQueue = results[1] as List<Map<String, dynamic>>;
      _activityFeed = results[2] as List<Map<String, dynamic>>;
      _pendingApprovals = results[3] as List<Map<String, dynamic>>;
      _globalPromotions = results[4] as List<ProductModel>;
      _reels = results[5] as List<Map<String, dynamic>>;
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminHomeProvider.loadInitialData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    _error = null;
    notifyListeners();
    await loadInitialData();
  }

  Future<void> createPromotion(Map<String, dynamic> data) async {
    await _service.createGlobalPromotion(data);
    await _service.getGlobalPromotions().then((list) {
      _globalPromotions = list;
      notifyListeners();
    });
  }

  Future<void> deletePromotion(String id) async {
    await _service.deletePromotion(id);
    _globalPromotions.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> createReel(Map<String, dynamic> data) async {
    await _service.createReel(data);
    await _service.getReels().then((list) {
      _reels = list;
      notifyListeners();
    });
  }

  Future<void> deleteReel(String id) async {
    await _service.deleteReel(id);
    _reels.removeWhere((r) => r['id'] == id);
    notifyListeners();
  }
}
