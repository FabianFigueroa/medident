import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/dentist/dentist-clinic-provider.dart';
import 'package:medident/screens/role/dentist/clinic/onboarding/clinic-onboarding-screen.dart';
import 'package:medident/screens/role/dentist/clinic/widgets/dentist_clinic_dashboard.dart';
import 'package:medident/screens/role/dentist/clinic/widgets/clinic-shimmer-error.dart';

class DentistClinicMobile extends StatelessWidget {
  const DentistClinicMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<DentistClinicProvider, ClinicStatus>((p) => p.status);
    switch (status) {
      case ClinicStatus.checking:
        return const ClinicShimmer();
      case ClinicStatus.noClinic:
        return const ClinicOnboardingScreen();
      case ClinicStatus.owner:
      case ClinicStatus.employee:
        return DentistClinic_Dashboard();
      case ClinicStatus.error:
        return ClinicErrorWidget();
    }
  }
}
