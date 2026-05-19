import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/core/providers/admin/admin-shops-provider.dart';

class AdminShopsTablet extends StatelessWidget {
  const AdminShopsTablet({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().shopsProvider;
    if (provider == null) return const SizedBox();
    final stats = provider.shopsOverview;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Tiendas'), backgroundColor: const Color(0xFF111827)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _statCard('Total tiendas', '${stats['totalShops']}', Icons.store, const Color(0xFF1D4ED8)),
                const SizedBox(height: 12),
                _statCard('Pendientes', '${stats['pendingApprovals']}', Icons.pending, const Color(0xFFEA580C)),
              ]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...provider.pendingShops.map((s) => Card(
                    child: ListTile(
                      title: Text(s['name'] ?? s['id'] ?? ''),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => provider.approveShop(s['id'])),
                        IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => provider.rejectShop(s['id'])),
                      ]),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [Icon(icon, color: color), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text(label)])]),
      ),
    );
  }
}
