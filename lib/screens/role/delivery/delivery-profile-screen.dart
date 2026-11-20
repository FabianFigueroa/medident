import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class DeliveryProfileScreen extends StatefulWidget {
  const DeliveryProfileScreen({super.key});

  @override
  State<DeliveryProfileScreen> createState() => _DeliveryProfileScreenState();
}

class _DeliveryProfileScreenState extends State<DeliveryProfileScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<DeliveryMainProvider>();
    final userId = mainProvider.userId;

    if (userId.isEmpty || _initializedForUserId == userId) return;

    _initializedForUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DeliveryMainProvider>().initializeSection('profile');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DeliveryMainProvider, bool>(
      selector: (_, p) => p.isSectionLoading('profile'),
      builder: (context, isLoading, _) {
        final mainProvider = context.watch<DeliveryMainProvider>();
        final error = mainProvider.getSectionError('profile');

        if (isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error al cargar perfil: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => mainProvider.initializeSection('profile'),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final profileProvider = mainProvider.profileProvider;
        if (profileProvider == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return ChangeNotifierProvider.value(
          value: profileProvider,
          child: const _ProfileContent(),
        );
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryProfileProvider>();
    final user = context.watch<AuthenticateProvider>().user;
    final fullName =
        (provider.user?['fullName'] ?? user?.fullName ?? 'Domiciliario') as String;
    final email = (provider.user?['email'] ?? user?.email ?? '') as String;
    final phone = (provider.user?['phoneNumber'] ?? user?.phoneNumber ?? '') as String;
    final imageUrl = (provider.user?['imageUrl'] ?? user?.imageUrl ?? '') as String;
    final hasImage = imageUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red, size: 20),
            onPressed: () => context.read<AuthenticateProvider>().signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey[300],
              backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
              child: !hasImage
                  ? Icon(Icons.person, size: 48, color: Colors.grey[500])
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(email, style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(height: 20),
          // Estado rápido del rider (riders.isActive, editable aquí)
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: SwitchListTile(
                value: provider.isServiceActive,
                activeColor: const Color(0xFF10B981),
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Servicio de domicilios',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  provider.isServiceActive ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    color: provider.isServiceActive
                        ? const Color(0xFF10B981)
                        : Colors.grey[600],
                  ),
                ),
                secondary: Icon(
                  Icons.wifi_tethering,
                  color: provider.isServiceActive
                      ? const Color(0xFF10B981)
                      : Colors.grey,
                ),
                onChanged: (v) => provider.toggleServiceStatus(v),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Mi actividad',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Entregas en curso',
                  value: '${provider.inProgressCount}',
                  icon: Icons.local_shipping,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Entregas completadas',
                  value: '${provider.completedCount}',
                  icon: Icons.task_alt,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _ListTileInfo(
                  icon: Icons.phone,
                  title: 'Teléfono',
                  value: phone.isEmpty ? 'Sin teléfono' : phone,
                ),
                const Divider(height: 1),
                _ListTileInfo(
                  icon: Icons.badge,
                  title: 'Rol',
                  value: 'Domiciliario',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                provider.error!,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
              ),
            ),
          Center(
            child: Text(
              'Cuenta verificada • Medident',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTileInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ListTileInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: const Color(0xFF1E293B), size: 20),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
      ),
    );
  }
}
