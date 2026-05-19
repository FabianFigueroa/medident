import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class AdminSecurityScreen extends StatelessWidget {
  const AdminSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenTrace(
      tag: 'ROLE_ADMIN_SECURITY',
      message:
          'Entrando a la pantalla Security del rol admin. Preparando monitoreo, accesos, zonas y alertas.',
      role: 'admin',
      child: ResponsiveUtils(
        mobile: SecurityTemperaturePage(),
        tablet: AdminSecurityTablet(),
        desktop: AdminSecurityDesktop(),
      ),
    );
  }
}
