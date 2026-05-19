import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class HomeMobile extends StatefulWidget {
  const HomeMobile({super.key});

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  final List<Map<String, dynamic>> _stats = [
    {'title': 'Pacientes hoy', 'value': '8', 'icon': Icons.today, 'color': Color(0xFF008080)},
    {'title': 'Próximas citas', 'value': '12', 'icon': Icons.calendar_today, 'color': Color(0xFF20B2AA)},
    {'title': 'Facturación mes', 'value': '\$4,250', 'icon': Icons.attach_money, 'color': Color(0xFF5F9EA0)},
    {'title': 'Pendientes', 'value': '3', 'icon': Icons.warning, 'color': Color(0xFF008B8B)},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ValeriaProvider>().observe('dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRole = AppLogger.roleName(
      context.watch<AuthenticateProvider>().user?.role,
    );
    return ScreenTrace(
      tag: 'HOME_SCREEN_TABLET',
      message: 'Pantalla Home tablet cargada. Mostrando metricas, citas y recordatorios.',
      role: currentRole,
      child: Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        actions: [IconButton(icon: Icon(Icons.notifications), onPressed: () {})],
      ),
      body: Container(
        color: Colors.grey[50],
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _stats.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _stats[index]['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_stats[index]['icon'], color: _stats[index]['color'], size: 20),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_stats[index]['value'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(_stats[index]['title'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Próximas citas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text('Ver todas')),
              ],
            ),
            SizedBox(height: 12),
            _buildAppointmentCard('María González', '10:30 AM', 'Limpieza dental'),
            _buildAppointmentCard('Carlos Ruiz', '11:45 AM', 'Endodoncia'),
            _buildAppointmentCard('Ana López', '3:00 PM', 'Revisión'),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recordatorios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text('Ver todos')),
              ],
            ),
            SizedBox(height: 12),
            _buildReminderCard('Completar historial de Juan', 'Hace 2 horas', Icons.pending),
            _buildReminderCard('Confirmar cita de mañana', 'En 3 horas', Icons.schedule),
            _buildReminderCard('Pedir materiales', 'Urgente', Icons.warning),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildAppointmentCard(String name, String time, String type) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF008080).withOpacity(0.1),
          child: Text(
            name.split(' ').map((e) => e[0]).take(2).join(),
            style: TextStyle(color: Color(0xFF008080), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name),
        subtitle: Text(type),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFF008080).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(time, style: TextStyle(color: Color(0xFF008080), fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildReminderCard(String title, String time, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF008080)),
        title: Text(title),
        subtitle: Text(time),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}
