import 'package:flutter/material.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';

/// Widget para verificar proximidad Bluetooth
class DentistMobileChecker extends StatelessWidget {
  const DentistMobileChecker({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistMobileChecker] build() iniciado');
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📱', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verificación por Proximidad',
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Control de acceso mediante Bluetooth',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingM),
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Column(
                    children: [
                      const Text('📡', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        'Buscando dispositivos...',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      LinearProgressIndicator(
                        backgroundColor: AppColors.grey300,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
