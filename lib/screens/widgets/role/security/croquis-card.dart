import 'package:flutter/widgets.dart';
import 'package:medident/screens/widgets/role/security/operational-layout-editor-widget.dart';

@Deprecated(
  'Usa OperationalLayoutEditorWidget para el editor operativo reutilizable.',
)
class CroquisCardWidget extends OperationalLayoutEditorWidget {
  const CroquisCardWidget({
    super.key,
    required super.roleName,
    required super.usesMockData,
    required super.floor,
    required super.floors,
    required super.activeFloor,
    required super.template,
    required super.selectedRoom,
    required super.selectedWall,
    required super.showGrid,
    required super.onFloorChanged,
    required super.onRoomSelected,
    required super.onWallSelected,
    required super.onRoomDragStart,
    required super.onRoomDrag,
    required super.onRoomDragEnd,
    required super.onRoomResizeStart,
    required super.onRoomResize,
    required super.onRoomResizeEnd,
  });
}
