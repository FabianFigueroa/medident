import 'package:flutter/material.dart';
import 'package:medident/core/models/roles/dentist/dentist-security-model.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

/// Widget para gestionar empleados (CRUD)
class DentistEmployeeManager extends StatefulWidget {
  const DentistEmployeeManager({super.key});

  @override
  State<DentistEmployeeManager> createState() => _DentistEmployeeManagerState();
}

class _DentistEmployeeManagerState extends State<DentistEmployeeManager> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  final List<Map<String, String>> employees = [
    {'name': 'Dr. Roberto Silva', 'role': 'Odontólogo', 'status': '✅', 'avatar': '🧑‍⚕️'},
    {'name': 'Dra. Laura Martínez', 'role': 'Odontólogo', 'status': '✅', 'avatar': '👩‍⚕️'},
    {'name': 'Carlos García', 'role': 'Asistente', 'status': '⏸️', 'avatar': '👨‍🔧'},
    {'name': 'María López', 'role': 'Recepción', 'status': '✅', 'avatar': '👩‍💼'},
  ];

  @override
  Widget build(BuildContext context) {
    debugPrint('[DentistEmployeeManager] build() iniciado');
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('👥 Personal de Turno', style: AppTextStyles.headlineSmall),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                  onPressed: () => _showAddEmployeeDialog(context),
                )
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final emp = employees[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
                  child: ListTile(
                    leading: Text(emp['avatar']!, style: const TextStyle(fontSize: 28)),
                    title: Text(emp['name']!, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(emp['role']!),
                    trailing: Wrap(
                      spacing: AppConstants.paddingXS,
                      children: [
                        Chip(label: Text(emp['status']!)),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(child: const Text('Editar')),
                            PopupMenuItem(child: const Text('Eliminar')),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Empleado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: AppConstants.paddingS),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Puesto'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _roleController.text.isNotEmpty) {
                setState(() {
                  employees.add({
                    'name': _nameController.text,
                    'role': _roleController.text,
                    'status': '✅',
                    'avatar': '👤',
                  });
                });
                Navigator.pop(context);
                _nameController.clear();
                _roleController.clear();
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }
}
