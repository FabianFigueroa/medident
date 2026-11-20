import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/base/main-provider-base.dart';
import 'package:medident/core/providers/patient/patient-main-provider.dart';
import 'package:medident/screens/role/dentist/agenda/dentist-personal-agenda.dart';

class PatientAgendaScreen extends StatelessWidget {
  const PatientAgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.read<PatientMainProvider>();
    return ChangeNotifierProvider<MainProviderBase>.value(
      value: mainProvider,
      child: const PersonalAgendaView(
        title: 'Mis citas',
        allowCreate: false,
      ),
    );
  }
}
