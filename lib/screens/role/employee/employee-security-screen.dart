import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class EmployeeSecurityScreen extends StatefulWidget {
  const EmployeeSecurityScreen({super.key});

  @override
  State<EmployeeSecurityScreen> createState() => _EmployeeSecurityScreenState();
}

class _EmployeeSecurityScreenState extends State<EmployeeSecurityScreen> {
  @override
  Widget build(BuildContext context) {
    return const ScreenTrace(
      tag: 'ROLE_EMPLOYEE_SECURITY',
      message: 'Entrando a la pantalla de seguridad del empleado.',
      role: 'employee',
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 64,
                color: Color(0xFFCBD5E1),
              ),
              SizedBox(height: 16),
              Text(
                'Seguridad',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                  fontFamily: 'Ubuntu-Bold',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Control de acceso y seguridad',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                  fontFamily: 'Ubuntu-Regular',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
