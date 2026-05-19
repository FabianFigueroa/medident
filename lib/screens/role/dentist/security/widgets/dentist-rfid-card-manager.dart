import 'package:flutter/material.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

/// Widget para gestionar tarjetas RFID
class DentistRfidCardManager extends StatelessWidget {
  const DentistRfidCardManager({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistRfidCardManager] build() iniciado');
    final provider = context.watch<DentistSecurityProvider>();
    final rfidCards = provider.rfidCards;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ðŸ†” Tarjetas RFID', style: AppTextStyles.headlineSmall),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva'),
                  onPressed: () => provider.setCardRegistrationMode(true),
                )
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            if (rfidCards.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingL),
                  child: Text(
                    'No hay tarjetas registradas',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: AppConstants.paddingS,
                  mainAxisSpacing: AppConstants.paddingS,
                ),
                itemCount: rfidCards.length,
                itemBuilder: (context, index) {
                  final card = rfidCards[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingS),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ðŸ†” ${card.cardId}',
                            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            card.assignedTo,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.check_circle, color: AppColors.positive, size: 20),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                onPressed: () => provider.deleteRfidCard(card.cardId),
                              ),
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
