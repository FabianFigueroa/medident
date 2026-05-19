import 'package:flutter/material.dart';
import 'package:medident/screens/role/admin/security/floor-tabbar.dart';
import 'package:medident/screens/role/admin/security/interaction.dart';
import 'package:medident/screens/role/admin/security/models.dart';
import 'package:medident/screens/role/admin/security/point-badge-widget.dart';
import 'package:medident/screens/role/admin/security/resized-widget.dart';
import 'package:medident/screens/role/admin/security/room-card-widget.dart';
import 'package:medident/screens/widgets/role/security/operational-layout-painter.dart';
import 'package:medident/screens/widgets/role/security/template.dart';
import 'package:medident/screens/widgets/role/security/wallout-touch-layer.dart';

import '../../../../main_export.dart';

class OperationalLayoutEditorWidget extends StatelessWidget {
  final String roleName;
  final bool usesMockData;
  final FloorConfigModel floor;
  final List<FloorConfigModel> floors;
  final int activeFloor;
  final LayoutTemplateModel template;
  final int selectedRoom;
  final DoorSideEnums? selectedWall;
  final bool showGrid;
  final ValueChanged<int> onFloorChanged;
  final ValueChanged<int> onRoomSelected;
  final void Function(int roomIndex, DoorSideEnums side) onWallSelected;
  final ValueChanged<int> onRoomDragStart;
  final void Function(int roomIndex, Offset delta, Size canvasSize) onRoomDrag;
  final ValueChanged<int> onRoomDragEnd;
  final ValueChanged<int> onRoomResizeStart;
  final void Function(
    int roomIndex,
    CornerPositionEnums corner,
    Offset delta,
    Size canvasSize,
  )
  onRoomResize;
  final ValueChanged<int> onRoomResizeEnd;

  const OperationalLayoutEditorWidget({
    super.key,
    required this.roleName,
    required this.usesMockData,
    required this.floor,
    required this.floors,
    required this.activeFloor,
    required this.template,
    required this.selectedRoom,
    required this.selectedWall,
    required this.showGrid,
    required this.onFloorChanged,
    required this.onRoomSelected,
    required this.onWallSelected,
    required this.onRoomDragStart,
    required this.onRoomDrag,
    required this.onRoomDragEnd,
    required this.onRoomResizeStart,
    required this.onRoomResize,
    required this.onRoomResizeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final visibleRooms = floor.rooms.take(floor.roomCount).toList();
    return panelAdminWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

              const Expanded(
                child: Text(
                  'Editor operativo de espacios',
                  style: _sectionTitle,
                ),
              ),

              FloorTabBarWidget(
                floors: floors,
                activeFloor: activeFloor,
                onFloorChanged: onFloorChanged,
              ),
              
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.badge_outlined,
                label: 'Rol ${roleName.toUpperCase()}',
              ),
              _InfoChip(
                icon: usesMockData
                    ? Icons.dataset_outlined
                    : Icons.cloud_sync_outlined,
                label: usesMockData
                    ? 'Datos de ejemplo'
                    : 'Datos sincronizados',
              ),
              const _InfoChip(
                icon: Icons.hub_outlined,
                label: 'Base lista para Provider',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            template.descripcion,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const InteractionGuideWidget(),
          const SizedBox(height: 14),
          Container(
            height: 560,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F1EA),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFE3DDD2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: OperationalLayoutPainter(
                          rooms: visibleRooms,
                          selectedRoom: selectedRoom,
                          selectedWall: selectedWall,
                          wallStyle: floor.wallStyle,
                          showGrid: showGrid,
                        ),
                      ),
                    ),
                    ...List.generate(visibleRooms.length, (i) {
                      final room = visibleRooms[i];
                      return Positioned(
                        left: constraints.maxWidth * room.x,
                        top: constraints.maxHeight * room.y,
                        width: constraints.maxWidth * room.w,
                        height: constraints.maxHeight * room.h,
                        child: GestureDetector(
                          onLongPressStart: (_) => onRoomDragStart(i),
                          onLongPressMoveUpdate: (d) => onRoomDrag(
                            i,
                            d.offsetFromOrigin,
                            constraints.biggest,
                          ),
                          onLongPressEnd: (_) => onRoomDragEnd(i),
                          child: RoomCardWidget(
                            room: room,
                            wallStyle: floor.wallStyle,
                            active: i == selectedRoom,
                            onTap: () => onRoomSelected(i),
                          ),
                        ),
                      );
                    }),
                    ...List.generate(visibleRooms.length, (i) {
                      final room = visibleRooms[i];
                      return Positioned(
                        left: constraints.maxWidth * room.x,
                        top: constraints.maxHeight * room.y,
                        width: constraints.maxWidth * room.w,
                        height: constraints.maxHeight * room.h,
                        child: WallTouchLayerWidget(
                          onWallTap: (side) => onWallSelected(i, side),
                        ),
                      );
                    }),
                    if (selectedRoom >= 0 && selectedRoom < visibleRooms.length)
                      Positioned(
                        left:
                            constraints.maxWidth * visibleRooms[selectedRoom].x,
                        top:
                            constraints.maxHeight *
                            visibleRooms[selectedRoom].y,
                        width:
                            constraints.maxWidth * visibleRooms[selectedRoom].w,
                        height:
                            constraints.maxHeight *
                            visibleRooms[selectedRoom].h,
                        child: ResizeHandleLayerWidget(
                          onResizeStart: () => onRoomResizeStart(selectedRoom),
                          onResizeUpdate: (corner, delta) => onRoomResize(
                            selectedRoom,
                            corner,
                            delta,
                            constraints.biggest,
                          ),
                          onResizeEnd: () => onRoomResizeEnd(selectedRoom),
                        ),
                      ),
                    ...floor.points.map((point) {
                      if (point.roomIndex >= visibleRooms.length) {
                        return const SizedBox.shrink();
                      }
                      final room = visibleRooms[point.roomIndex];
                      return Positioned(
                        left:
                            constraints.maxWidth * (room.x + room.w * point.x),
                        top:
                            constraints.maxHeight * (room.y + room.h * point.y),
                        child: PointBadgeWidget(point: point),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
///////////////////////////////////////////////////////////////////////////////
Widget panelAdminWidget({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE7EAEE)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 22,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE3E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF3A7AFE)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.black,
              fontFamily: 'Ubuntu-Medium',
            ),
          ),
        ],
      ),
    );
  }
}

const _sectionTitle = TextStyle(
  fontSize: 18,
  color: AppColors.black,
  fontFamily: 'Ubuntu-Bold',
);
