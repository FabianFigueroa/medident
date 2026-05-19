import 'package:flutter/material.dart';

// --- Modelos de Datos ---

class Device {
  final String id;
  final String name;
  final IconData icon;
  bool isOn;

  Device({required this.id, required this.name, required this.icon, this.isOn = false});
}

class Room {
  final String id;
  final String name;
  final String status;
  final List<Device> devices;

  Room({required this.id, required this.name, required this.status, required this.devices});
}

// --- Widget Principal ---

class DentistSecurityDashboardMobile extends StatefulWidget {
  const DentistSecurityDashboardMobile({super.key});

  @override
  _DentistSecurityDashboardMobileState createState() => _DentistSecurityDashboardMobileState();
}

class _DentistSecurityDashboardMobileState extends State<DentistSecurityDashboardMobile> {
  // --- Datos de Ejemplo ---
  final List<Room> _rooms = [
    Room(id: 'r1', name: 'Recepción', status: 'Normal', devices: [
      Device(id: 'd1', name: 'Luz Principal', icon: Icons.lightbulb_outline),
      Device(id: 'd2', name: 'Ventilador', icon: Icons.air_outlined),
    ]),
    Room(id: 'r2', name: 'Consultorio 1', status: 'Normal', devices: [
      Device(id: 'd3', name: 'Luz Consultorio', icon: Icons.lightbulb_outline),
      Device(id: 'd4', name: 'Aire Acondicionado', icon: Icons.ac_unit_outlined),
      Device(id: 'd5', name: 'Cámara de Seguridad', icon: Icons.videocam_outlined),
    ]),
    Room(id: 'r3', name: 'Sala de Espera', status: 'Normal', devices: [
      Device(id: 'd6', name: 'Luz Sala', icon: Icons.lightbulb_outline),
    ]),
  ];

  Room? _selectedRoom;

  @override
  void initState() {
    super.initState();
    if (_rooms.isNotEmpty) {
      _selectedRoom = _rooms.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusContainer('Normal'),
            const SizedBox(height: 24),
            _buildSummaryCards(),
            const SizedBox(height: 24),
            const Text('Habitaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildRoomsList(),
            const SizedBox(height: 24),
            if (_selectedRoom != null) ...[
              Text('Dispositivos en ${_selectedRoom!.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDevicesGrid(_selectedRoom!),
            ],
          ],
        );
  }

  Widget _buildStatusContainer(String status) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Text(
            'Estado del Local: $status',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
      children: [
        _buildSummaryCard(Icons.sensors, '3', 'Sensores Activos'),
        _buildSummaryCard(Icons.credit_card, '12', 'Tarjetas Registradas'),
        _buildSummaryCard(Icons.update, 'Hoy 10:30 AM', 'Última Actividad'),
      ],
    );
  }

  Widget _buildSummaryCard(IconData icon, String value, String label) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 3),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          final isSelected = _selectedRoom?.id == room.id;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRoom = room;
              });
            },
            child: Card(
              elevation: isSelected ? 4 : 1,
              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected ? BorderSide(color: Theme.of(context).primaryColor, width: 2) : BorderSide.none,
              ),
              child: Container(
                width: 120,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(room.status, style: TextStyle(color: room.status == 'Normal' ? Colors.green : Colors.red)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDevicesGrid(Room room) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 2,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: room.devices.length,
      itemBuilder: (context, index) {
        final device = room.devices[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(device.icon, size: 28),
                    Switch(
                      value: device.isOn,
                      onChanged: (value) {
                        setState(() {
                          device.isOn = value;
                        });
                      },
                    ),
                  ],
                ),
                const Spacer(),
                Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}
