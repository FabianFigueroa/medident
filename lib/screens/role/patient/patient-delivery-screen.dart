import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/main_export.dart';

class PatientDeliveryScreen extends StatefulWidget {
  const PatientDeliveryScreen({super.key});

  @override
  State<PatientDeliveryScreen> createState() => _PatientDeliveryScreenState();
}

class _PatientDeliveryScreenState extends State<PatientDeliveryScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<PatientMainProvider>();
    final userId = mainProvider.userId;

    if (userId.isEmpty || _initializedForUserId == userId) return;

    _initializedForUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PatientMainProvider>().initializeSection('delivery');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_PATIENT_DELIVERY',
      message: 'Entrando a la pantalla de seguimiento de entregas del paciente.',
      role: 'patient',
      child: Selector<PatientMainProvider, bool>(
        selector: (_, p) => p.isSectionLoading('delivery'),
        builder: (context, isLoading, _) {
          if (isLoading) {
            return Scaffold(body: _buildScreenShimmer());
          }

          final mainProvider = context.watch<PatientMainProvider>();
          final error = mainProvider.getSectionError('delivery');

          if (error != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Error al cargar entregas: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => mainProvider.initializeSection('delivery'),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final deliveryProvider = mainProvider.deliveryProvider;

          if (deliveryProvider == null) {
            return Scaffold(body: _buildScreenShimmer());
          }

          // El nombre del paciente se resuelve aquí (AuthGate solo pasa userId).
          final authUser = context.read<AuthenticateProvider>().user;
          if (deliveryProvider.patientName.trim().isEmpty &&
              (authUser?.fullName ?? '').trim().isNotEmpty &&
              !deliveryProvider.isLoading) {
            deliveryProvider.patientName = authUser!.fullName.trim();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) deliveryProvider.loadDeliveries();
            });
          }

          return ChangeNotifierProvider.value(
            value: deliveryProvider,
            child: ScreenTrace(
              tag: 'ROLE_PATIENT_DELIVERY',
              message: 'Panel de entregas del paciente listo para renderizar.',
              role: 'patient',
              child: ResponsiveUtils(
                mobile: const _DeliveryContent(),
                tablet: const _DeliveryContent(),
                desktop: const _DeliveryContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreenShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _DeliveryContent extends StatelessWidget {
  const _DeliveryContent();

  @override
  Widget build(BuildContext context) {
    // En desktop/tablet se centra con ancho maximo para no estirar el contenido.
    final content = _buildScaffold(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: content,
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final provider = context.watch<PatientDeliveryProvider>();
    final deliveries = provider.deliveries;
    final stats = provider.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Mis Entregas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF008080), Color(0xFF20B2AA)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => provider.loadDeliveries(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadDeliveries(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCards(stats),
            const SizedBox(height: 20),
            const Text(
              'Mis Pedidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (deliveries.isEmpty && !provider.showDemoOverview)
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.local_shipping, color: Colors.grey, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'Aún no tienes pedidos en camino',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cuando compres en la tienda, tus entregas aparecerán aquí.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              ...deliveries.map((delivery) => _DeliveryCard(delivery: delivery)),
            ],
            if (provider.showDemoOverview) ...[
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFFE0F7F7),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xFF008080), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vista general de entregas recientes en la plataforma (demo).',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.teal[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...provider.recentDeliveries
                  .map((delivery) => _DeliveryCard(delivery: delivery)),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, int> stats) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Pendientes',
            count: stats['pending'] ?? 0,
            color: const Color(0xFFF59E0B),
            icon: Icons.hourglass_empty,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'En curso',
            count: stats['active'] ?? 0,
            color: const Color(0xFF3B82F6),
            icon: Icons.local_shipping,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Entregados',
            count: stats['delivered'] ?? 0,
            color: const Color(0xFF10B981),
            icon: Icons.task_alt,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final Map<String, dynamic> delivery;

  const _DeliveryCard({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientDeliveryProvider>();
    final status = (delivery['status'] ?? 'pending').toString();
    final address = (delivery['patientAddress'] ?? delivery['address'] ?? 'Sin dirección').toString();
    final items = delivery['items'];
    final itemsList = (items is List) ? items : <dynamic>[];
    final riderName = (delivery['riderName'] ?? delivery['employeeName'] ?? '').toString();
    final total = delivery['total'];
    final id = (delivery['id'] ?? '').toString();

    (Color, String) statusMeta;
    switch (status) {
      case 'accepted':
        statusMeta = (const Color(0xFF3B82F6), 'Aceptado');
        break;
      case 'inTransit':
        statusMeta = (const Color(0xFF3B82F6), 'En tránsito');
        break;
      case 'delivered':
        statusMeta = (const Color(0xFF10B981), 'Entregado');
        break;
      case 'cancelled':
        statusMeta = (const Color(0xFFEF4444), 'Cancelado');
        break;
      default:
        statusMeta = (const Color(0xFFF59E0B), 'Pendiente');
    }
    final statusColor = statusMeta.$1;
    final statusLabel = statusMeta.$2;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF008080), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (riderName.isNotEmpty)
              Text(
                'Repartidor: $riderName',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            if (total != null)
              Text(
                'Total: \$${(total as num).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF008080),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pedido #${id.length > 8 ? id.substring(0, 8) : id}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
            if (itemsList.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(
                'Artículos: ${itemsList.join(', ')}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
            if (status == 'pending' || status == 'inTransit') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status == 'inTransit')
                    ElevatedButton.icon(
                      onPressed: () => provider.confirmReceived(id),
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Recibido'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  if (status == 'inTransit') const SizedBox(width: 8),
                  if (status == 'pending' || status == 'inTransit')
                    OutlinedButton.icon(
                      onPressed: () => _confirmCancel(context, provider, id),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmCancel(
    BuildContext context,
    PatientDeliveryProvider provider,
    String id,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar pedido'),
        content: const Text(
          '¿Seguro que deseas cancelar esta entrega? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              provider.cancelDelivery(id);
            },
            child: const Text(
              'Cancelar pedido',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}
