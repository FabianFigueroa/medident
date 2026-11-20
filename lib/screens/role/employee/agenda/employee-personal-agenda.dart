import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/employee/employee-main-provider.dart';
import 'package:medident/screens/role/dentist/agenda/dentist-personal-agenda.dart';

class EmployeeAgendaScreen extends StatelessWidget {
  const EmployeeAgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.read<EmployeeMainProvider>();
    return ChangeNotifierProvider<MainProviderBase>.value(
      value: mainProvider,
      child: const PersonalAgendaView(
        title: 'Agenda de la clínica',
        clinicSection: 'clinic',
      ),
    );
  }
}

class EmployeeTurnosScreen extends StatelessWidget {
  const EmployeeTurnosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.read<EmployeeMainProvider>();
    return ChangeNotifierProvider<MainProviderBase>.value(
      value: mainProvider,
      child: const PersonalTurnosView(title: 'Mis turnos laborales'),
    );
  }
}
