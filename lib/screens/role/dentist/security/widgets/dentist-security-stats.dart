import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class DentistSecurityStats extends StatelessWidget {
  const DentistSecurityStats({super.key});

  static const _darkText = Color(0xFF1D1D1F);
  static const _mediumText = Color(0xFF86868B);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;
    if (profile == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final active = profile.lights.where((l) => l.isOn).length +
        profile.fans.where((f) => f.isOn).length +
        profile.airs.where((a) => a.isOn).length +
        profile.tvs.where((t) => t.isOn).length +
        profile.doors.where((d) => d.isOn).length +
        profile.voices.where((v) => v.isOn).length;

    final uptime = Random().nextDouble() * 0.8 + 99.0;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Resumen'),
            const SizedBox(height: 14),
            Row(
              children: [
                _statCard(Icons.person_outline, 'Accesos hoy', '12', const Color(0xFF007AFF)),
                const SizedBox(width: 12),
                _statCard(Icons.devices_outlined, 'Dispositivos on', '$active', const Color(0xFF34C759)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statCard(Icons.notifications_outlined, 'Alertas', '${provider.alerts.length}', const Color(0xFFFF9500)),
                const SizedBox(width: 12),
                _statCard(Icons.timer_outlined, 'Uptime', '${uptime.toStringAsFixed(1)}%', const Color(0xFF5856D6)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _darkText,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _darkText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _mediumText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
