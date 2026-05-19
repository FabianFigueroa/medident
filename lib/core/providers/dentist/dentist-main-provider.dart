import 'package:flutter/material.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/dentist/dentist-profile-provider.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/core/providers/clinic/clinic-provider.dart';
import 'package:medident/core/providers/delivery/delivery-provider.dart';
import 'package:medident/core/services/dentist/dentist-home-services.dart';
import 'package:medident/core/services/dentist/dentist-security-services.dart';
import 'package:medident/core/services/clinic-service.dart';

class DentistMainProvider extends MainProviderBase {
  final _homeService = DentistHomeService();
  final _securityService = DentistSecurityService();
  final _clinicService = ClinicService();

  DentistMainProvider(super.userId) {
    initializeSection('home');
  }

  DentistHomeProvider? get homeProvider =>
      getTypedProvider<DentistHomeProvider>('home');
  DentistProfileProvider? get profileProvider =>
      getTypedProvider<DentistProfileProvider>('profile');
  DentistSecurityProvider? get dentistSecurityProvider =>
      getTypedProvider<DentistSecurityProvider>('security');
  DentistHomeProvider? get clinicProvider =>
      getTypedProvider<DentistHomeProvider>('clinic');
  ClinicProvider? get clinicStatusProvider =>
      getTypedProvider<ClinicProvider>('clinicStatus');
  DeliveryProvider? get deliveryProvider =>
      getTypedProvider<DeliveryProvider>('delivery');

  @override
  Future<ChangeNotifier> createSectionProvider(String section) async {
    switch (section) {
      case 'home':
        final statusP = getTypedProvider<ClinicProvider>('clinicStatus');
        final provider = DentistHomeProvider(service: _homeService, userId: userId, clinicId: statusP?.clinic?.id);
        provider.loadInitialData();
        return provider;

      case 'clinic':
        final statusP = getTypedProvider<ClinicProvider>('clinicStatus');
        final cid = statusP?.clinic?.id;
        final home = DentistHomeProvider(service: _homeService, userId: userId, clinicId: cid);
        await Future.wait([
          home.loadAppointments(),
          home.loadTurnos(),
          home.loadTreatments(),
          home.loadOdontograms(),
        ]);
        return home;

      case 'clinicStatus':
        final provider = ClinicProvider(service: _clinicService);
        await provider.checkClinicStatus(userId);
        return provider;

      case 'profile':
        final provider = DentistProfileProvider(userId: userId);
        await provider.initialize();
        return provider;

      case 'security':
        final provider = DentistSecurityProvider(userId, _securityService);
        provider.initializeStreams();
        return provider;

      case 'delivery':
        final provider = DeliveryProvider(userId: userId);
        return provider;

      default:
        throw Exception('Sección desconocida: $section');
    }
  }
}
