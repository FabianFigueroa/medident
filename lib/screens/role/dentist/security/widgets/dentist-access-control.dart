import 'package:flutter/material.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';

/// Widget para control de acceso
class DentistAccessControl extends StatelessWidget {
  const DentistAccessControl({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistAccessControl] build() iniciado');
    
    final doors = [
      {'name': 'Puerta Principal', 'status': 'Desbloqueada', 'time': '09:30 AM', 'icon': 'ðŸŸ¢'},
      {'name': 'Puerta Consultorio 1', 'status': 'Bloqueada', 'time': '10:15 AM', 'icon': 'ðŸ”´'},
      {'name': 'Puerta Consultorio 2', 'status': 'Desbloqueada', 'time': '10:20 AM', 'icon': 'ðŸŸ¢'},
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ðŸšª Control de Acceso', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppConstants.paddingM),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doors.length,
              itemBuilder: (context, index) {
                final door = doors[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(door['name']!, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(door['status']!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(door['icon']!, style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(door['time']!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
                          ],
                        ),
                      ],
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
