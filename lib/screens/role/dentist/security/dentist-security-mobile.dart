import 'package:flutter/material.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-security-dashboard.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-security-stats.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-rfid-card-manager.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-iot-device-control.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-access-control.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-security-alerts.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-contract-status-widget.dart';
import 'package:medident/screens/widgets/appbar/appbar-center.dart';
import 'package:provider/provider.dart';

class DentistSecurityMobile extends StatelessWidget {
  const DentistSecurityMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return DentistContractStatusWidget(
      dashboard: _buildDashboard(context),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final provider = context.watch<DentistSecurityProvider>();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 251, 251),
      // appBar: Appbar_Center_Widget(
      //   title: 'Seguridad IoT',
      //   backgroundColor: const Color.fromARGB(255, 212, 84, 84),
      // ),
      body: RefreshIndicator(
        color: const Color(0xFF007AFF),
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
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
