import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-textstyle.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

/// Widget para configurar lectores RFID
class RfidReadersConfigWidget extends StatefulWidget {
  const RfidReadersConfigWidget({super.key});

  @override
  State<RfidReadersConfigWidget> createState() => _RfidReadersConfigWidgetState();
}

class _RfidReadersConfigWidgetState extends State<RfidReadersConfigWidget> {
  final _formKey = GlobalKey<FormState>();
  final _readerIdController = TextEditingController();
  final _locationController = TextEditingController();
  bool _hasCamera = false;
  String _selectedType = 'entrance';

  @override
  void dispose() {
    _readerIdController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistSecurityProvider>();
    final readers = provider.securityData?.readers ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lectores RFID', style: AppTextStyles.headlineSmall),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar'),
              onPressed: () => _showAddReaderDialog(context, provider),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (readers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No hay lectores configurados',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: readers.length,
            itemBuilder: (context, index) {
              final reader = readers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: reader.isOnline
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.contactless,
                      color: reader.isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  title: Text(reader.readerId),
                  subtitle: Text('${reader.location} • ${reader.type}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (reader.hasCamera)
                        const Icon(Icons.camera, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Icon(
                        reader.isOnline ? Icons.wifi : Icons.wifi_off,
                        color: reader.isOnline ? Colors.green : Colors.red,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAddReaderDialog(BuildContext context, DentistSecurityProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Lector RFID'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _readerIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del Lector',
                  hintText: 'reader_001',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  hintText: 'Entrada Principal',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'entrance', child: Text('Entrada')),
                  DropdownMenuItem(value: 'office', child: Text('Consultorio')),
                  DropdownMenuItem(value: 'emergency', child: Text('Emergencia')),
                ],
                onChanged: (v) => _selectedType = v ?? 'entrance',
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _hasCamera,
                title: const Text('¿Tiene Cámara?'),
                onChanged: (v) => setState(() => _hasCamera = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final reader = RfidReaderModel(
                  readerId: _readerIdController.text,
                  location: _locationController.text,
                  hasCamera: _hasCamera,
                  type: _selectedType,
                );
                await provider.addReader(reader);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
