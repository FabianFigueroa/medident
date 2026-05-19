import 'package:medident/screens/role/admin/security/models.dart';

class LayoutTemplateModel {
  final String id;
  final String nombre;
  final String descripcion;
  final List<RoomBlueprintModel> rooms;

  const LayoutTemplateModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.rooms,
  });
}
