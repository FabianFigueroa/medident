import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/doctor/doctor-delivery-provider.dart';
import 'package:medident/core/providers/doctor/doctor-home-provider.dart';
import 'package:medident/core/providers/doctor/doctor-profile-provider.dart';
import 'package:medident/core/providers/doctor/doctor-security-provider.dart';
import 'package:medident/core/providers/doctor/doctor-shop-provider.dart';
import 'package:medident/core/providers/dentist/dentist-clinic-provider.dart';
import 'package:medident/core/providers/dentist/dentist-agenda-provider.dart';
import 'package:medident/core/providers/dentist/dentist-turnos-provider.dart';
import 'package:medident/core/services/agenda-service.dart';
import 'package:medident/core/services/clinic-service.dart';
import 'package:medident/core/services/clinic/clinic-appointment-service.dart';
import 'package:medident/core/services/domain/empty-appointment-service.dart';
import 'package:medident/core/services/patient-service.dart';
import 'package:medident/core/services/doctor/doctor-delivery-service.dart';
import 'package:medident/core/services/doctor/doctor-home-service.dart';
import 'package:medident/core/services/doctor/doctor-profile-service.dart';
import 'package:medident/core/services/doctor/doctor-security-service.dart';
import 'package:medident/core/services/doctor/doctor-shop-service.dart';

class DoctorMainProvider extends MainProviderBase {
  final _homeService = DoctorHomeService();
  final _profileService = DoctorProfileService();
  final _securityService = DoctorSecurityService();
  final _shopService = DoctorShopService();
  final _deliveryService = DoctorDeliveryService();
  final _clinicService = ClinicService();
  final _agendaService = AgendaService();
  final _patientService = PatientService();

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

  DoctorDeliveryProvider? get deliveryProvider =>
      getTypedProvider<DoctorDeliveryProvider>('delivery');

  DentistClinicProvider? get clinicProvider =>
      getTypedProvider<DentistClinicProvider>('clinic');

  DentistAgendaProvider? get personalAgendaProvider =>
      getTypedProvider<DentistAgendaProvider>('agenda');

  DentistTurnosProvider? get personalTurnosProvider =>
      getTypedProvider<DentistTurnosProvider>('turnos');

  Future<String> _resolveClinicId() async {
    final clinics = await _clinicService.getClinicsForUser(userId);
    return clinics.isEmpty ? '' : clinics.first.id;
  }

  @override
  Future<ChangeNotifier> createSectionProvider(String section) async {
    switch (section) {
      case 'home':
        final provider = DoctorHomeProvider(
          service: _homeService,
          userId: userId,
        );
        unawaited(provider.loadInitialData());
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

      case 'delivery':
        final provider = DoctorDeliveryProvider(
          userId: userId,
          service: _deliveryService,
        );
        await provider.loadDeliveries();
        return provider;

      case 'clinic':
        final provider = DentistClinicProvider(service: _clinicService);
        await provider.checkClinicStatus(userId);
        return provider;

      case 'agenda':
        final clinicId = await _resolveClinicId();
        return DentistAgendaProvider(
          userId: userId,
          clinicId: clinicId,
          scope: AgendaScope.dentist,
          appointmentService: clinicId.isEmpty
              ? EmptyAppointmentService()
              : ClinicAppointmentService(
                  clinicId: clinicId,
                  clinicService: _clinicService,
                ),
          patientService: _patientService,
        );

      case 'turnos':
        return DentistTurnosProvider(
          userId: userId,
          service: _agendaService,
        );

      default:
        throw Exception('Sección desconocida: $section');
    }
  }
}
