import 'package:flutter/material.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/doctor/doctor-home-provider.dart';
import 'package:medident/core/providers/doctor/doctor-profile-provider.dart';
import 'package:medident/core/providers/doctor/doctor-security-provider.dart';
import 'package:medident/core/providers/doctor/doctor-shop-provider.dart';
import 'package:medident/core/services/doctor/doctor-home-service.dart';
import 'package:medident/core/services/doctor/doctor-profile-service.dart';
import 'package:medident/core/services/doctor/doctor-security-service.dart';
import 'package:medident/core/services/doctor/doctor-shop-service.dart';

class DoctorMainProvider extends MainProviderBase {
  final _homeService = DoctorHomeService();
  final _profileService = DoctorProfileService();
  final _securityService = DoctorSecurityService();
  final _shopService = DoctorShopService();

  DoctorMainProvider(super.userId) {
    initializeSection('home');
  }

  DoctorHomeProvider? get homeProvider =>
      getTypedProvider<DoctorHomeProvider>('home');
  DoctorProfileProvider? get profileProvider =>
      getTypedProvider<DoctorProfileProvider>('profile');
  DoctorSecurityProvider? get securityProvider =>
      getTypedProvider<DoctorSecurityProvider>('security');
  DoctorShopProvider? get shopProvider =>
      getTypedProvider<DoctorShopProvider>('shop');

  @override
  Future<ChangeNotifier> createSectionProvider(String section) async {
    switch (section) {
      case 'home':
        final provider = DoctorHomeProvider(
          service: _homeService,
          userId: userId,
        );
        await provider.loadInitialData();
        return provider;

      case 'profile':
        final provider = DoctorProfileProvider(
          service: _profileService,
          userId: userId,
        );
        await provider.initialize();
        return provider;

      case 'security':
        final provider = DoctorSecurityProvider(
          service: _securityService,
          userId: userId,
        );
        provider.initialize();
        return provider;

      case 'shop':
        final provider = DoctorShopProvider(service: _shopService);
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
