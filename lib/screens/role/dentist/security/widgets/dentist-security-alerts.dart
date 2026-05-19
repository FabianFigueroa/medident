import 'package:flutter/material.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';

/// Widget para mostrar alertas de seguridad
class DentistSecurityAlerts extends StatelessWidget {
  const DentistSecurityAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistSecurityAlerts] build() iniciado');
    
    final alerts = [
      {'icon': '🔔', 'title': 'Puerta Abierta', 'subtitle': 'Puerta Principal', 'level': 'warning'},
      {'icon': '⚠️', 'title': 'Batería Baja', 'subtitle': 'Sensor Consultorio 1', 'level': 'warning'},
      {'icon': '✅', 'title': 'Sistema Normal', 'subtitle': 'Todos los sistemas operativos', 'level': 'success'},
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🚨 Alertas de Seguridad', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppConstants.paddingM),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final isWarning = alert['level'] == 'warning';
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
                  color: isWarning ? AppColors.error.withOpacity(0.1) : AppColors.positive.withOpacity(0.1),
                  child: ListTile(
                    leading: Text(alert['icon']!, style: const TextStyle(fontSize: 24)),
                    title: Text(alert['title']!, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(alert['subtitle']!),
                    trailing: Icon(
                      Icons.info_outline,
                      color: isWarning ? AppColors.error : AppColors.positive,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
