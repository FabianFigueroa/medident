import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-colors.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/widgets/app_card.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:provider/provider.dart';

class DentistAccessControl extends StatelessWidget {
  const DentistAccessControl({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;

    final doors = profile?.doors ?? [];
    if (doors.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppConstants.paddingM, AppConstants.paddingS, AppConstants.paddingM, AppConstants.paddingS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control de Acceso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            ...doors.map((door) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                margin: EdgeInsets.zero,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (door.isOn ? AppColors.success : AppColors.error).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                      ),
                      child: Icon(
                        door.isOn ? Icons.lock_open_outlined : Icons.lock_outlined,
                        color: door.isOn ? AppColors.success : AppColors.error,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            door.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            door.isOn ? 'Desbloqueada' : 'Bloqueada',
                            style: TextStyle(
                              fontSize: 12,
                              color: door.isOn ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      door.isOn ? Icons.check_circle : Icons.cancel,
                      color: door.isOn ? AppColors.success : AppColors.error,
                      size: 22,
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
