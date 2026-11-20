import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/dentist/dentist-profile-provider.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/core/providers/dentist/dentist-clinic-provider.dart';
import 'package:medident/core/providers/dentist/dentist-delivery-provider.dart';
import 'package:medident/core/providers/dentist/dentist-agenda-provider.dart';
import 'package:medident/core/providers/dentist/dentist-turnos-provider.dart';
import 'package:medident/core/services/domain/empty-appointment-service.dart';
import 'package:medident/core/services/clinic/clinic-appointment-service.dart';
import 'package:medident/core/services/agenda-service.dart';
import 'package:medident/core/services/patient-service.dart';
import 'package:medident/core/services/dentist/dentist-home-services.dart';
import 'package:medident/core/services/dentist/dentist-security-services.dart';
import 'package:medident/core/services/clinic-service.dart';

class DentistMainProvider extends MainProviderBase {
  final _homeService = DentistHomeService();
  final _securityService = DentistSecurityService();
  final _clinicService = ClinicService();
  final _agendaService = AgendaService();
  final _patientService = PatientService();

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
  DentistClinicProvider? get clinicStatusProvider =>
      getTypedProvider<DentistClinicProvider>('clinicStatus');
  DentistDeliveryProvider? get deliveryProvider =>
      getTypedProvider<DentistDeliveryProvider>('delivery');
  DentistAgendaProvider? get personalAgendaProvider =>
      getTypedProvider<DentistAgendaProvider>('agenda');
  DentistTurnosProvider? get personalTurnosProvider =>
      getTypedProvider<DentistTurnosProvider>('turnos');

  /// Resuelve el clinicId desde el sub-provider de clínica o, si aún no se
  /// cargó, directamente desde el usuario autenticado en Firestore.
  Future<String> _resolveClinicId() async {
    final status = getTypedProvider<DentistClinicProvider>('clinicStatus');
    final cachedId = status?.clinic?.id;
    if (cachedId != null && cachedId.isNotEmpty) return cachedId;
    final clinics = await _clinicService.getClinicsForUser(userId);
    return clinics.isEmpty ? '' : clinics.first.id;
  }

  @override
  Future<ChangeNotifier> createSectionProvider(String section) async {
    switch (section) {
      case 'home':
        // El feed del home es general (posts de usuarios y clinicas), no se
        // limita a la clinica del usuario.
        final provider = DentistHomeProvider(service: _homeService, userId: userId);
        // No bloquear el arranque: pinta cache/streams y notifica cuando llegue.
        unawaited(provider.loadInitialData());
        return provider;

      case 'clinic':
        final statusP = getTypedProvider<DentistClinicProvider>('clinicStatus');
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
        final provider = DentistClinicProvider(service: _clinicService);
        await provider.checkClinicStatus(userId);
        return provider;

      case 'agenda':
        final clinicId = await _resolveClinicId();
        if (clinicId.isEmpty) {
          return DentistAgendaProvider(
            userId: userId,
            clinicId: '',
            appointmentService: EmptyAppointmentService(),
            patientService: _patientService,
          );
        }
        return DentistAgendaProvider(
          userId: userId,
          clinicId: clinicId,
          appointmentService: ClinicAppointmentService(
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

      case 'profile':
        final provider = DentistProfileProvider(userId: userId);
        await provider.initialize();
        return provider;

      case 'security':
        final provider = DentistSecurityProvider(userId, _securityService);
        provider.initializeStreams();
        return provider;

      case 'delivery':
        final provider = DentistDeliveryProvider(userId: userId);
        await provider.loadDeliveries();
        return provider;

      default:
        throw Exception('Sección desconocida: $section');
    }
  }
}

