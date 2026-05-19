import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/core/providers/admin/admin-shops-provider.dart';

class AdminShopsMobile extends StatelessWidget {
  const AdminShopsMobile({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().shopsProvider;
    if (provider == null) return const SizedBox();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Tiendas'), backgroundColor: const Color(0xFF111827)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStats(provider),
          const SizedBox(height: 16),
          const Text('Tiendas pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...provider.pendingShops.map((s) => Card(
            child: ListTile(
              title: Text(s['name'] ?? s['id'] ?? ''),
              subtitle: Text(s['status'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => provider.approveShop(s['id'])),
                  IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => provider.rejectShop(s['id'])),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStats(AdminShopsProvider p) {
    final stats = p.shopsOverview;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Total: ${stats['totalShops']}', style: const TextStyle(fontSize: 18)),
            Text('Pendientes: ${stats['pendingApprovals']}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
