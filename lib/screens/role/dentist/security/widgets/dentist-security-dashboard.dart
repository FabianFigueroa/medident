import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-colors.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:provider/provider.dart';

class DentistSecurityDashboard extends StatelessWidget {
  const DentistSecurityDashboard({super.key});

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
        padding: const EdgeInsets.fromLTRB(AppConstants.paddingM, AppConstants.paddingM, AppConstants.paddingM, AppConstants.paddingS),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.purpleColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: AppConstants.elevationXL,
                offset: const Offset(0, AppConstants.elevationM),
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
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppColors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Seguridad',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingL),
              Row(
                children: [
                  _metric(Icons.credit_card_outlined, '${profile.rfidCards.length}', 'Tarjetas'),
                  const SizedBox(width: AppConstants.paddingL),
                  _metric(Icons.devices_outlined, '$totalDevices', 'Dispositivos'),
                  const SizedBox(width: AppConstants.paddingL),
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
          Icon(icon, color: AppColors.white.withOpacity(0.7), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
