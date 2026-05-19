import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class EmployeeShopScreen extends StatefulWidget {
  const EmployeeShopScreen({super.key});

  @override
  State<EmployeeShopScreen> createState() => _EmployeeShopScreenState();
}

class _EmployeeShopScreenState extends State<EmployeeShopScreen> {
  @override
  Widget build(BuildContext context) {
    return const ScreenTrace(
      tag: 'ROLE_EMPLOYEE_SHOP',
      message: 'Entrando a la pantalla de tienda del empleado.',
      role: 'employee',
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store_outlined,
                size: 64,
                color: Color(0xFFCBD5E1),
              ),
              SizedBox(height: 16),
              Text(
                'Próximamente',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                  fontFamily: 'Ubuntu-Bold',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tienda del empleado',
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
