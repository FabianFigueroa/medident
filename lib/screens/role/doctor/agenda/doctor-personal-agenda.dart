import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/doctor/doctor-main-provider.dart';
import 'package:medident/screens/role/dentist/agenda/dentist-personal-agenda.dart';

class DoctorAgendaScreen extends StatelessWidget {
  const DoctorAgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.read<DoctorMainProvider>();
    return ChangeNotifierProvider<MainProviderBase>.value(
      value: mainProvider,
      child: const PersonalAgendaView(
        title: 'Mi agenda',
        clinicSection: 'clinic',
      ),
    );
  }
}

class DoctorTurnosScreen extends StatelessWidget {
  const DoctorTurnosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.read<DoctorMainProvider>();
    return ChangeNotifierProvider<MainProviderBase>.value(
      value: mainProvider,
      child: const PersonalTurnosView(title: 'Mis turnos laborales'),
    );
  }
}
