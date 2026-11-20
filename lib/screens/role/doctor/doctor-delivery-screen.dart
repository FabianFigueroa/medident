import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/main_export.dart';

class DoctorDeliveryScreen extends StatefulWidget {
  const DoctorDeliveryScreen({super.key});

  @override
  State<DoctorDeliveryScreen> createState() => _DoctorDeliveryScreenState();
}

class _DoctorDeliveryScreenState extends State<DoctorDeliveryScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<DoctorMainProvider>();
    final userId = mainProvider.userId;

    if (userId.isEmpty || _initializedForUserId == userId) return;

    _initializedForUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DoctorMainProvider>().initializeSection('delivery');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_DOCTOR_DELIVERY',
      message: 'Entrando a la pantalla de envios del medico.',
      role: 'doctor',
      child: Selector<DoctorMainProvider, bool>(
        selector: (_, p) => p.isSectionLoading('delivery'),
        builder: (context, isLoading, _) {
          if (isLoading) {
            return Scaffold(body: _buildScreenShimmer());
          }

          final mainProvider = context.watch<DoctorMainProvider>();
          final error = mainProvider.getSectionError('delivery');

          if (error != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Error al cargar envíos: $error'),
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

          return ChangeNotifierProvider.value(
            value: deliveryProvider,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: const _DeliveryContent(),
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
    final provider = context.watch<DoctorDeliveryProvider>();
    final deliveries = provider.deliveries;
    final stats = provider.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Envíos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRequestSheet(context, provider),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Solicitar envío'),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadDeliveries(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _buildSummaryCards(stats),
            if (provider.error != null) ...[
              const SizedBox(height: 12),
              Text(
                provider.error!,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Envíos Solicitados',
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
                        'No has solicitado envíos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Usa "Solicitar envío" para enviar insumos o medicamentos a tus pacientes.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...deliveries.map((delivery) => _DeliveryCard(delivery: delivery)),
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

  void _showCreateRequestSheet(
    BuildContext context,
    DoctorDeliveryProvider provider,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CreateRequestSheet(provider: provider),
    );
  }
}

class _CreateRequestSheet extends StatefulWidget {
  final DoctorDeliveryProvider provider;

  const _CreateRequestSheet({required this.provider});

  @override
  State<_CreateRequestSheet> createState() => _CreateRequestSheetState();
}

class _CreateRequestSheetState extends State<_CreateRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _patientName;
  late final TextEditingController _patientAddress;
  final _itemsController = TextEditingController();
  final _totalController = TextEditingController();
  String? _doctorName;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _patientName = TextEditingController();
    _patientAddress = TextEditingController();
  }

  @override
  void dispose() {
    _patientName.dispose();
    _patientAddress.dispose();
    _itemsController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _doctorName ??= context.watch<AuthenticateProvider>().user?.fullName ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solicitar envío',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'El pedido se enviará al equipo de entregas.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _patientName,
              decoration: const InputDecoration(
                labelText: 'Nombre del paciente',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _patientAddress,
              decoration: const InputDecoration(
                labelText: 'Dirección de entrega',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _itemsController,
              decoration: const InputDecoration(
                labelText: 'Artículos (separados por coma)',
                hintText: 'Paracetamol 500mg, Jeringas x10',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _totalController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Total estimado (\$) — opcional',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final raw = (v ?? '').trim();
                if (raw.isEmpty) return null;
                if (double.tryParse(raw) == null) return 'Número inválido';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, size: 18),
                label: Text(_submitting ? 'Enviando...' : 'Enviar solicitud'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await widget.provider.submitDeliveryRequest(
      doctorName: _doctorName ?? '',
      patientName: _patientName.text.trim(),
      patientAddress: _patientAddress.text.trim(),
      items: _itemsController.text.trim(),
      total: double.tryParse(_totalController.text.trim()) ?? 0,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo enviar la solicitud${widget.provider.error != null ? ': ${widget.provider.error}' : ''}',
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
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
    final status = (delivery['status'] ?? 'pending').toString();
    final patientName = (delivery['patientName'] ?? 'Paciente').toString();
    final address = (delivery['patientAddress'] ?? 'Sin dirección').toString();
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
                      const Icon(Icons.person_outline,
                          color: Color(0xFF1565C0), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          patientName,
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
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF1565C0), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (riderName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Repartidor: $riderName',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            if (total != null && (total as num) > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Total: \$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0),
                  ),
                ),
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
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Cancelar envío'),
                          content: const Text(
                            '¿Seguro que deseas cancelar esta solicitud?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: const Text('Volver'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              child: const Text(
                                'Cancelar envío',
                                style: TextStyle(color: Color(0xFFEF4444)),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        context.read<DoctorDeliveryProvider>().cancelDelivery(id);
                      }
                    },
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
}
