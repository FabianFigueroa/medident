import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/providers/delivery/delivery-provider.dart';
import 'package:medident/main_export.dart';

class DeliveryInactiveScreen extends StatelessWidget {
  const DeliveryInactiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DeliveryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedTruck,
                  color: Colors.grey[500],
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Delivery Inactivo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Activa el servicio para comenzar a recibir pedidos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  provider.toggleService();
                },
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedPlay,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Activar Delivery',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008080),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
