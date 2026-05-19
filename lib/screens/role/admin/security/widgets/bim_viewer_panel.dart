import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/role/admin/security/clinic-floor-painter.dart';
import 'package:medident/screens/role/admin/security/models.dart';
import 'package:medident/screens/role/admin/security/room-card-widget.dart';

class BimViewerPanel extends StatelessWidget {
  final FloorConfigModel floor;
  final bool showGrid;
  final bool snapEnabled;
  final int selectedRoom;
  final DoorSideEnums? selectedWall;
  final ValueChanged<int> onRoomSelected;
  final ValueChanged<int> onRoomOptionsRequested;
  final void Function(int roomIndex, DoorSideEnums wallSide) onWallSelected;
  final void Function(int roomIndex, Offset normalizedDelta) onRoomDrag;
  final ValueChanged<int> onRoomDragEnd;
  final void Function(int roomIndex, String point, Offset normalizedDelta)
  onPointDrag;
  final void Function(int roomIndex, String point) onPointDragEnd;
  final VoidCallback onUndo;
  final VoidCallback onToggleGrid;
  final VoidCallback onToggleSnap;

  const BimViewerPanel({
    super.key,
    required this.floor,
    required this.showGrid,
    required this.snapEnabled,
    required this.selectedRoom,
    required this.selectedWall,
    required this.onRoomSelected,
    required this.onRoomOptionsRequested,
    required this.onWallSelected,
    required this.onRoomDrag,
    required this.onRoomDragEnd,
    required this.onPointDrag,
    required this.onPointDragEnd,
    required this.onUndo,
    required this.onToggleGrid,
    required this.onToggleSnap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Maqueta BIM de seguridad',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Ubuntu-Bold',
                    color: AppColors.black,
                  ),
                ),
              ),
              _ToolbarButton(
                icon: Icons.undo_rounded,
                label: 'Deshacer',
                onPressed: onUndo,
              ),
              const SizedBox(width: 8),
              _ToolbarButton(
                icon: showGrid ? Icons.grid_on_rounded : Icons.grid_off_rounded,
                label: showGrid ? 'Grid' : 'Sin grid',
                onPressed: onToggleGrid,
              ),
              const SizedBox(width: 8),
              _ToolbarButton(
                icon: snapEnabled
                    ? Icons.control_camera_rounded
                    : Icons.open_with_rounded,
                label: snapEnabled ? 'Snap' : 'Libre',
                onPressed: onToggleSnap,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final canvasSize = constraints.biggest;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ClinicFloorPainterWidget(
                            rooms: floor.rooms,
                            selectedRoom: selectedRoom,
                            selectedWall: selectedWall,
                            wallStyle: floor.wallStyle,
                            showGrid: showGrid,
                          ),
                        ),
                      ),
                      ...List.generate(floor.rooms.length, (index) {
                        final room = floor.rooms[index];
                        return Positioned(
                          left: canvasSize.width * room.x,
                          top: canvasSize.height * room.y,
                          width: canvasSize.width * room.w,
                          height: canvasSize.height * room.h,
                          child: GestureDetector(
                            onTap: () {
                              onRoomSelected(index);
                              onRoomOptionsRequested(index);
                            },
                            onPanUpdate: (details) {
                              onRoomDrag(
                                index,
                                Offset(
                                  details.delta.dx / canvasSize.width,
                                  details.delta.dy / canvasSize.height,
                                ),
                              );
                            },
                            onPanEnd: (_) => onRoomDragEnd(index),
                            child: RoomCardWidget(
                              room: room,
                              wallStyle: floor.wallStyle,
                              active: index == selectedRoom,
                              onTap: () => onRoomSelected(index),
                            ),
                          ),
                        );
                      }),
                      ...List.generate(floor.rooms.length, (index) {
                        final room = floor.rooms[index];
                        return Positioned(
                          left: canvasSize.width * room.x,
                          top: canvasSize.height * room.y,
                          width: canvasSize.width * room.w,
                          height: canvasSize.height * room.h,
                          child: _WallTouchLayer(
                            onWallTap: (side) => onWallSelected(index, side),
                          ),
                        );
                      }),
                      if (selectedRoom >= 0 &&
                          selectedRoom < floor.rooms.length)
                        _ResizeHandles(
                          room: floor.rooms[selectedRoom],
                          canvasSize: canvasSize,
                          onDrag: (point, delta) => onPointDrag(
                            selectedRoom,
                            point,
                            Offset(
                              delta.dx / canvasSize.width,
                              delta.dy / canvasSize.height,
                            ),
                          ),
                          onDragEnd: (point) =>
                              onPointDragEnd(selectedRoom, point),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.grey700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _WallTouchLayer extends StatelessWidget {
  final ValueChanged<DoorSideEnums> onWallTap;

  const _WallTouchLayer({required this.onWallTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: DoorSideEnums.values.map((side) {
            return Positioned.fromRect(
              rect: _rectFor(side, constraints.biggest),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => onWallTap(side),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Rect _rectFor(DoorSideEnums side, Size size) {
    const thickness = 18.0;
    return switch (side) {
      DoorSideEnums.top => Rect.fromLTWH(0, 0, size.width, thickness),
      DoorSideEnums.right => Rect.fromLTWH(
        size.width - thickness,
        0,
        thickness,
        size.height,
      ),
      DoorSideEnums.bottom => Rect.fromLTWH(
        0,
        size.height - thickness,
        size.width,
        thickness,
      ),
      DoorSideEnums.left => Rect.fromLTWH(0, 0, thickness, size.height),
    };
  }
}

class _ResizeHandles extends StatelessWidget {
  final RoomBlueprintModel room;
  final Size canvasSize;
  final void Function(String point, Offset delta) onDrag;
  final ValueChanged<String> onDragEnd;

  const _ResizeHandles({
    required this.room,
    required this.canvasSize,
    required this.onDrag,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _handle('tl', room.x, room.y),
        _handle('tr', room.x + room.w, room.y),
        _handle('bl', room.x, room.y + room.h),
        _handle('br', room.x + room.w, room.y + room.h),
      ],
    );
  }

  Widget _handle(String point, double x, double y) {
    return Positioned(
      left: canvasSize.width * x - 8,
      top: canvasSize.height * y - 8,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => onDrag(point, details.delta),
        onPanEnd: (_) => onDragEnd(point),
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2563EB), width: 2),
          ),
        ),
      ),
    );
  }
}
