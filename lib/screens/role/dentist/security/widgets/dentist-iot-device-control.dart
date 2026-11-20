import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-colors.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/widgets/app_card.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:provider/provider.dart';

class DentistIoTDeviceControl extends StatelessWidget {
  const DentistIoTDeviceControl({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;
    if (profile == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final allDevices = <_DeviceItem>[
      ...profile.lights.map((d) => _DeviceItem(d, Icons.light_outlined, AppColors.accent, 'lights')),
      ...profile.fans.map((d) => _DeviceItem(d, Icons.air_outlined, AppColors.primary, 'fans')),
      ...profile.airs.map((d) => _DeviceItem(d, Icons.ac_unit_outlined, AppColors.success, 'airs')),
      ...profile.tvs.map((d) => _DeviceItem(d, Icons.tv_outlined, AppColors.purpleColor, 'tvs')),
      ...profile.doors.map((d) => _DeviceItem(d, Icons.door_front_door_outlined, AppColors.error, 'doors')),
      ...profile.voices.map((d) => _DeviceItem(d, Icons.volume_up_outlined, const Color(0xFFAF52DE), 'voices')),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppConstants.paddingM, AppConstants.paddingS, AppConstants.paddingM, AppConstants.paddingS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dispositivos IoT',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            ...allDevices.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM, vertical: 12),
                margin: EdgeInsets.zero,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.device.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            item.device.room,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: item.device.isOn,
                      activeColor: AppColors.success,
                      onChanged: (val) => provider.updateUserDeviceState(
                        item.type,
                        item.device.id,
                        val,
                      ),
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

class _DeviceItem {
  final Device device;
  final IconData icon;
  final Color color;
  final String type;
  _DeviceItem(this.device, this.icon, this.color, this.type);
}
