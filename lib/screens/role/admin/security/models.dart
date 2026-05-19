//////////////////////// enums
enum DoorSideEnums { top, right, bottom, left }

class DoorBlueprintModel {
  final DoorSideEnums side;
  final double offset;
  const DoorBlueprintModel({required this.side, required this.offset});
}

/////////////////////////////// model
class DevicePointModel {
  final int roomIndex;
  final String label;
  final String type;
  final double x;
  final double y;

  const DevicePointModel({
    required this.roomIndex,
    required this.label,
    required this.type,
    required this.x,
    required this.y,
  });
}

/////////////////////////////////////////////////////////// models

class FloorConfigModel {
  final String nombre;
  String templateId;
  String wallStyle;
  int roomCount;
  List<RoomBlueprintModel> rooms;
  final List<DevicePointModel> points;

  FloorConfigModel({
    required this.nombre,
    required this.templateId,
    required this.wallStyle,
    required this.roomCount,
    required this.rooms,
    required this.points,
  });
}

class RoomBlueprintModel {
  final String id;
  String nombre;
  double x;
  double y;
  double w;
  double h;
  final List<DoorBlueprintModel> doors;

  RoomBlueprintModel(
    this.id,
    this.nombre,
    this.x,
    this.y,
    this.w,
    this.h, {
    this.doors = const [],
  });
}
