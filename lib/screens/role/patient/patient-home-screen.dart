import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final TrackingScrollController _scrollController = TrackingScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_PATIENT_HOME',
      message: 'Entrando al home del rol patient. Cargando panel principal del paciente.',
      role: 'patient',
      child: ResponsiveUtils(
      mobile: HomeScreenMobile(),  //scrollController: _scrollController
      tablet: HomeScreenMobile(),
      desktop: HomeScreenMobile(),
    ),
    );
  }
}

