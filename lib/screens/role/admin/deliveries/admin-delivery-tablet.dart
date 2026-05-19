import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/core/providers/admin/admin-delivery-provider.dart';

class AdminDeliveryTablet extends StatelessWidget {
  const AdminDeliveryTablet({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().deliveryProvider;
    if (provider == null) return const SizedBox();
    final stats = provider.deliveryStats;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Entregas'), backgroundColor: const Color(0xFF111827)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatCard('Total', '${stats['totalDeliveries']}', Icons.local_shipping),
                  const SizedBox(height: 12),
                  _buildStatCard('Pendientes', '${stats['pendingDeliveries']}', Icons.pending),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: provider.pendingDeliveries.map((d) => ListTile(
                  title: Text(d['id'] ?? ''),
                  subtitle: Text(d['status'] ?? ''),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: ListTile(leading: Icon(icon), title: Text(value), subtitle: Text(label)),
    );
  }
}
