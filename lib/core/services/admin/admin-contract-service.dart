import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/contract-request-model.dart';

class AdminContractService {
  final CollectionReference _contractRequests =
      FirebaseFirestore.instance.collection('contract_requests');

  final CollectionReference _admins =
      FirebaseFirestore.instance.collection('admins');

  final CollectionReference _security =
      FirebaseFirestore.instance.collection('security');

  Stream<List<ContractRequestModel>> streamAllRequests() {
    return _contractRequests
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                ContractRequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<ContractRequestModel>> streamRequestsByStatus(
      ContractRequestStatus status) {
    return _contractRequests
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                ContractRequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<ContractRequestModel?> streamRequestByUserId(String userId) {
    return _contractRequests
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return ContractRequestModel.fromMap(
          snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
    });
  }

  Future<DocumentReference> createRequest(ContractRequestModel request) async {
    return _contractRequests.add(request.toMap());
  }

  Future<void> approveRequest(String requestId, String adminUid,
      {String? notes}) async {
    final now = DateTime.now();
    final expiresAt = DateTime(now.year, now.month + 1, now.day);
    final batch = FirebaseFirestore.instance.batch();

    final requestRef = _contractRequests.doc(requestId);
    batch.update(requestRef, {
      'status': ContractRequestStatus.approved.name,
      'reviewedBy': adminUid,
      'reviewedAt': Timestamp.fromDate(now),
      'adminNotes': notes,
      'subscriptionExpiresAt': Timestamp.fromDate(expiresAt),
    });

    final requestSnap = await requestRef.get();
    final data = requestSnap.data() as Map<String, dynamic>;
    final userId = data['userId'] as String;

    final securityRef = _security.doc(userId);
    batch.set(securityRef, {
      'contract-status': 'active',
      'subscriptionExpiresAt': Timestamp.fromDate(expiresAt),
      'lastPaymentDate': Timestamp.fromDate(now),
      'paymentStatus': 'paid',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> rejectRequest(String requestId, String adminUid,
      {String? notes}) async {
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();

    final requestRef = _contractRequests.doc(requestId);
    batch.update(requestRef, {
      'status': ContractRequestStatus.rejected.name,
      'reviewedBy': adminUid,
      'reviewedAt': Timestamp.fromDate(now),
      'adminNotes': notes,
    });

    final requestSnap = await requestRef.get();
    final data = requestSnap.data() as Map<String, dynamic>;
    final userId = data['userId'] as String;

    final securityRef = _security.doc(userId);
    batch.set(securityRef, {
      'contract-status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> deactivateSubscription(String userId, String adminUid,
      {String? notes, required String reason}) async {
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();

    final requestsSnap = await _contractRequests
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: [
      ContractRequestStatus.approved.name,
      ContractRequestStatus.suspended.name,
    ]).get();

    for (final doc in requestsSnap.docs) {
      batch.update(doc.reference, {
        'status': ContractRequestStatus.suspended.name,
        'reviewedBy': adminUid,
        'reviewedAt': Timestamp.fromDate(now),
        'adminNotes': notes ?? reason,
        'subscriptionExpiresAt': null,
      });
    }

    final securityRef = _security.doc(userId);
    batch.set(securityRef, {
      'contract-status': 'suspended',
      'suspensionReason': reason,
      'suspendedAt': Timestamp.fromDate(now),
      'suspendedBy': adminUid,
      'subscriptionExpiresAt': null,
      'paymentStatus': 'unpaid',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> reactivateSubscription(String userId, String adminUid) async {
    final now = DateTime.now();
    final expiresAt = DateTime(now.year, now.month + 1, now.day);
    final batch = FirebaseFirestore.instance.batch();

    final requestsSnap = await _contractRequests
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: ContractRequestStatus.suspended.name)
        .get();

    for (final doc in requestsSnap.docs) {
      batch.update(doc.reference, {
        'status': ContractRequestStatus.approved.name,
        'reviewedBy': adminUid,
        'reviewedAt': Timestamp.fromDate(now),
        'subscriptionExpiresAt': Timestamp.fromDate(expiresAt),
      });
    }

    final securityRef = _security.doc(userId);
    batch.set(securityRef, {
      'contract-status': 'active',
      'subscriptionExpiresAt': Timestamp.fromDate(expiresAt),
      'paymentStatus': 'paid',
      'suspensionReason': null,
      'suspendedAt': null,
      'suspendedBy': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<List<String>> getAdminUids() async {
    final snap = await _admins.get();
    return snap.docs.map((doc) => doc.id).toList();
  }

  Stream<DocumentSnapshot> streamSecurityDoc(String userId) {
    return _security.doc(userId).snapshots();
  }
}
