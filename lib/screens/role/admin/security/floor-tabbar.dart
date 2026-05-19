// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                    FLOOR TAB BAR (inside croquis header)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

// ignore: unused_element
import 'package:flutter/material.dart';
import 'package:medident/screens/role/admin/security/models.dart';

import '../../../../main_export.dart';

class FloorTabBarWidget extends StatelessWidget {
  final List<FloorConfigModel> floors;
  final int activeFloor;
  final ValueChanged<int> onFloorChanged;

  const FloorTabBarWidget({
    required this.floors,
    required this.activeFloor,
    required this.onFloorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(floors.length, (i) {
        final active = i == activeFloor;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: InkWell(
            onTap: () => onFloorChanged(i),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF3A7AFE) : AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                floors[i].nombre,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Ubuntu-Medium',
                  color: active ? Colors.white : AppColors.grey600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
