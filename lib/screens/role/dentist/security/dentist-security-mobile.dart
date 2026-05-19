import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-contract-acceptance.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-security-dashboard.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-security-stats.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-rfid-card-manager.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-iot-device-control.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-access-control.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-security-alerts.dart';

class DentistSecurityMobile extends StatelessWidget {
  const DentistSecurityMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DentistSecurityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Ocurrió un error: ${provider.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (provider.dentistSecurityModel == null ||
            provider.dentistSecurityModel!.contractStatus != 'active') {
          return const ContractAcceptanceWidget();
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshData(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const DentistSecurityDashboard(),
              const DentistSecurityStats(),
              const DentistRfidCardManager(),
              const DentistIoTDeviceControl(),
              const DentistAccessControl(),
              const DentistSecurityAlerts(),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }
}
