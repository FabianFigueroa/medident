import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/core/providers/admin/admin-profile-provider.dart';

class AdminProfileTablet extends StatelessWidget {
  const AdminProfileTablet({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().profileProvider;
    if (provider == null) return const SizedBox();
    final profile = provider.profile;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Perfil'), backgroundColor: const Color(0xFF111827)),
      body: Center(
        child: SizedBox(
          width: 600,
          child: Column(
            children: [
              const SizedBox(height: 24),
              const CircleAvatar(child: Icon(Icons.admin_panel_settings, size: 50), radius: 50),
              const SizedBox(height: 16),
              Text(profile['name'] ?? 'Admin', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text(profile['email'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 24),
              Card(margin: const EdgeInsets.all(16), child: Column(children: [
                ListTile(leading: const Icon(Icons.phone), title: Text(profile['phone'] ?? 'No registrado'), subtitle: const Text('Telefono')),
                const Divider(),
                ListTile(leading: const Icon(Icons.badge), title: Text(profile['role'] ?? 'admin'), subtitle: const Text('Rol')),
              ])),
            ],
          ),
        ),
      ),
    );
  }
}
