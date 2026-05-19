import 'package:flutter/material.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

/// Widget para mostrar estadísticas de seguridad
class DentistSecurityStats extends StatelessWidget {
  const DentistSecurityStats({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistSecurityStats] build() iniciado');
    
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;
    
    if (profile == null) return SliverToBoxAdapter(child: const SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Estadísticas', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppConstants.paddingM),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppConstants.paddingM,
              mainAxisSpacing: AppConstants.paddingM,
              children: [
                _buildStatCard('Accesos Hoy', '45', '📈'),
                _buildStatCard('Dispositivos On', '8', '✅'),
                _buildStatCard('Alertas', '2', '⚠️'),
                _buildStatCard('Uptime', '99.2%', '⏱️'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String emoji) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700)),
            Text(value, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
