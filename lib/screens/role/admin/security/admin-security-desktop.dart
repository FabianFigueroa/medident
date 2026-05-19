import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-logger.dart';
import 'package:medident/screens/role/admin/security/bluid-header.dart';
import 'package:medident/screens/role/admin/security/models.dart';
import 'package:medident/screens/role/admin/security/widgets/bim_viewer_panel.dart';
import 'package:medident/screens/role/admin/security/widgets/device_config_panel.dart';
import 'package:medident/screens/role/admin/security/widgets/floor_selector_panel.dart';
import 'package:medident/screens/widgets/role/security/template.dart';

class AdminSecurityDesktop extends StatefulWidget {
  const AdminSecurityDesktop({super.key});

  @override
  State<AdminSecurityDesktop> createState() => _AdminSecurityDesktopState();
}

class _AdminSecurityDesktopState extends State<AdminSecurityDesktop> {
  static const _logTag = 'ADMIN_SECURITY_BIM';
  late final List<LayoutTemplateModel> _templates;
  late final List<FloorConfigModel> _floors;
  final List<_UndoSnapshot> _undoStack = [];
  final Map<int, Rect> _pendingSnapshots = {};
  final _deviceCatalog = const [
    DeviceCatalogItem(
      'Sensor puerta',
      Icons.sensors_rounded,
      Color(0xFF2563EB),
    ),
    DeviceCatalogItem('Camara IP', Icons.videocam_rounded, Color(0xFF16A34A)),
    DeviceCatalogItem(
      'Alarma',
      Icons.notifications_active_rounded,
      Color(0xFFDC2626),
    ),
    DeviceCatalogItem(
      'Control acceso',
      Icons.lock_open_rounded,
      Color(0xFF7C3AED),
    ),
    DeviceCatalogItem(
      'Detector humo',
      Icons.local_fire_department_rounded,
      Color(0xFFF97316),
    ),
    DeviceCatalogItem(
      'Sensor ventana',
      Icons.window_rounded,
      Color(0xFF0891B2),
    ),
    DeviceCatalogItem(
      'Boton panico',
      Icons.emergency_share_rounded,
      Color(0xFFBE123C),
    ),
    DeviceCatalogItem(
      'Lector biometrico',
      Icons.fingerprint_rounded,
      Color(0xFF4F46E5),
    ),
    DeviceCatalogItem('Sirena', Icons.campaign_rounded, Color(0xFFCA8A04)),
    DeviceCatalogItem(
      'Movimiento',
      Icons.directions_walk_rounded,
      Color(0xFF059669),
    ),
  ];

  int _activeFloor = 0;
  int _selectedRoom = 0;
  int _selectedDevice = 0;
  DoorSideEnums? _selectedWall;
  String _draftLabel = 'Sensor acceso';
  bool _showGrid = true;
  bool _snapEnabled = true;

  @override
  void initState() {
    super.initState();
    _templates = [
      LayoutTemplateModel(
        id: 't1',
        nombre: 'Consultorio Basico',
        descripcion:
            'Recepcion y oficina con muros listos para puntos de seguridad.',
        rooms: [
          RoomBlueprintModel(
            't1-r1',
            'Recepcion',
            0.08,
            0.08,
            0.34,
            0.42,
            doors: [
              DoorBlueprintModel(side: DoorSideEnums.bottom, offset: 0.5),
            ],
          ),
          RoomBlueprintModel(
            't1-r2',
            'Oficina',
            0.42,
            0.08,
            0.26,
            0.26,
            doors: [DoorBlueprintModel(side: DoorSideEnums.left, offset: 0.5)],
          ),
        ],
      ),
      LayoutTemplateModel(
        id: 't2',
        nombre: 'Dos Consultorios',
        descripcion: 'Recepcion conectada con dos consultorios laterales.',
        rooms: [
          RoomBlueprintModel(
            't2-r1',
            'Recepcion',
            0.08,
            0.08,
            0.34,
            0.26,
            doors: [
              DoorBlueprintModel(side: DoorSideEnums.bottom, offset: 0.5),
            ],
          ),
          RoomBlueprintModel(
            't2-r2',
            'Consultorio 1',
            0.42,
            0.08,
            0.26,
            0.26,
            doors: [DoorBlueprintModel(side: DoorSideEnums.left, offset: 0.5)],
          ),
          RoomBlueprintModel(
            't2-r3',
            'Consultorio 2',
            0.42,
            0.34,
            0.26,
            0.26,
            doors: [DoorBlueprintModel(side: DoorSideEnums.left, offset: 0.5)],
          ),
        ],
      ),
    ];
    _floors = [
      FloorConfigModel(
        nombre: 'Piso 1',
        templateId: 't1',
        wallStyle: 'Muro liviano',
        roomCount: 2,
        rooms: _cloneRooms('t1'),
        points: [],
      ),
    ];
  }

  List<RoomBlueprintModel> _cloneRooms(String templateId) {
    final template = _templates.firstWhere(
      (template) => template.id == templateId,
    );
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return [
      for (var i = 0; i < template.rooms.length; i++)
        RoomBlueprintModel(
          '$templateId-$stamp-$i',
          template.rooms[i].nombre,
          template.rooms[i].x,
          template.rooms[i].y,
          template.rooms[i].w,
          template.rooms[i].h,
          doors: [
            for (final door in template.rooms[i].doors)
              DoorBlueprintModel(side: door.side, offset: door.offset),
          ],
        ),
    ];
  }

  void _addFloor() {
    setState(() {
      final floorNumber = _floors.length + 1;
      AppLogger.log(_logTag, 'Agregando Piso $floorNumber.');
      _floors.add(
        FloorConfigModel(
          nombre: 'Piso $floorNumber',
          templateId: 't1',
          wallStyle: 'Muro liviano',
          roomCount: 0,
          rooms: [],
          points: [],
        ),
      );
      _activeFloor = _floors.length - 1;
      _selectedRoom = 0;
      _selectedWall = null;
    });
  }

  void _deleteFloor(int index) {
    if (_floors.length <= 1) return;
    setState(() {
      AppLogger.log(_logTag, 'Eliminando piso index=$index.');
      _floors.removeAt(index);
      _activeFloor = math.min(_activeFloor, _floors.length - 1);
      _selectedRoom = 0;
      _selectedWall = null;
    });
  }

  void _applyTemplate(String templateId) {
    setState(() {
      AppLogger.log(_logTag, 'Aplicando plantilla BIM templateId=$templateId.');
      final rooms = _cloneRooms(templateId);
      final floor = _floors[_activeFloor];
      floor
        ..templateId = templateId
        ..rooms = rooms
        ..roomCount = rooms.length
        ..points.clear();
      _selectedRoom = 0;
      _selectedWall = null;
      _undoStack.clear();
      _pendingSnapshots.clear();
    });
  }

  void _setRoomCount(int count) {
    setState(() {
      AppLogger.log(_logTag, 'Cambiando cantidad de habitaciones a $count.');
      final floor = _floors[_activeFloor];
      floor.roomCount = count;
      floor.rooms = _buildRoomsForCount(count);
      floor.points.clear();
      _selectedRoom = 0;
      _selectedWall = null;
      _undoStack.clear();
      _pendingSnapshots.clear();
    });
  }

  List<RoomBlueprintModel> _buildRoomsForCount(int count) {
    const gap = 0.025;
    final columns = math.min(3, math.max(1, math.sqrt(count).ceil()));
    final rows = (count / columns).ceil();
    final width = (0.82 - gap * (columns - 1)) / columns;
    final height = (0.72 - gap * (rows - 1)) / rows;
    return [
      for (var i = 0; i < count; i++)
        RoomBlueprintModel(
          'custom-${DateTime.now().microsecondsSinceEpoch}-$i',
          'Habitacion ${i + 1}',
          0.08 + (i % columns) * (width + gap),
          0.08 + (i ~/ columns) * (height + gap),
          width,
          height,
          doors: [DoorBlueprintModel(side: DoorSideEnums.bottom, offset: 0.5)],
        ),
    ];
  }

  Future<void> _showRoomOptions(int roomIndex) async {
    final room = _floors[_activeFloor].rooms[roomIndex];
    AppLogger.log(
      _logTag,
      'Mostrando opciones para roomIndex=$roomIndex nombre=${room.nombre}.',
    );
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(room.nombre),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agrega un dispositivo o ajusta los accesos de esta habitacion.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _deviceCatalog.asMap().entries.map((entry) {
                    final index = entry.key;
                    final device = entry.value;
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        _addPoint(roomIndex: roomIndex, deviceIndex: index);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: device.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: device.color.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(device.icon, color: device.color, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                device.nombre,
                                style: TextStyle(
                                  color: device.color,
                                  fontSize: 12,
                                  fontFamily: 'Ubuntu-Medium',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _selectedWall = DoorSideEnums.bottom);
              },
              child: const Text('Seleccionar puerta'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addPoint(roomIndex: roomIndex);
              },
              child: const Text('Agregar seleccionado'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _pushUndo(String action, int roomIndex, Rect rect) {
    _undoStack.add(_UndoSnapshot(action, roomIndex, rect));
  }

  void _captureSnapshot(int roomIndex) {
    _pendingSnapshots.putIfAbsent(roomIndex, () {
      final room = _floors[_activeFloor].rooms[roomIndex];
      return Rect.fromLTWH(room.x, room.y, room.w, room.h);
    });
  }

  Future<void> _commitSnapshot(String action, int roomIndex) async {
    final snapshot = _pendingSnapshots.remove(roomIndex);
    if (snapshot == null) return;
    if (roomIndex < 0 || roomIndex >= _floors[_activeFloor].rooms.length) {
      return;
    }

    AppLogger.log(_logTag, 'Confirmando accion=$action roomIndex=$roomIndex.');
    _snapRoomToNeighbors(roomIndex);
    _keepRoomInside(_floors[_activeFloor].rooms[roomIndex]);

    final overlappedRooms = _overlappedRooms(roomIndex);
    if (overlappedRooms.isNotEmpty) {
      AppLogger.log(
        _logTag,
        'Superposicion detectada roomIndex=$roomIndex overlaps=$overlappedRooms.',
      );
      final decision = await _askOverlapDecision(roomIndex, overlappedRooms);
      if (!mounted) return;
      AppLogger.log(_logTag, 'Decision de superposicion: $decision.');
      if (decision == _OverlapDecision.cancel) {
        _restoreRoom(roomIndex, snapshot);
        return;
      }
      if (decision == _OverlapDecision.addDoor) {
        _addDoorBetweenRooms(roomIndex, overlappedRooms.first);
      }
      if (decision == _OverlapDecision.addWindow) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La ventana queda pendiente hasta crear WindowBlueprintModel.',
            ),
          ),
        );
      }
    }

    _pushUndo(action, roomIndex, snapshot);
    setState(() {});
  }

  List<int> _overlappedRooms(int roomIndex) {
    final rooms = _floors[_activeFloor].rooms;
    final roomRect = _roomRect(rooms[roomIndex]);
    return [
      for (var i = 0; i < rooms.length; i++)
        if (i != roomIndex && roomRect.overlaps(_roomRect(rooms[i]))) i,
    ];
  }

  Rect _roomRect(RoomBlueprintModel room) {
    return Rect.fromLTWH(room.x, room.y, room.w, room.h);
  }

  void _restoreRoom(int roomIndex, Rect snapshot) {
    setState(() {
      final room = _floors[_activeFloor].rooms[roomIndex];
      room
        ..x = snapshot.left
        ..y = snapshot.top
        ..w = snapshot.width
        ..h = snapshot.height;
    });
  }

  Future<_OverlapDecision> _askOverlapDecision(
    int roomIndex,
    List<int> overlappedRooms,
  ) async {
    final floor = _floors[_activeFloor];
    final room = floor.rooms[roomIndex];
    final names = overlappedRooms
        .map((index) => floor.rooms[index].nombre)
        .join(', ');
    final decision = await showDialog<_OverlapDecision>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Habitaciones superpuestas'),
          content: Text(
            '${room.nombre} esta montada sobre: $names.\n\nQuieres conservar ese cambio?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(_OverlapDecision.cancel),
              child: const Text('Cancelar cambio'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(_OverlapDecision.keep),
              child: const Text('Mantener sin acceso'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(_OverlapDecision.addDoor),
              child: const Text('Agregar puerta'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(_OverlapDecision.addWindow),
              child: const Text('Agregar ventana'),
            ),
          ],
        );
      },
    );
    return decision ?? _OverlapDecision.cancel;
  }

  void _addDoorBetweenRooms(int roomIndex, int otherIndex) {
    final rooms = _floors[_activeFloor].rooms;
    final room = rooms[roomIndex];
    final other = rooms[otherIndex];
    final side = _nearestSide(room, other);
    setState(() {
      AppLogger.log(
        _logTag,
        'Agregando puerta entre roomIndex=$roomIndex y otherIndex=$otherIndex side=$side.',
      );
      room.doors.add(DoorBlueprintModel(side: side, offset: 0.5));
      _selectedRoom = roomIndex;
      _selectedWall = side;
    });
  }

  DoorSideEnums _nearestSide(
    RoomBlueprintModel room,
    RoomBlueprintModel other,
  ) {
    final roomCenter = _roomRect(room).center;
    final otherCenter = _roomRect(other).center;
    final dx = otherCenter.dx - roomCenter.dx;
    final dy = otherCenter.dy - roomCenter.dy;
    if (dx.abs() > dy.abs()) {
      return dx > 0 ? DoorSideEnums.right : DoorSideEnums.left;
    }
    return dy > 0 ? DoorSideEnums.bottom : DoorSideEnums.top;
  }

  void _popUndo() {
    if (_undoStack.isEmpty) return;
    final snapshot = _undoStack.removeLast();
    final rooms = _floors[_activeFloor].rooms;
    if (snapshot.roomIndex < 0 || snapshot.roomIndex >= rooms.length) return;
    setState(() {
      AppLogger.log(
        _logTag,
        'Deshaciendo ${snapshot.action} en roomIndex=${snapshot.roomIndex}.',
      );
      final room = rooms[snapshot.roomIndex];
      room
        ..x = snapshot.rect.left
        ..y = snapshot.rect.top
        ..w = snapshot.rect.width
        ..h = snapshot.rect.height;
    });
  }

  void _onRoomDrag(int roomIndex, Offset delta) {
    setState(() {
      final room = _floors[_activeFloor].rooms[roomIndex];
      _captureSnapshot(roomIndex);
      room
        ..x += delta.dx
        ..y += delta.dy;
      _keepRoomInside(room);
    });
  }

  void _onPointDrag(int roomIndex, String point, Offset delta) {
    setState(() {
      final room = _floors[_activeFloor].rooms[roomIndex];
      _captureSnapshot(roomIndex);
      switch (point) {
        case 'tl':
          room
            ..x += delta.dx
            ..y += delta.dy
            ..w -= delta.dx
            ..h -= delta.dy;
        case 'tr':
          room
            ..y += delta.dy
            ..w += delta.dx
            ..h -= delta.dy;
        case 'bl':
          room
            ..x += delta.dx
            ..w -= delta.dx
            ..h += delta.dy;
        case 'br':
          room
            ..w += delta.dx
            ..h += delta.dy;
      }
      _normalizeRoom(room);
    });
  }

  void _snapRoomToNeighbors(int roomIndex) {
    if (!_snapEnabled) return;
    final rooms = _floors[_activeFloor].rooms;
    final room = rooms[roomIndex];
    const threshold = 0.018;
    const grid = 0.02;

    room
      ..x = (room.x / grid).round() * grid
      ..y = (room.y / grid).round() * grid;

    for (var i = 0; i < rooms.length; i++) {
      if (i == roomIndex) continue;
      final other = rooms[i];
      if (_verticalOverlap(room, other)) {
        if ((room.x - (other.x + other.w)).abs() < threshold) {
          room.x = other.x + other.w;
        } else if ((room.x + room.w - other.x).abs() < threshold) {
          room.x = other.x - room.w;
        }
      }
      if (_horizontalOverlap(room, other)) {
        if ((room.y - (other.y + other.h)).abs() < threshold) {
          room.y = other.y + other.h;
        } else if ((room.y + room.h - other.y).abs() < threshold) {
          room.y = other.y - room.h;
        }
      }
    }
  }

  bool _verticalOverlap(RoomBlueprintModel a, RoomBlueprintModel b) {
    return math.max(a.y, b.y) < math.min(a.y + a.h, b.y + b.h);
  }

  bool _horizontalOverlap(RoomBlueprintModel a, RoomBlueprintModel b) {
    return math.max(a.x, b.x) < math.min(a.x + a.w, b.x + b.w);
  }

  void _normalizeRoom(RoomBlueprintModel room) {
    room
      ..w = room.w.clamp(0.12, 0.9)
      ..h = room.h.clamp(0.12, 0.9);
    _keepRoomInside(room);
  }

  void _keepRoomInside(RoomBlueprintModel room) {
    room
      ..x = room.x.clamp(0.0, 1.0 - room.w)
      ..y = room.y.clamp(0.0, 1.0 - room.h);
  }

  void _addPoint({int? roomIndex, int? deviceIndex}) {
    final floor = _floors[_activeFloor];
    if (floor.rooms.isEmpty) return;
    final targetRoomIndex = (roomIndex ?? _selectedRoom).clamp(
      0,
      floor.rooms.length - 1,
    );
    final targetDeviceIndex = (deviceIndex ?? _selectedDevice).clamp(
      0,
      _deviceCatalog.length - 1,
    );
    final room = floor.rooms[targetRoomIndex];
    final device = _deviceCatalog[targetDeviceIndex];
    setState(() {
      AppLogger.log(
        _logTag,
        'Agregando dispositivo ${device.nombre} en roomIndex=$targetRoomIndex nombre=${room.nombre}.',
      );
      floor.points.add(
        DevicePointModel(
          roomIndex: targetRoomIndex,
          label: _draftLabel.trim().isEmpty
              ? device.nombre
              : _draftLabel.trim(),
          type: device.nombre,
          x: 0.5,
          y: 0.5,
        ),
      );
      _draftLabel = '${device.nombre} ${room.nombre}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final floor = _floors[_activeFloor];
    final RoomBlueprintModel? selectedRoom;
    if (floor.rooms.isEmpty) {
      selectedRoom = null;
    } else {
      selectedRoom =
          floor.rooms[_selectedRoom.clamp(0, floor.rooms.length - 1)];
    }
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: BuilderHeaderWidget(
              floors: _floors.length,
              totalPoints: _floors.fold(
                0,
                (total, floor) => total + floor.points.length,
              ),
              canUndo: _undoStack.isNotEmpty,
              onUndo: _popUndo,
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 8, 16),
                    // COLUMNA 1: Selector de pisos, plantilla BIM y cantidad
                    // de habitaciones. Aqui despues conectamos Provider para
                    // leer el estado activo y Firebase para guardar floors,
                    // templateId, roomCount y rooms del piso seleccionado.
                    child: FloorSelectorPanel(
                      floors: _floors,
                      activeFloor: _activeFloor,
                      templates: _templates,
                      onAddFloor: _addFloor,
                      onDeleteFloor: _deleteFloor,
                      onSelectFloor: (index) {
                        setState(() {
                          _activeFloor = index;
                          _selectedRoom = 0;
                          _selectedWall = null;
                        });
                      },
                      onTemplateChanged: _applyTemplate,
                      onRoomCountChanged: _setRoomCount,
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  // COLUMNA 2: Widget BIM reutilizable. Recibe el FloorConfigModel
                  // activo y callbacks de interaccion; mas adelante Provider puede
                  // exponer floor/showGrid/snapEnabled y Firebase persistir cambios
                  // de rooms, muros, puertas y puntos.
                  child: BimViewerPanel(
                    floor: floor,
                    showGrid: _showGrid,
                    snapEnabled: _snapEnabled,
                    selectedRoom: _selectedRoom,
                    selectedWall: _selectedWall,
                    onRoomSelected: (roomIndex) {
                      setState(() {
                        _selectedRoom = roomIndex;
                        _selectedWall = null;
                      });
                    },
                    onRoomOptionsRequested: _showRoomOptions,
                    onWallSelected: (roomIndex, wallSide) {
                      setState(() {
                        _selectedRoom = roomIndex;
                        _selectedWall = wallSide;
                      });
                    },
                    onPointDrag: _onPointDrag,
                    onPointDragEnd: (roomIndex, _) {
                      _commitSnapshot('resize', roomIndex);
                    },
                    onRoomDrag: _onRoomDrag,
                    onRoomDragEnd: (roomIndex) {
                      _commitSnapshot('move', roomIndex);
                    },
                    onUndo: _popUndo,
                    onToggleGrid: () => setState(() => _showGrid = !_showGrid),
                    onToggleSnap: () =>
                        setState(() => _snapEnabled = !_snapEnabled),
                  ),
                ),
                Expanded(
                  flex: 2,
                  // COLUMNA 3: Panel de dispositivos. Aqui despues conectamos el
                  // catalogo desde Provider/Firebase y guardamos points como
                  // subcoleccion o campo embebido del floor activo.
                  child: DeviceConfigPanel(
                    room: selectedRoom,
                    points: floor.points,
                    deviceCatalog: _deviceCatalog,
                    selectedDevice: _selectedDevice,
                    draftLabel: _draftLabel,
                    onSelectDevice: (index) =>
                        setState(() => _selectedDevice = index),
                    onDraftLabelChanged: (label) =>
                        setState(() => _draftLabel = label),
                    onAddPoint: _addPoint,
                    onRemovePoint: (point) =>
                        setState(() => floor.points.remove(point)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UndoSnapshot {
  final String action;
  final int roomIndex;
  final Rect rect;

  const _UndoSnapshot(this.action, this.roomIndex, this.rect);
}

enum _OverlapDecision { cancel, keep, addDoor, addWindow }
