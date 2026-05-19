import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthenticateProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF008080), Color(0xFF20B2AA)]),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text((user?.fullName ?? 'P')[0],
                        style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Text(user?.fullName ?? 'Paciente',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _profileOption(icon: Icons.person, title: 'Editar Perfil', subtitle: 'Actualizar información personal', onTap: () {}),
                  _profileOption(icon: Icons.calendar_today, title: 'Mis Citas', subtitle: 'Ver citas programadas', onTap: () {}),
                  _profileOption(icon: Icons.history, title: 'Historial Clínico', subtitle: 'Ver registros médicos', onTap: () {}),
                  _profileOption(icon: Icons.face, title: 'Mi Odontograma', subtitle: 'Ver estado dental', onTap: () {}),
                  _profileOption(icon: Icons.notifications, title: 'Notificaciones', subtitle: 'Configurar alertas', onTap: () {}),
                  _profileOption(icon: Icons.settings, title: 'Configuración', subtitle: 'Preferencias de la cuenta', onTap: () {}),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.read<AuthenticateProvider>().signOut(),
                      icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                      label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF008080).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF008080), size: 24),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
