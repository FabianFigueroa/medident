import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class EmployeeDeliveryScreen extends StatefulWidget {
  const EmployeeDeliveryScreen({super.key});

  @override
  State<EmployeeDeliveryScreen> createState() => _EmployeeDeliveryScreenState();
}

class _EmployeeDeliveryScreenState extends State<EmployeeDeliveryScreen> {
  @override
  Widget build(BuildContext context) {
    return const ScreenTrace(
      tag: 'ROLE_EMPLOYEE_DELIVERY',
      message: 'Entrando a la pantalla de envios del empleado.',
      role: 'employee',
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_shipping_outlined,
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
                'Entregas y seguimiento',
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
