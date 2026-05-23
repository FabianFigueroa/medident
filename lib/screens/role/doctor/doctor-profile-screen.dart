import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/doctor/doctor-main-provider.dart';
import 'package:medident/core/providers/doctor/doctor-profile-provider.dart';
import 'package:medident/core/utils/responsive.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<DoctorMainProvider>().initializeSection('profile');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorMainProvider>(
      builder: (context, mainProvider, child) {
        if (mainProvider.isSectionLoading('profile') ||
            mainProvider.profileProvider == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final error = mainProvider.getSectionError('profile');
        if (error != null) {
          return Scaffold(
            body: Center(child: Text('Error al cargar perfil: $error')),
          );
        }

        return ChangeNotifierProvider.value(
          value: mainProvider.profileProvider!,
          child: ResponsiveUtils(
            mobile: const _DoctorProfileBody(),
            tablet: const _DoctorProfileBody(),
            desktop: const _DoctorProfileBody(),
          ),
        );
      },
    );
  }
}

class _DoctorProfileBody extends StatelessWidget {
  const _DoctorProfileBody();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<DoctorProfileProvider>().userProfile;
    final fullName = profile?['fullName'] as String? ?? 'Doctor';
    final email = profile?['email'] as String? ?? '';
    final initial = (fullName.isNotEmpty ? fullName[0] : 'D').toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(initial,
                        style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Text('Dr(a). $fullName',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(email,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _profileOption(
                      icon: Icons.person,
                      title: 'Editar Perfil',
                      subtitle: 'Actualizar información personal',
                      onTap: () {}),
                  _profileOption(
                      icon: Icons.calendar_today,
                      title: 'Mi Agenda',
                      subtitle: 'Gestionar citas y horarios',
                      onTap: () {}),
                  _profileOption(
                      icon: Icons.history,
                      title: 'Historial Médico',
                      subtitle: 'Ver registros de pacientes',
                      onTap: () {}),
                  _profileOption(
                      icon: Icons.notifications,
                      title: 'Notificaciones',
                      subtitle: 'Configurar alertas',
                      onTap: () {}),
                  _profileOption(
                      icon: Icons.settings,
                      title: 'Configuración',
                      subtitle: 'Preferencias de la cuenta',
                      onTap: () {}),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.read<AuthenticateProvider>().signOut(),
                      icon: const Icon(Icons.logout,
                          color: Colors.red, size: 20),
                      label: const Text('Cerrar Sesión',
                          style: TextStyle(color: Colors.red)),
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
          decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 24),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
