import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  final TrackingScrollController _scrollController = TrackingScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const ScreenTrace(
      tag: 'ROLE_EMPLOYEE_HOME',
      message: 'Entrando al home del rol employee. Cargando panel operativo del empleado.',
      role: 'employee',
      child: ResponsiveUtils(
      mobile: EmployeeHomeMobile(),  //scrollController: _scrollController
      tablet: EmployeeHomeTablet(),
      desktop: EmployeeHomeDesktop(),
    ),
    );
  }
}

