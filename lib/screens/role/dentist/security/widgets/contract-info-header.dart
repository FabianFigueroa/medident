import 'package:flutter/material.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:provider/provider.dart';

class DentistContractInfoHeader extends StatelessWidget {
  const DentistContractInfoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos un Consumer para escuchar los cambios en el provider
    return Consumer<DentistSecurityProvider>(
      builder: (context, provider, child) {
        // Obtenemos los datos de seguridad. Si son nulos, usamos valores por defecto.
        final securityData = provider.securityData;
        final address = securityData?.address ?? 'No disponible';
        final status = securityData?.contractStatus ?? 'inactivo';

        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalles del Contrato',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  icon: Icons.location_on_outlined,
                  label: 'Ubicación',
                  value: address,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  icon: Icons.shield_outlined,
                  label: 'Estado',
                  value: status.toUpperCase(),
                  valueColor: status == 'active' ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value, Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: valueColor ?? Colors.black87, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
