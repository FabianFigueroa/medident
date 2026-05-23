import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ContractRequestStatus {
  pending_review,
  approved,
  rejected,
  suspended;

  String get label {
    switch (this) {
      case ContractRequestStatus.pending_review:
        return 'Pendiente de revisión';
      case ContractRequestStatus.approved:
        return 'Aprobado';
      case ContractRequestStatus.rejected:
        return 'Rechazado';
      case ContractRequestStatus.suspended:
        return 'Suspendido';
    }
  }
}

class ContractRequestModel {
  final String? id;
  final String userId;
  final String dentistName;
  final String dentistEmail;
  final String? dentistPhone;
  final DateTime installationDate;
  final TimeOfDay installationTime;
  final String? signatureBase64;
  final ContractRequestStatus status;
  final DateTime createdAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? adminNotes;
  final DateTime? subscriptionExpiresAt;
  final String? lastPaymentId;

  ContractRequestModel({
    this.id,
    required this.userId,
    required this.dentistName,
    required this.dentistEmail,
    this.dentistPhone,
    required this.installationDate,
    required this.installationTime,
    this.signatureBase64,
    this.status = ContractRequestStatus.pending_review,
    DateTime? createdAt,
    this.reviewedBy,
    this.reviewedAt,
    this.adminNotes,
    this.subscriptionExpiresAt,
    this.lastPaymentId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ContractRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return ContractRequestModel(
      id: id,
      userId: map['userId'] ?? '',
      dentistName: map['dentistName'] ?? '',
      dentistEmail: map['dentistEmail'] ?? '',
      dentistPhone: map['dentistPhone'],
      installationDate: (map['installationDate'] as Timestamp).toDate(),
      installationTime: _parseTimeOfDay(map['installationHour'] as int, map['installationMinute'] as int),
      signatureBase64: map['signatureBase64'],
      status: _parseStatus(map['status'] as String?),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      reviewedBy: map['reviewedBy'],
      reviewedAt: (map['reviewedAt'] as Timestamp?)?.toDate(),
      adminNotes: map['adminNotes'],
      subscriptionExpiresAt: (map['subscriptionExpiresAt'] as Timestamp?)?.toDate(),
      lastPaymentId: map['lastPaymentId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dentistName': dentistName,
      'dentistEmail': dentistEmail,
      'dentistPhone': dentistPhone,
      'installationDate': Timestamp.fromDate(installationDate),
      'installationHour': installationTime.hour,
      'installationMinute': installationTime.minute,
      'signatureBase64': signatureBase64,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'adminNotes': adminNotes,
      'subscriptionExpiresAt': subscriptionExpiresAt != null ? Timestamp.fromDate(subscriptionExpiresAt!) : null,
      'lastPaymentId': lastPaymentId,
    };
  }

  static ContractRequestStatus _parseStatus(String? status) {
    return ContractRequestStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => ContractRequestStatus.pending_review,
    );
  }

  static TimeOfDay _parseTimeOfDay(int hour, int minute) {
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  String get installationTimeFormatted {
    final h = installationTime.hour.toString().padLeft(2, '0');
    final m = installationTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get installationDateFormatted {
    return '${installationDate.day}/${installationDate.month}/${installationDate.year}';
  }

  Map<String, dynamic> toJson() => toMap();

  String toJsonString() => jsonEncode(toMap());
}
