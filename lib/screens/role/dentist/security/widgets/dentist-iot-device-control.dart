import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class DentistIoTDeviceControl extends StatelessWidget {
  const DentistIoTDeviceControl({super.key});

  static const _darkText = Color(0xFF1D1D1F);
  static const _mediumText = Color(0xFF86868B);
  static const _cardBg = Color(0xFFF5F5F7);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;
    if (profile == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final allDevices = <_DeviceItem>[
      ...profile.lights.map((d) => _DeviceItem(d, Icons.light_outlined, const Color(0xFFFF9500), 'lights')),
      ...profile.fans.map((d) => _DeviceItem(d, Icons.air_outlined, const Color(0xFF007AFF), 'fans')),
      ...profile.airs.map((d) => _DeviceItem(d, Icons.ac_unit_outlined, const Color(0xFF34C759), 'airs')),
      ...profile.tvs.map((d) => _DeviceItem(d, Icons.tv_outlined, const Color(0xFF5856D6), 'tvs')),
      ...profile.doors.map((d) => _DeviceItem(d, Icons.door_front_door_outlined, const Color(0xFFFF3B30), 'doors')),
      ...profile.voices.map((d) => _DeviceItem(d, Icons.volume_up_outlined, const Color(0xFFAF52DE), 'voices')),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dispositivos IoT',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _darkText,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            ...allDevices.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
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
                              color: _darkText,
                            ),
                          ),
                          Text(
                            item.device.room,
                            style: TextStyle(fontSize: 12, color: _mediumText),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: item.device.isOn,
                      activeColor: const Color(0xFF34C759),
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
