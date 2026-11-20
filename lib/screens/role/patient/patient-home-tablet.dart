import 'package:flutter/material.dart';
import 'package:medident/screens/role/patient/patient-home-mobile.dart';

class PatientHomeTablet extends StatelessWidget {
  const PatientHomeTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: const PatientHomeMobile(),
      ),
    );
  }
}
