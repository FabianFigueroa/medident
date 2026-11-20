import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class DeliverySecurityScreen extends StatefulWidget {
  const DeliverySecurityScreen({super.key});

  @override
  State<DeliverySecurityScreen> createState() => _DeliverySecurityScreenState();
}

class _DeliverySecurityScreenState extends State<DeliverySecurityScreen> {
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
      context.read<DeliveryMainProvider>().initializeSection('security');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DeliveryMainProvider, bool>(
      selector: (_, p) => p.isSectionLoading('security'),
      builder: (context, isLoading, _) {
        final mainProvider = context.watch<DeliveryMainProvider>();
        final error = mainProvider.getSectionError('security');

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
                  Text('Error al cargar seguridad: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => mainProvider.initializeSection('security'),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final securityProvider = mainProvider.securityProvider;
        if (securityProvider == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return ChangeNotifierProvider.value(
          value: securityProvider,
          child: const _SecurityContent(),
        );
      },
    );
  }
}

class _SecurityContent extends StatelessWidget {
  const _SecurityContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryProfileProvider>();
    final homeProvider = context.watch<DeliveryMainProvider>().homeProvider;
    final userName =
        provider.user?['fullName'] ?? homeProvider?.userName ?? 'Domiciliario';
    final isActive = provider.isServiceActive;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Seguridad',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Estado del servicio (riders.isActive en Firestore)
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isActive ? Colors.green : Colors.grey)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.wifi_tethering,
                      color: isActive ? const Color(0xFF10B981) : Colors.grey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isActive
                              ? 'Servicio de domicilios activo'
                              : 'Servicio de domicilios inactivo',
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive
                                ? const Color(0xFF10B981)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isActive,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) {
                      provider.toggleServiceStatus(v);
                      final delivery = context.read<DeliveryMainProvider>().homeProvider;
                      if (delivery != null) {
                        v ? delivery.activateService() : delivery.toggleService();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Estadísticas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'En curso',
                  value: '${provider.inProgressCount}',
                  icon: Icons.local_shipping,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Completadas',
                  value: '${provider.completedCount}',
                  icon: Icons.task_alt,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Protocolo de seguridad',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.phone_in_talk,
            color: const Color(0xFF3B82F6),
            text:
                'Botón de emergencia 123 disponible en todo momento. Ante un riesgo, cancela la entrega.',
          ),
          _TipCard(
            icon: Icons.location_on,
            color: const Color(0xFF10B981),
            text:
                'Tu ubicación se comparte mientras haya una entrega en curso (GPS con precisión alta).',
          ),
          _TipCard(
            icon: Icons.shield_outlined,
            color: const Color(0xFFF59E0B),
            text:
                'Verifica siempre el destinatario antes de entregar el pedido. No entregues sin confirmación.',
          ),
          _TipCard(
            icon: Icons.nightlight_round,
            color: const Color(0xFF1E293B),
            text:
                'Evita rutas riesgosas de noche. Si algo se siente inseguro, detén el servicio desde el switch.',
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

class _TipCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _TipCard({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
