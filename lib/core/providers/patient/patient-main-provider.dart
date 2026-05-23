import 'package:flutter/material.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/patient/patient-home-provider.dart';
import 'package:medident/core/providers/patient/patient-profile-provider.dart';
import 'package:medident/core/providers/patient/patient-security-provider.dart';
import 'package:medident/core/providers/patient/patient-shop-provider.dart';
import 'package:medident/core/services/patient/patient-home-service.dart';
import 'package:medident/core/services/patient/patient-profile-service.dart';
import 'package:medident/core/services/patient/patient-security-service.dart';
import 'package:medident/core/services/patient/patient-shop-service.dart';

class PatientMainProvider extends MainProviderBase {
  final _homeService = PatientHomeService();
  final _profileService = PatientProfileService();
  final _securityService = PatientSecurityService();
  final _shopService = PatientShopService();

  PatientMainProvider(super.userId) {
    initializeSection('home');
  }

  PatientHomeProvider? get homeProvider =>
      getTypedProvider<PatientHomeProvider>('home');

  PatientProfileProvider? get profileProvider =>
      getTypedProvider<PatientProfileProvider>('profile');

  PatientSecurityProvider? get securityProvider =>
      getTypedProvider<PatientSecurityProvider>('security');

  PatientShopProvider? get shopProvider =>
      getTypedProvider<PatientShopProvider>('shop');

  @override
  Future<ChangeNotifier> createSectionProvider(String section) async {
    switch (section) {
      case 'home':
        final provider = PatientHomeProvider(userId: userId, service: _homeService);
        await provider.loadInitialData();
        return provider;

      case 'profile':
        final provider = PatientProfileProvider(userId: userId, service: _profileService);
        await provider.initialize();
        return provider;

      case 'security':
        final provider = PatientSecurityProvider(userId: userId, service: _securityService);
        await provider.initialize();
        return provider;

      case 'shop':
        final provider = PatientShopProvider(userId: userId, service: _shopService);
        await Future.wait([
          provider.loadProducts(),
          provider.loadPromotions(),
        ]);
        return provider;

      default:
        throw Exception('Sección desconocida: $section');
    }
  }
}
