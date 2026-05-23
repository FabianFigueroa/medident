import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class AdminDeliveryMobile extends StatelessWidget {
  const AdminDeliveryMobile({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().deliveryProvider;
    if (provider == null) return const SizedBox();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Entregas'), backgroundColor: const Color(0xFF111827)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCard(provider),
          const SizedBox(height: 16),
          const Text('Entregas pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...provider.pendingDeliveries.map((d) => ListTile(title: Text(d['id'] ?? ''), subtitle: Text(d['status'] ?? ''))),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AdminDeliveryProvider p) {
    final stats = p.deliveryStats;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Total: ${stats['totalDeliveries']}', style: const TextStyle(fontSize: 16)),
            Text('Pendientes: ${stats['pendingDeliveries']}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
