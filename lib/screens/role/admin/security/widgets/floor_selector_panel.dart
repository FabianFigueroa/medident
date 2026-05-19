import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/role/admin/security/models.dart';
import 'package:medident/screens/widgets/role/security/template.dart';

class FloorSelectorPanel extends StatelessWidget {
  final List<FloorConfigModel> floors;
  final int activeFloor;
  final List<LayoutTemplateModel> templates;
  final VoidCallback onAddFloor;
  final Function(int) onDeleteFloor;
  final Function(int) onSelectFloor;
  final ValueChanged<String> onTemplateChanged;
  final ValueChanged<int> onRoomCountChanged;

  const FloorSelectorPanel({
    super.key,
    required this.floors,
    required this.activeFloor,
    required this.templates,
    required this.onAddFloor,
    required this.onDeleteFloor,
    required this.onSelectFloor,
    required this.onTemplateChanged,
    required this.onRoomCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = floors[activeFloor];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pisos de la clinica',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Ubuntu-Medium',
            color: AppColors.grey800,
          ),
        ),
        const SizedBox(height: 8),
        ...floors.asMap().entries.map((entry) {
          final index = entry.key;
          final floor = entry.value;
          final isActive = index == activeFloor;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isActive
                      ? const Color(0xFF3A7AFE)
                      : const Color(0xFFE2E8F0),
                  width: isActive ? 1.5 : 1,
                ),
              ),
              tileColor: isActive ? const Color(0xFFEFF3FE) : Colors.white,
              title: Text(
                floor.nombre,
                style: TextStyle(
                  fontFamily: isActive ? 'Ubuntu-Medium' : 'Ubuntu-Regular',
                  color: isActive ? const Color(0xFF3A7AFE) : AppColors.grey800,
                ),
              ),
              trailing: floors.length > 1
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      onPressed: () => onDeleteFloor(index),
                      tooltip: 'Eliminar piso',
                    )
                  : null,
              onTap: () => onSelectFloor(index),
            ),
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddFloor,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar piso'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.grey700,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Plantilla BIM',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Ubuntu-Medium',
            color: AppColors.grey800,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue:
              templates.any((template) => template.id == active.templateId)
              ? active.templateId
              : templates.first.id,
          items: templates
              .map(
                (template) => DropdownMenuItem(
                  value: template.id,
                  child: Text(template.nombre),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onTemplateChanged(value);
          },
          decoration: _inputDecoration('Selecciona una plantilla'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: active.roomCount.clamp(1, 8),
          items: List.generate(8, (index) {
            final count = index + 1;
            return DropdownMenuItem(
              value: count,
              child: Text('$count habitaciones'),
            );
          }),
          onChanged: (value) {
            if (value != null) onRoomCountChanged(value);
          },
          decoration: _inputDecoration('Cantidad de habitaciones'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }
}
