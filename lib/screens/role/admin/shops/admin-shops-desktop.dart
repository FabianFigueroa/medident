import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/core/providers/admin/admin-shops-provider.dart';

class AdminShopsDesktop extends StatelessWidget {
  const AdminShopsDesktop({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().shopsProvider;
    if (provider == null) return const SizedBox();
    final stats = provider.shopsOverview;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Gestion de Tiendas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const SizedBox(height: 24),
            Row(children: [
              _statCard('Total tiendas', '${stats['totalShops']}', Icons.store, const Color(0xFF1D4ED8)),
              const SizedBox(width: 16),
              _statCard('Pendientes', '${stats['pendingApprovals']}', Icons.pending, const Color(0xFFEA580C)),
              const SizedBox(width: 16),
              _statCard('Activas', '${stats['activeShops']}', Icons.check_circle, const Color(0xFF0F766E)),
              const SizedBox(width: 16),
              _statCard('Productos', '${stats['totalProducts']}', Icons.inventory, const Color(0xFF7C3AED)),
            ]),
            const SizedBox(height: 24),
            const Text('Tiendas pendientes de aprobacion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...provider.pendingShops.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(s['name'] ?? s['id'] ?? 'Sin nombre'),
                subtitle: Text(s['status'] ?? ''),
                leading: const Icon(Icons.store, color: Color(0xFF1D4ED8)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  ElevatedButton.icon(
                    onPressed: () => provider.approveShop(s['id']),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Aprobar'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => provider.rejectShop(s['id']),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ]),
              ),
            )),
            const SizedBox(height: 24),
            const Text('Tiendas activas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...provider.activeShops.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(s['name'] ?? s['id'] ?? 'Sin nombre'),
                subtitle: Text(s['email'] ?? ''),
                leading: const Icon(Icons.storefront, color: Color(0xFF0F766E)),
              ),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
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
