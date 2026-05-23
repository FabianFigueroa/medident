import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medident/core/models/contract-request-model.dart';
import 'package:medident/core/services/admin/admin-contract-service.dart';

enum AdminContractTab { pending, approved, rejected, active }

class AdminContractProvider with ChangeNotifier {
  final AdminContractService _service = AdminContractService();
  final String userId;

  AdminContractTab _currentTab = AdminContractTab.pending;
  List<ContractRequestModel> _allRequests = [];
  bool _isLoading = false;
  String? _error;

  AdminContractProvider({required this.userId});

  AdminContractTab get currentTab => _currentTab;
  List<ContractRequestModel> get allRequests => _allRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ContractRequestModel> get pendingRequests =>
      _allRequests.where((r) => r.status == ContractRequestStatus.pending_review).toList();

  List<ContractRequestModel> get approvedRequests =>
      _allRequests.where((r) => r.status == ContractRequestStatus.approved).toList();

  List<ContractRequestModel> get rejectedRequests =>
      _allRequests.where((r) => r.status == ContractRequestStatus.rejected).toList();

  List<ContractRequestModel> get activeSubscriptions =>
      _allRequests.where((r) => r.status == ContractRequestStatus.approved).toList();

  void setTab(AdminContractTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void startListening() {
    _isLoading = true;
    notifyListeners();

    _service.streamAllRequests().listen((requests) {
      _allRequests = requests;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> approveRequest(String requestId, {String? notes}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _service.approveRequest(requestId, userId, notes: notes);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectRequest(String requestId, {String? notes}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _service.rejectRequest(requestId, userId, notes: notes);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deactivateSubscription(String targetUserId,
      {String? notes, required String reason}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _service.deactivateSubscription(targetUserId, userId,
          notes: notes, reason: reason);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reactivateSubscription(String targetUserId) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _service.reactivateSubscription(targetUserId, userId);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<DocumentSnapshot> streamUserSecurityDoc(String uid) {
    return _service.streamSecurityDoc(uid);
  }
}
