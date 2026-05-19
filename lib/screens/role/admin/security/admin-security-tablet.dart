import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/core/providers/admin/admin-security-provider.dart';

class AdminSecurityTablet extends StatelessWidget {
  const AdminSecurityTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().securityProvider;
    if (provider == null) return const SizedBox();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: RefreshIndicator(
        onRefresh: () => provider.refreshData(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildOverview(provider),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAlertsSection(provider)),
                const SizedBox(width: 16),
                Expanded(child: _buildAccessLogsSection(provider)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(AdminSecurityProvider p) {
    final overview = p.securityOverview;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Seguridad y monitoreo', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16, runSpacing: 16,
          children: [
            _overviewChip('Personal', '${overview['totalStaff'] ?? 0}', Icons.badge, Colors.white.withValues(alpha: 0.2)),
            _overviewChip('Alertas', '${overview['activeAlerts'] ?? 0}', Icons.notifications_active, Colors.white.withValues(alpha: 0.2)),
            _overviewChip('Zonas seguras', '${overview['secureZones'] ?? 0}', Icons.shield, Colors.white.withValues(alpha: 0.2)),
            _overviewChip('Incidentes hoy', '${overview['incidentsToday'] ?? 0}', Icons.warning, Colors.white.withValues(alpha: 0.2)),
          ],
        ),
      ]),
    );
  }

  Widget _overviewChip(String label, String value, IconData icon, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text('$label: $value', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildAlertsSection(AdminSecurityProvider p) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Alertas recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (p.recentAlerts.isEmpty)
          const Text('Sin alertas recientes', style: TextStyle(color: Colors.grey))
        else
          ...p.recentAlerts.take(5).map((alert) => ListTile(
            dense: true,
            leading: Icon(Icons.notifications_active, color: Colors.orange.shade700, size: 20),
            title: Text(alert['title'] ?? alert['id'] ?? 'Alerta', style: const TextStyle(fontSize: 14)),
            subtitle: Text(alert['timestamp']?.toString() ?? ''),
          )),
      ]),
    );
  }

  Widget _buildAccessLogsSection(AdminSecurityProvider p) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Registros de acceso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (p.accessLogs.isEmpty)
          const Text('Sin registros de acceso', style: TextStyle(color: Colors.grey))
        else
          ...p.accessLogs.take(5).map((log) => ListTile(
            dense: true,
            leading: const Icon(Icons.fingerprint, color: Color(0xFF7C3AED), size: 20),
            title: Text(log['user'] ?? log['id'] ?? 'Acceso', style: const TextStyle(fontSize: 14)),
            subtitle: Text(log['timestamp']?.toString() ?? ''),
          )),
      ]),
    );
  }
}
