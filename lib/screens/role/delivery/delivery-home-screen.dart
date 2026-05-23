import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class DeliveryMainScreen extends StatelessWidget {
  const DeliveryMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainProv = context.watch<DeliveryMainProvider>();
    final deliveryProv = mainProv.homeProvider;
    if (deliveryProv == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Domicilios'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        actions: [
          Switch(
            value: deliveryProv.isServiceActive,
            onChanged: (_) => deliveryProv.toggleService(),
            activeColor: Colors.green,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
      body: deliveryProv.isServiceActive
          ? _buildActiveView(deliveryProv)
          : _buildInactiveView(deliveryProv),
    );
  }

  Widget _buildActiveView(DeliveryProvider prov) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Pedidos Pendientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (prov.pendingOrders.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.delivery_dining, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('Esperando pedidos...', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          else
            ...prov.pendingOrders.map((order) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(order.patientName),
                    subtitle: Text(order.originAddress),
                    trailing: Text('\$${order.total.toStringAsFixed(0)}'),
                  ),
                )),
          const SizedBox(height: 16),
          const Text('Entregas Activas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (prov.activeDeliveries.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('Sin entregas activas', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          else
            ...prov.activeDeliveries.map((del) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.green.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(del.patientName),
                    subtitle: Text('${del.status.name} · \$${del.total.toStringAsFixed(0)}'),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildInactiveView(DeliveryProvider prov) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delivery_dining, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Servicio de Domicilios',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Activa el servicio para recibir pedidos',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => prov.activateService(),
            icon: const Icon(Icons.power_settings_new),
            label: const Text('Activar Servicio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
