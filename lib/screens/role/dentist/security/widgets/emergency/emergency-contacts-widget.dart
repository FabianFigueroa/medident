import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';

/// Modelo para contactos de emergencia
class EmergencyContact {
  final String name;
  final String phone;
  final int priority;

  const EmergencyContact({
    required this.name,
    required this.phone,
    this.priority = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'priority': priority,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      priority: map['priority'] ?? 1,
    );
  }
}

/// Widget para gestionar contactos de emergencia
class EmergencyContactsWidget extends StatefulWidget {
  const EmergencyContactsWidget({super.key});

  @override
  State<EmergencyContactsWidget> createState() => _EmergencyContactsWidgetState();
}

class _EmergencyContactsWidgetState extends State<EmergencyContactsWidget> {
  final List<EmergencyContact> _contacts = [
    const EmergencyContact(name: 'Policía', phone: '911', priority: 1),
    const EmergencyContact(name: 'Bomberos', phone: '100', priority: 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Contactos de Emergencia', style: AppTextStyles.headlineSmall),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddContactDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            final contact = _contacts[index];
            return Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.emergency, color: Colors.red),
                ),
                title: Text(contact.name),
                subtitle: Text(contact.phone),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () {
                    // Lógica para llamar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Llamando a ${contact.name}')),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Contacto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                setState(() {
                  _contacts.add(EmergencyContact(
                    name: nameController.text,
                    phone: phoneController.text,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
