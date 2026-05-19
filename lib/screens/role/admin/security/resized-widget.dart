// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                                RESIZE HANDLE LAYER
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';

enum CornerPositionEnums { topLeft, topRight, bottomLeft, bottomRight }

// ignore: unused_element
class ResizeHandleLayerWidget extends StatelessWidget {
  final VoidCallback onResizeStart;
  final void Function(CornerPositionEnums corner, Offset delta) onResizeUpdate;
  final VoidCallback onResizeEnd;

  const ResizeHandleLayerWidget({
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _handle(top: -6, left: -6, corner: CornerPositionEnums.topLeft),
      _handle(top: -6, right: -6, corner: CornerPositionEnums.topRight),
      _handle(bottom: -6, left: -6, corner: CornerPositionEnums.bottomLeft),
      _handle(bottom: -6, right: -6, corner: CornerPositionEnums.bottomRight),
    ]);
  }

  Widget _handle({
    double? top,
    double? right,
    double? bottom,
    double? left,
    required CornerPositionEnums corner,
  }) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => onResizeStart(),
        onPanUpdate: (d) => onResizeUpdate(corner, d.delta),
        onPanEnd: (_) => onResizeEnd(),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border.all(color: const Color(0xFF2563EB), width: 2),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x20000000),
                      blurRadius: 8,
                      offset: Offset(0, 3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
