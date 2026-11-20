import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-colors.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/widgets/app_card.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:provider/provider.dart';

class DentistSecurityStats extends StatelessWidget {
  const DentistSecurityStats({super.key});

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
        padding: const EdgeInsets.fromLTRB(AppConstants.paddingM, AppConstants.paddingS, AppConstants.paddingM, AppConstants.paddingS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Resumen'),
            const SizedBox(height: 14),
            Row(
              children: [
                _statCard(Icons.person_outline, 'Accesos hoy', '12', AppColors.primary),
                const SizedBox(width: 12),
                _statCard(Icons.devices_outlined, 'Dispositivos on', '$active', AppColors.success),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statCard(Icons.notifications_outlined, 'Alertas', '${provider.alerts.length}', AppColors.warning),
                const SizedBox(width: 12),
                _statCard(Icons.timer_outlined, 'Uptime', '${uptime.toStringAsFixed(1)}%', AppColors.purpleColor),
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
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusXS),
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
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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
