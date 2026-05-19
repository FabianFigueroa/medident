// ignore: unused_element
import 'package:flutter/material.dart';
import 'package:medident/screens/role/admin/security/models.dart';

import '../../../../main_export.dart';

class PointBadgeWidget extends StatelessWidget {
  final DevicePointModel point;
  const PointBadgeWidget({required this.point});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF3A7AFE),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Color(0x663A7AFE),
                  blurRadius: 12,
                  offset: Offset(0, 0)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE1D9CC)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2)),
            ],
          ),
          child: Text(point.label,
              style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.black,
                  fontFamily: 'Ubuntu-Bold')),
        ),
      ],
    );
  }
}
