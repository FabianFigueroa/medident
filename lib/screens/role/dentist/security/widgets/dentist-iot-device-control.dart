import 'package:flutter/material.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

/// Widget para controlar dispositivos IoT
class DentistIoTDeviceControl extends StatelessWidget {
  const DentistIoTDeviceControl({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistIoTDeviceControl] build() iniciado');
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;

    if (profile == null) return const SizedBox.shrink();

    final allDevices = [
      ...profile.lights.map((d) => {'device': d, 'type': 'lights', 'icon': 'ðŸ’¡'}),
      ...profile.fans.map((d) => {'device': d, 'type': 'fans', 'icon': 'ðŸŒ€'}),
      ...profile.airs.map((d) => {'device': d, 'type': 'airs', 'icon': 'â„ï¸'}),
      ...profile.tvs.map((d) => {'device': d, 'type': 'tvs', 'icon': 'ðŸ“º'}),
      ...profile.doors.map((d) => {'device': d, 'type': 'doors', 'icon': 'ðŸšª'}),
      ...profile.voices.map((d) => {'device': d, 'type': 'voices', 'icon': 'ðŸ“¢'}),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ðŸ”Œ Control de Dispositivos', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppConstants.paddingM),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: AppConstants.paddingM,
                mainAxisSpacing: AppConstants.paddingM,
              ),
              itemCount: allDevices.length,
              itemBuilder: (context, index) {
                final item = allDevices[index];
                final device = item['device'] as Device?;
                final icon = item['icon'] as String?;
                
                if (device == null) return const SizedBox.shrink();
                
                return GestureDetector(
                  onTap: () => provider.updateUserDeviceState(item['type'] as String, device.id, !device.isOn),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: device.isOn ? AppColors.primary.withOpacity(0.1) : AppColors.white,
                      border: Border.all(
                        color: device.isOn ? AppColors.primary : AppColors.grey300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      boxShadow: device.isOn
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(icon ?? 'ðŸ“Œ', style: const TextStyle(fontSize: 28)),
                              AnimatedRotation(
                                turns: device.isOn ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.power_settings_new,
                                  color: device.isOn ? AppColors.primary : AppColors.grey500,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.name,
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                device.isOn ? 'âœ… Activo' : 'â¸ï¸ Inactivo',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: device.isOn ? AppColors.positive : AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
