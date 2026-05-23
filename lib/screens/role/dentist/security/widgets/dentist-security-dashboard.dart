import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class DentistSecurityDashboard extends StatelessWidget {
  const DentistSecurityDashboard({super.key});

  static const _accent = Color(0xFF007AFF);
  static const _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;

    if (profile == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final totalDevices = profile.lights.length +
        profile.fans.length +
        profile.airs.length +
        profile.tvs.length +
        profile.doors.length +
        profile.voices.length;

    final activeDevices =
        profile.lights.where((l) => l.isOn).length +
        profile.fans.where((f) => f.isOn).length +
        profile.airs.where((a) => a.isOn).length +
        profile.tvs.where((t) => t.isOn).length +
        profile.doors.where((d) => d.isOn).length +
        profile.voices.where((v) => v.isOn).length;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_outlined, color: _white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Seguridad',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _metric(Icons.credit_card_outlined, '${profile.rfidCards.length}', 'Tarjetas'),
                  const SizedBox(width: 24),
                  _metric(Icons.devices_outlined, '$totalDevices', 'Dispositivos'),
                  const SizedBox(width: 24),
                  _metric(Icons.check_circle_outlined, '$activeDevices', 'Activos'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _white.withOpacity(0.7), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _white,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: _white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
