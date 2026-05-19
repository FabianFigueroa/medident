import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/core/providers/admin/admin-delivery-provider.dart';

class AdminDeliveryDesktop extends StatelessWidget {
  const AdminDeliveryDesktop({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().deliveryProvider;
    if (provider == null) return const SizedBox();
    final stats = provider.deliveryStats;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gestion de Entregas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              const SizedBox(height: 24),
              Row(
                children: [
                  _infoCard('Total entregas', '${stats['totalDeliveries']}', Icons.local_shipping, const Color(0xFF1D4ED8)),
                  const SizedBox(width: 16),
                  _infoCard('Pendientes', '${stats['pendingDeliveries']}', Icons.pending, const Color(0xFFEA580C)),
                  const SizedBox(width: 16),
                  _infoCard('Completadas hoy', '${stats['completedToday']}', Icons.check_circle, const Color(0xFF0F766E)),
                  const SizedBox(width: 16),
                  _infoCard('Repartidores activos', '${stats['activeRiders']}', Icons.pedal_bike, const Color(0xFF7C3AED)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Entregas pendientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...provider.pendingDeliveries.map((d) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(title: Text(d['id'] ?? ''), subtitle: Text(d['status'] ?? ''), leading: const Icon(Icons.local_shipping)),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ]),
      ),
    );
  }
}
