import 'package:flutter/material.dart';
import 'package:medident/core/models/roles/dentist/dentist-sensor-model.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:provider/provider.dart';

class DentistSensorSection extends StatelessWidget {
  const DentistSensorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DentistSecurityProvider>(
      builder: (context, provider, child) {
        final sensors = provider.securityData?.sensors ?? [];

        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias, // Asegura que el contenido respete los bordes redondeados
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sensores de la Clínica',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
                      tooltip: 'Añadir Sensor',
                      onPressed: () => _showAddSensorDialog(context),
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (sensors.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'No hay sensores instalados.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sensors.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final sensor = sensors[index];
                      return ListTile(
                        leading: Icon(
                          _getSensorIcon(sensor.type),
                          color: sensor.isOnline ? Colors.green.shade600 : Colors.grey.shade700,
                          size: 28,
                        ),
                        title: Text(sensor.sensorName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text('ID: ${sensor.sensorId}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              avatar: CircleAvatar(
                                backgroundColor: sensor.isOnline ? Colors.green.shade100 : Colors.grey.shade300,
                                child: Icon(
                                  sensor.isOnline ? Icons.check_circle : Icons.cancel,
                                  color: sensor.isOnline ? Colors.green.shade800 : Colors.grey.shade700,
                                  size: 16,
                                ),
                              ),
                              label: Text(
                                sensor.isOnline ? 'En línea' : 'Offline',
                                style: TextStyle(
                                  color: sensor.isOnline ? Colors.green.shade900 : Colors.grey.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: sensor.isOnline ? Colors.green.shade50 : Colors.grey.shade200,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: 'Eliminar Sensor',
                              onPressed: () => _confirmDeleteSensor(context, sensor),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getSensorIcon(String type) {
    switch (type.toLowerCase()) {
      case 'door':
        return Icons.door_sliding_outlined;
      case 'window':
        return Icons.sensor_window_outlined;
      case 'motion':
        return Icons.sensors_outlined;
      default:
        return Icons.device_unknown_outlined;
    }
  }

  void _showAddSensorDialog(BuildContext context) {
    final provider = context.read<DentistSecurityProvider>();
    final sensorIdController = TextEditingController();
    final nameController = TextEditingController();
    String selectedType = 'door'; // Valor inicial para el Dropdown

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Añadir Nuevo Sensor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sensorIdController,
                decoration: const InputDecoration(labelText: 'ID del Sensor', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre (Ej: Puerta Principal)', border: OutlineInputBorder()),
              ),
              // Aquí podrías añadir un Dropdown para el tipo de sensor si quieres
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Añadir', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (sensorIdController.text.isNotEmpty && nameController.text.isNotEmpty) {
                  final newSensor = DentistSensorModel(
                    sensorId: sensorIdController.text,
                    sensorName: nameController.text,
                    type: selectedType,
                    isOnline: false, // Por defecto aparece offline
                  );
                  provider.addSensor(newSensor);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSensor(BuildContext context, DentistSensorModel sensor) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar el sensor "${sensor.sensorName}"? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
              onPressed: () {
                context.read<DentistSecurityProvider>().deleteSensor(sensor);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
