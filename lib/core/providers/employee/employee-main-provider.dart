import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/employee/employee-home-provider.dart';
import 'package:medident/core/providers/employee/employee-profile-provider.dart';
import 'package:medident/core/providers/employee/employee-security-provider.dart';
import 'package:medident/core/providers/employee/employee-delivery-provider.dart';
import 'package:medident/core/providers/dentist/dentist-clinic-provider.dart';
import 'package:medident/core/providers/dentist/dentist-agenda-provider.dart';
import 'package:medident/core/providers/dentist/dentist-turnos-provider.dart';
import 'package:medident/core/services/agenda-service.dart';
import 'package:medident/core/services/clinic-service.dart';
import 'package:medident/core/services/clinic/clinic-appointment-service.dart';
import 'package:medident/core/services/domain/empty-appointment-service.dart';
import 'package:medident/core/services/patient-service.dart';
import 'package:medident/core/services/employee/employee-home-service.dart';
import 'package:medident/core/services/employee/employee-profile-service.dart';
import 'package:medident/core/services/employee/employee-security-service.dart';

class EmployeeMainProvider extends MainProviderBase {
  final _homeService = EmployeeHomeService();
  final _profileService = EmployeeProfileService();
  final _securityService = EmployeeSecurityService();
  final _clinicService = ClinicService();
  final _agendaService = AgendaService();
  final _patientService = PatientService();

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
        final provider = EmployeeHomeProvider(userId: userId, service: _homeService);
        unawaited(provider.loadInitialData());
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

      case 'clinic':
        final provider = DentistClinicProvider(service: _clinicService);
        await provider.checkClinicStatus(userId);
        return provider;

      case 'agenda':
        final clinicId = await _resolveClinicId();
        return DentistAgendaProvider(
          userId: userId,
          clinicId: clinicId,
          scope: AgendaScope.clinic,
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
