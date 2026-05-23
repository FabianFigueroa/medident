import 'package:flutter/material.dart';
import 'package:medident/core/models/contract-request-model.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/screens/role/dentist/security/widgets/dentist-contract-acceptance.dart';
import 'package:provider/provider.dart';

class DentistContractStatusWidget extends StatelessWidget {
  final Widget dashboard;

  const DentistContractStatusWidget({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DentistSecurityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFFF3B30), fontSize: 15),
              ),
            ),
          );
        }

        final model = provider.dentistSecurityModel;
        final status = model?.contractStatus ?? 'inactive';

        switch (status) {
          case 'inactive':
          case '':
            return const ContractAcceptance_Widget();

          case 'pending_review':
            return _buildStatusScreen(
              icon: Icons.hourglass_empty,
              iconColor: const Color(0xFFFF9500),
              title: 'Solicitud enviada',
              subtitle: 'Tu solicitud de activación de seguridad IoT está siendo revisada por un administrador. Te notificaremos cuando sea aprobada.',
            );

          case 'rejected':
            return _buildStatusScreen(
              icon: Icons.cancel_outlined,
              iconColor: const Color(0xFFFF3B30),
              title: 'Solicitud rechazada',
              subtitle: 'Tu solicitud de seguridad IoT no fue aprobada. Contactá al administrador para más información.',
            );

          case 'suspended':
            final reason = model?.suspensionReason ?? 'Falta de pago';
            return _buildStatusScreen(
              icon: Icons.pause_circle_outline,
              iconColor: const Color(0xFFFF3B30),
              title: 'Servicio suspendido',
              subtitle: 'El servicio de seguridad IoT está suspendido por: $reason. Contactá al administrador para reactivarlo.',
            );

          case 'active':
            if (model?.isSubscriptionExpired == true) {
              return _buildStatusScreen(
                icon: Icons.credit_card_off_outlined,
                iconColor: const Color(0xFFFF3B30),
                title: 'Suscripción vencida',
                subtitle: 'Tu suscripción de seguridad IoT está vencida. Contactá al administrador para renovar el pago mensual.',
              );
            }
            return dashboard;

          default:
            return const ContractAcceptance_Widget();
        }
      },
    );
  }

  Widget _buildStatusScreen({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF86868B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
