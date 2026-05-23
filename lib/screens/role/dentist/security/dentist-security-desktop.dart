import 'package:flutter/material.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-security-dashboard.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-security-stats.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-rfid-card-manager.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-iot-device-control.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-access-control.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-security-alerts.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-contract-status-widget.dart';
import 'package:provider/provider.dart';

class DentistSecurityDesktop extends StatelessWidget {
  final TrackingScrollController scrollController;
  const DentistSecurityDesktop({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return DentistContractStatusWidget(
      dashboard: _buildDashboard(context),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Seguridad'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1D1F),
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          const DentistSecurityDashboard(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
              ),
              delegate: SliverChildListDelegate([
                const _SectionCard('Tarjetas RFID', Icons.credit_card_outlined, Color(0xFF007AFF)),
                const _SectionCard('Dispositivos IoT', Icons.devices_outlined, Color(0xFF5856D6)),
                const _SectionCard('Control de Acceso', Icons.door_front_door_outlined, Color(0xFF34C759)),
                const _SectionCard('Alertas', Icons.notifications_outlined, Color(0xFFFF9500)),
              ]),
            ),
          ),
          const DentistSecurityStats(),
          const DentistRfidCardManager(),
          const DentistIoTDeviceControl(),
          const DentistAccessControl(),
          const DentistSecurityAlerts(),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionCard(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D1D1F),
            ),
          ),
        ],
      ),
    );
  }
}
