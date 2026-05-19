// ignore: unused_element
import 'package:flutter/material.dart';
import 'package:medident/screens/role/admin/security/models.dart';

class WallTouchLayerWidget extends StatelessWidget {
  final ValueChanged<DoorSideEnums> onWallTap;
  const WallTouchLayerWidget({required this.onWallTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            left: 10, right: 10, top: 0, height: 14,
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => onWallTap(DoorSideEnums.top))),
        Positioned(
            right: 0, top: 10, bottom: 10, width: 14,
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => onWallTap(DoorSideEnums.right))),
        Positioned(
            left: 10, right: 10, bottom: 0, height: 14,
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => onWallTap(DoorSideEnums.bottom))),
        Positioned(
            left: 0, top: 10, bottom: 10, width: 14,
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => onWallTap(DoorSideEnums.left))),
      ],
    );
  }
}
