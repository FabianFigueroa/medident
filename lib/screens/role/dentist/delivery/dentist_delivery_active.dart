import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/delivery/delivery-provider.dart';
import 'package:medident/main_export.dart';

class DeliveryActiveScreen extends StatelessWidget {
  const DeliveryActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF008080), Color(0xFF20B2AA)]),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Delivery Activo',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.green, size: 10),
                            SizedBox(width: 6),
                            Text('En línea', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.notifications, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _statCard(
                    iconWidget: const Icon(Icons.shopping_bag, color: Color(0xFF008080), size: 24),
                    label: 'Pendientes',
                    value: provider.pendingOrders.length.toString(),
                    color: const Color(0xFF008080),
                  ),
                  const SizedBox(height: 12),
                  _statCard(
                    iconWidget: const Icon(Icons.local_shipping, color: Colors.green, size: 24),
                    label: 'En Curso',
                    value: provider.activeDeliveries.length.toString(),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  if (provider.pendingOrders.isNotEmpty) ...[
                    const Text('Pedidos Disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...provider.pendingOrders.map((order) => _orderCard(order)).toList(),
                  ],
                  if (provider.activeDeliveries.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Entregas Activas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...provider.activeDeliveries.map((d) => _deliveryCard(d)).toList(),
                  ],
                  if (provider.pendingOrders.isEmpty && provider.activeDeliveries.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(Icons.shopping_bag, color: Colors.grey, size: 48),
                            const SizedBox(height: 12),
                            const Text('No hay pedidos disponibles'),
                          ],
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

  Widget _statCard({
    required Widget iconWidget,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: iconWidget,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                  Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(dynamic order) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF008080).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.shopping_bag, color: Color(0xFF008080), size: 20),
        ),
        title: Text(order.restaurantName ?? 'Pedido'),
        subtitle: Text(order.deliveryAddress ?? ''),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Text('Disponible', style: TextStyle(color: Colors.orange, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _deliveryCard(dynamic delivery) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.local_shipping, color: Colors.green, size: 20),
        ),
        title: Text(delivery.restaurantName ?? 'Entrega'),
        subtitle: Text(delivery.deliveryAddress ?? ''),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Text('En curso', style: TextStyle(color: Colors.green, fontSize: 12)),
        ),
      ),
    );
  }
}
