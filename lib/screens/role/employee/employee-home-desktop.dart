import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/role/employee/employee-home-mobile.dart';

class EmployeeHomeDesktop extends StatelessWidget {
  const EmployeeHomeDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: const EmployeeHomeMobile(),
      ),
    );
  }
}
