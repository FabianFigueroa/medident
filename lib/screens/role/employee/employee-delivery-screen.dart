import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class EmployeeDeliveryScreen extends StatefulWidget {
  const EmployeeDeliveryScreen({super.key});

  @override
  State<EmployeeDeliveryScreen> createState() => _EmployeeDeliveryScreenState();
}

class _EmployeeDeliveryScreenState extends State<EmployeeDeliveryScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<EmployeeMainProvider>();
    final userId = mainProvider.userId;

    if (userId.isEmpty || _initializedForUserId == userId) return;

    _initializedForUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EmployeeMainProvider>().initializeSection('delivery');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_EMPLOYEE_DELIVERY',
      message: 'Entrando a la pantalla de envios del empleado.',
      role: 'employee',
      child: Selector<EmployeeMainProvider, bool>(
        selector: (_, p) => p.isSectionLoading('delivery'),
        builder: (context, isLoading, _) {
          if (isLoading) {
            return Scaffold(body: _buildShimmer());
          }

          final mainProvider = context.watch<EmployeeMainProvider>();
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
            return Scaffold(body: _buildShimmer());
          }

          return ChangeNotifierProvider.value(
            value: deliveryProvider,
            child: _DeliveryContent(),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 140,
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
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeDeliveryProvider>();
    final deliveries = provider.deliveries;

    final pending = deliveries.where((d) => d['status'] == 'pending').length;
    final accepted = deliveries.where((d) => d['status'] == 'accepted').length;
    final completed = deliveries.where((d) => d['status'] == 'completed').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Entregas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
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
            _buildSummaryCards(pending, accepted, completed),
            const SizedBox(height: 20),
            const Text(
              'Lista de Entregas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (deliveries.isEmpty)
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.local_shipping, color: Colors.grey, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'No hay entregas asignadas',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...deliveries.map((delivery) => _DeliveryCard(delivery: delivery)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(int pending, int accepted, int completed) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Pendientes',
            count: pending,
            color: const Color(0xFFF59E0B),
            icon: Icons.hourglass_empty,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Aceptadas',
            count: accepted,
            color: const Color(0xFF3B82F6),
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Completadas',
            count: completed,
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
    final status = delivery['status'] ?? 'pending';
    final address = delivery['address'] ?? 'Sin dirección';
    final items = delivery['items'];
    final itemsList = (items is List) ? items : <dynamic>[];
    final id = delivery['id'] ?? '';
    final provider = context.read<EmployeeDeliveryProvider>();

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'accepted':
        statusColor = const Color(0xFF3B82F6);
        statusLabel = 'Aceptado';
        break;
      case 'completed':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Completado';
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Pendiente';
    }

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
                      const Icon(Icons.location_on, color: Color(0xFFF97316), size: 18),
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
            if (itemsList.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(
                'Artículos: ${itemsList.join(', ')}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
            if (status == 'pending' || status == 'accepted') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status == 'pending')
                    ElevatedButton.icon(
                      onPressed: () => provider.acceptDelivery(id),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Aceptar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  if (status == 'accepted')
                    ElevatedButton.icon(
                      onPressed: () => provider.completeDelivery(id),
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Completar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  if (status == 'accepted')
                    const SizedBox(width: 8),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
