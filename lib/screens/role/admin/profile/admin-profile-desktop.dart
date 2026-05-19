import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/core/providers/admin/admin-profile-provider.dart';

class AdminProfileDesktop extends StatelessWidget {
  const AdminProfileDesktop({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().profileProvider;
    if (provider == null) return const SizedBox();
    final profile = provider.profile;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
                      child: Column(children: [
                        const CircleAvatar(child: Icon(Icons.admin_panel_settings, size: 60), radius: 50),
                        const SizedBox(height: 16),
                        Text(profile['name'] ?? 'Administrador', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(profile['email'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const Divider(height: 32),
                        _infoRow(Icons.phone, 'Telefono', profile['phone'] ?? 'No registrado'),
                        const SizedBox(height: 12),
                        _infoRow(Icons.badge, 'Rol', profile['role'] ?? 'admin'),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Registro de auditoria', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...provider.auditLog.map((log) => ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(log['action'] ?? ''),
                        subtitle: Text(log['timestamp']?.toString() ?? ''),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [Icon(icon, color: Colors.grey), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(value, style: const TextStyle(fontSize: 16))])]);
  }
}
