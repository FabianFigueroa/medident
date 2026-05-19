import 'package:flutter/material.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/employee/employee-home-provider.dart';
import 'package:medident/core/services/employee/employee-home-service.dart';

class EmployeeMainProvider extends MainProviderBase {
  final _homeService = EmployeeHomeService();

  EmployeeMainProvider(super.userId) {
    initializeSection('home');
  }

  EmployeeHomeProvider? get homeProvider =>
      getTypedProvider<EmployeeHomeProvider>('home');

  @override
  Future<ChangeNotifier> createSectionProvider(String section) async {
    switch (section) {
      case 'home':
        final provider = EmployeeHomeProvider(userId: userId, service: _homeService);
        provider.loadInitialData();
        return provider;

      default:
        throw Exception('Sección desconocida: $section');
    }
  }
}
