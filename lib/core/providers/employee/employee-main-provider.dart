import 'package:flutter/material.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/employee/employee-home-provider.dart';
import 'package:medident/core/providers/employee/employee-profile-provider.dart';
import 'package:medident/core/providers/employee/employee-security-provider.dart';
import 'package:medident/core/providers/employee/employee-delivery-provider.dart';
import 'package:medident/core/services/employee/employee-home-service.dart';
import 'package:medident/core/services/employee/employee-profile-service.dart';
import 'package:medident/core/services/employee/employee-security-service.dart';

class EmployeeMainProvider extends MainProviderBase {
  final _homeService = EmployeeHomeService();
  final _profileService = EmployeeProfileService();
  final _securityService = EmployeeSecurityService();

  EmployeeMainProvider(super.userId) {
    initializeSection('home');
  }

  EmployeeHomeProvider? get homeProvider =>
      getTypedProvider<EmployeeHomeProvider>('home');
  EmployeeProfileProvider? get profileProvider =>
      getTypedProvider<EmployeeProfileProvider>('profile');
  EmployeeSecurityProvider? get securityProvider =>
      getTypedProvider<EmployeeSecurityProvider>('security');
  EmployeeDeliveryProvider? get deliveryProvider =>
      getTypedProvider<EmployeeDeliveryProvider>('delivery');

  @override
  Future<ChangeNotifier> createSectionProvider(String section) async {
    switch (section) {
      case 'home':
        final provider = EmployeeHomeProvider(userId: userId, service: _homeService);
        await provider.loadInitialData();
        return provider;

      case 'profile':
        final provider = EmployeeProfileProvider(userId: userId, service: _profileService);
        await provider.initialize();
        return provider;

      case 'security':
        final provider = EmployeeSecurityProvider(userId: userId, service: _securityService);
        await provider.initialize();
        return provider;

      case 'delivery':
        final provider = EmployeeDeliveryProvider(userId: userId);
        await provider.loadDeliveries();
        return provider;

      default:
        throw Exception('Sección desconocida: $section');
    }
  }
}
