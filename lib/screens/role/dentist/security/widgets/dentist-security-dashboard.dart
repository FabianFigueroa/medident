import 'package:flutter/material.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

/// Widget que muestra el resumen ejecutivo de seguridad
class DentistSecurityDashboard extends StatelessWidget {
  const DentistSecurityDashboard({super.key});

  @override
  Widget build(BuildContext context) {
   debugPrint('[DentistSecurityDashboard] build() iniciado');
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;
    
    if (profile == null) {
      return SliverToBoxAdapter(child: const SizedBox.shrink());
    }

    final int totalDevices = profile.lights.length +
        profile.fans.length +
        profile.airs.length +
        profile.tvs.length +
        profile.doors.length +
        profile.voices.length;

    final int activeDevices = 
        profile.lights.where((l) => l.isOn).length +
        profile.fans.where((f) => f.isOn).length +
        profile.airs.where((a) => a.isOn).length +
        profile.tvs.where((t) => t.isOn).length +
        profile.doors.where((d) => d.isOn).length +
        profile.voices.where((v) => v.isOn).length;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.9),
              AppColors.secondary.withOpacity(0.7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ðŸ¥ Seguridad Dental',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDashboardCard(
                    icon: 'ðŸ†”',
                    label: 'Tarjetas RFID',
                    value: '${profile.rfidCards.length}',
                  ),
                  _buildDashboardCard(
                    icon: 'ðŸ”Œ',
                    label: 'Dispositivos',
                    value: '$totalDevices',
                  ),
                  _buildDashboardCard(
                    icon: 'âœ…',
                    label: 'Activos',
                    value: '$activeDevices',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: AppConstants.paddingXS),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}
