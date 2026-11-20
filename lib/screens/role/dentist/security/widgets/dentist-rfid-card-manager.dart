import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-colors.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/widgets/app_card.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:provider/provider.dart';

class DentistRfidCardManager extends StatelessWidget {
  const DentistRfidCardManager({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistSecurityProvider>();
    final rfidCards = provider.rfidCards;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppConstants.paddingM, AppConstants.paddingS, AppConstants.paddingM, AppConstants.paddingS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tarjetas RFID',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => provider.setCardRegistrationMode(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Nueva',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (rfidCards.isEmpty)
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 32),
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    Icon(Icons.credit_card_outlined, size: 40, color: AppColors.textDisabled.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    Text('Sin tarjetas registradas', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  ],
                ),
              )
            else
              ...rfidCards.map((card) => AppCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                      ),
                      child: const Icon(Icons.credit_card_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.assignedTo,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.cardId,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 12, color: AppColors.success),
                          SizedBox(width: 4),
                          Text(
                            'Activa',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => provider.deleteRfidCard(card.cardId),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                        ),
                        child: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}
