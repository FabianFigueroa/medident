import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final TrackingScrollController _scrollController = TrackingScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const ScreenTrace(
      tag: 'ROLE_DOCTOR_HOME',
      message: 'Entrando al home del rol doctor. Cargando panel principal del medico.',
      role: 'doctor',
      child: ResponsiveUtils(
      mobile: DoctorHomeMobile(),  //scrollController: _scrollController
      tablet: DoctorHomeMobile(),
      desktop: DoctorHomeMobile(),
    ),
    );
  }
}

