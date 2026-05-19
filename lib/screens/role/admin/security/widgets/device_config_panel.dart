import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/role/admin/security/models.dart';

class DeviceConfigPanel extends StatelessWidget {
  final RoomBlueprintModel? room;
  final List<DevicePointModel> points;
  final List<DeviceCatalogItem> deviceCatalog;
  final int selectedDevice;
  final String draftLabel;
  final Function(int) onSelectDevice;
  final Function(String) onDraftLabelChanged;
  final VoidCallback onAddPoint;
  final Function(DevicePointModel) onRemovePoint;

  const DeviceConfigPanel({
    super.key,
    this.room,
    required this.points,
    required this.deviceCatalog,
    required this.selectedDevice,
    required this.draftLabel,
    required this.onSelectDevice,
    required this.onDraftLabelChanged,
    required this.onAddPoint,
    required this.onRemovePoint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (room != null) ...[
            _buildRoomInfo(room!),
            const SizedBox(height: 20),
          ],
          _buildDeviceSelector(),
          const SizedBox(height: 20),
          _buildDevicePoints(),
        ],
      ),
    );
  }

  Widget _buildRoomInfo(RoomBlueprintModel room) {
    final pointsInRoom = points.where((p) => p.roomIndex == room.id).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room.nombre,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Ubuntu-Bold',
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${room.id}',
            style: const TextStyle(fontSize: 12, color: AppColors.grey500),
          ),
          const Divider(height: 24),
          const Text(
            'Dispositivos instalados:',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Ubuntu-Medium',
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          if (pointsInRoom.isEmpty)
            const Text(
              'Ninguno. Arrastra un dispositivo para instalar.',
              style: TextStyle(fontSize: 12, color: AppColors.grey500),
            )
          else
            ...pointsInRoom.map((p) {
              final device = deviceCatalog.firstWhere(
                (d) => d.nombre == p.type,
                orElse: () => const DeviceCatalogItem(
                  'Desconocido',
                  Icons.help_outline,
                  Colors.grey,
                ),
              );
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(device.icon, color: device.color, size: 20),
                title: Text(p.label, style: const TextStyle(fontSize: 14)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => onRemovePoint(p),
                  tooltip: 'Eliminar dispositivo',
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDeviceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catalogo de dispositivos',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Ubuntu-Medium',
            color: AppColors.grey800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: deviceCatalog.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == selectedDevice;
            return InkWell(
              onTap: () => onSelectDevice(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.color.withValues(alpha: 0.15)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? item.color : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(item.icon, color: item.color, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      item.nombre,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: isSelected
                            ? 'Ubuntu-Medium'
                            : 'Ubuntu-Regular',
                        color: isSelected ? item.color : AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDevicePoints() {
    final device = deviceCatalog[selectedDevice];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configurar y agregar',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Ubuntu-Medium',
            color: AppColors.grey800,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: TextEditingController(text: draftLabel),
          onChanged: onDraftLabelChanged,
          decoration: InputDecoration(
            labelText: 'Etiqueta del dispositivo',
            hintText: 'Ej: Sensor puerta principal',
            prefixIcon: Icon(device.icon, color: device.color),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddPoint,
            icon: const Icon(Icons.add_location_alt_rounded),
            label: Text('Agregar a ${room?.nombre ?? 'seleccion'}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A7AFE),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DeviceCatalogItem {
  final String nombre;
  final IconData icon;
  final Color color;
  const DeviceCatalogItem(this.nombre, this.icon, this.color);
}
