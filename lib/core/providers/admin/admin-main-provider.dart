import 'package:flutter/material.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/admin/admin-home-provider.dart';
import 'package:medident/core/providers/admin/admin-security-provider.dart';
import 'package:medident/core/providers/admin/admin-delivery-provider.dart';
import 'package:medident/core/providers/admin/admin-profile-provider.dart';
import 'package:medident/core/providers/admin/admin-shops-provider.dart';
import 'package:medident/core/services/admin/admin-home-service.dart';
import 'package:medident/core/services/admin/admin-security-service.dart';
import 'package:medident/core/services/admin/admin-delivery-service.dart';
import 'package:medident/core/services/admin/admin-profile-service.dart';
import 'package:medident/core/services/admin/admin-shops-service.dart';

class AdminMainProvider extends MainProviderBase {
  final _homeService = AdminHomeService();
  final _securityService = AdminSecurityService();
  final _deliveryService = AdminDeliveryService();
  final _profileService = AdminProfileService();
  final _shopsService = AdminShopsService();

  AdminMainProvider(super.userId) {
    initializeSection('home');
  }

  AdminHomeProvider? get homeProvider =>
      getTypedProvider<AdminHomeProvider>('home');
  AdminSecurityProvider? get securityProvider =>
      getTypedProvider<AdminSecurityProvider>('security');
  AdminDeliveryProvider? get deliveryProvider =>
      getTypedProvider<AdminDeliveryProvider>('delivery');
  AdminProfileProvider? get profileProvider =>
      getTypedProvider<AdminProfileProvider>('profile');
  AdminShopsProvider? get shopsProvider =>
      getTypedProvider<AdminShopsProvider>('shops');

  @override
  Future<ChangeNotifier> createSectionProvider(String section) async {
    switch (section) {
      case 'home':
        final provider = AdminHomeProvider(userId: userId, service: _homeService);
        provider.loadInitialData();
        return provider;

      case 'security':
        final provider = AdminSecurityProvider(userId: userId, service: _securityService);
        await provider.loadInitialData();
        return provider;

      case 'delivery':
        final provider = AdminDeliveryProvider(userId: userId, service: _deliveryService);
        await provider.loadInitialData();
        return provider;

      case 'profile':
        final provider = AdminProfileProvider(userId: userId, service: _profileService);
        await provider.loadInitialData();
        return provider;

      case 'shops':
        final provider = AdminShopsProvider(userId: userId, service: _shopsService);
        await provider.loadInitialData();
        return provider;

      default:
        throw Exception('Sección desconocida: $section');
    }
  }
}
