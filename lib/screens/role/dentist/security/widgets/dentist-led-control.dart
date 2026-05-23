import 'package:flutter/material.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

/// Widget para control LED
class DentistLedControl extends StatelessWidget {
  const DentistLedControl({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistLedControl] build() iniciado');
    final provider = context.watch<DentistSecurityProvider>();
    final selectedOption = provider.dentistSecurityModel?.activeLedOption;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💡 Control de Iluminación LED', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppConstants.paddingM),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLedModeButton(
                          context,
                          provider,
                          'Modo 1',
                          'led_option_1',
                          '🔴',
                          selectedOption,
                        ),
                        _buildLedModeButton(
                          context,
                          provider,
                          'Modo 2',
                          'led_option_2',
                          '🟡',
                          selectedOption,
                        ),
                        _buildLedModeButton(
                          context,
                          provider,
                          'Modo 3',
                          'led_option_3',
                          '🟢',
                          selectedOption,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingL),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Text(
                        selectedOption == null ? 'Luces apagadas' : 'Modo: ${selectedOption.replaceAll('led_option_', 'LED ')}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedModeButton(
    BuildContext context,
    DentistSecurityProvider provider,
    String label,
    String optionKey,
    String emoji,
    String? selectedOption,
  ) {
    final bool isSelected = selectedOption == optionKey;

    return GestureDetector(
      onTap: () => provider.updateActiveLedOption(isSelected ? null : optionKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: AppConstants.paddingXS),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
