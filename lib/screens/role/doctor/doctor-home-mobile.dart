import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/main_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorHomeMobile extends StatefulWidget {
  const DoctorHomeMobile({super.key});

  @override
  State<DoctorHomeMobile> createState() => _DoctorHomeMobileState();
}

class _DoctorHomeMobileState extends State<DoctorHomeMobile> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _patients = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = context.read<AuthenticateProvider>().user;
      if (user == null) {
        setState(() {
          _error = 'No se encontró sesión activa';
          _isLoading = false;
        });
        return;
      }

      final fs = FirebaseFirestore.instance;

      final results = await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
        fs.collection('appointments')
            .where('dentistId', isEqualTo: user.uid)
            .where('status', whereIn: ['pending', 'confirmed'])
            .orderBy('date')
            .limit(5)
            .get(),
        fs.collection('users')
            .where('role', isEqualTo: 'patient')
            .limit(10)
            .get(),
      ]);

      setState(() {
        _appointments = results[0].docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList();
        _patients = results[1].docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthenticateProvider>().user;
    final doctorName = user?.fullName ?? 'Doctor';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(doctorName),
            _buildQuickActions(),
            _buildTodayStats(),
            if (_isLoading) ...[
              _buildShimmerSection(),
              _buildShimmerSection(),
            ] else if (_error != null)
              _buildErrorSection()
            else ...[
              _buildAppointmentsSection(),
              _buildRecentPatients(),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String doctorName) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bienvenido,', style: TextStyle(color: Colors.white70, fontSize: 16)),
                Text('Dr(a). $doctorName', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.notifications, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _quickActionCard(
              iconWidget: const Icon(Icons.calendar_today, color: Color(0xFF1565C0), size: 24),
              label: 'Agenda',
              color: const Color(0xFF1565C0),
              onTap: () {},
            ),
            _quickActionCard(
              iconWidget: const Icon(Icons.people, color: Color(0xFF42A5F5), size: 24),
              label: 'Pacientes',
              color: const Color(0xFF42A5F5),
              onTap: () {},
            ),
            _quickActionCard(
              iconWidget: const Icon(Icons.history, color: Color(0xFF1976D2), size: 24),
              label: 'Historial',
              color: const Color(0xFF1976D2),
              onTap: () {},
            ),
            _quickActionCard(
              iconWidget: const Icon(Icons.videocam, color: Color(0xFF0D47A1), size: 24),
              label: 'Telemedicina',
              color: const Color(0xFF0D47A1),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionCard({
    required Widget iconWidget,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: iconWidget,
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _statCard(iconWidget: const Icon(Icons.people, color: Color(0xFF1565C0), size: 20),
                label: 'Pacientes Hoy', value: _appointments.length.toString(), color: const Color(0xFF1565C0)),
            const SizedBox(width: 12),
            _statCard(iconWidget: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                label: 'Completadas', value: _appointments.where((a) => a['status'] == 'completed').length.toString(), color: Colors.green),
            const SizedBox(width: 12),
            _statCard(iconWidget: const Icon(Icons.schedule, color: Colors.orange, size: 20),
                label: 'Pendientes', value: _appointments.where((a) => a['status'] == 'pending').length.toString(), color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required Widget iconWidget,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              iconWidget,
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Citas de Hoy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Ver todas')),
              ],
            ),
            const SizedBox(height: 12),
            if (_appointments.isEmpty)
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 48),
                      const SizedBox(height: 12),
                      const Text('No hay citas para hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              )
            else
              ..._appointments.map((apt) => _appointmentCard(apt)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _appointmentCard(Map<String, dynamic> apt) {
    final date = (apt['date'] as Timestamp?)?.toDate();
    final status = apt['status'] ?? 'pending';
    Color statusColor;
    switch (status) {
      case 'confirmed': statusColor = Colors.green; break;
      case 'completed': statusColor = Colors.blue; break;
      case 'cancelled': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
          child: Text((apt['patientName'] ?? 'P')[0],
              style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
        ),
        title: Text(apt['patientName'] ?? 'Paciente'),
        subtitle: Text(apt['treatmentName'] ?? 'Consulta General'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(date != null
                ? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
                : (apt['timeSlot'] ?? ''),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPatients() {
    if (_patients.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pacientes Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _patients.length,
                itemBuilder: (context, index) {
                  final p = _patients[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
                              child: Text((p['fullName'] ?? 'P')[0],
                                  style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            const SizedBox(height: 4),
                            Text(p['fullName'] ?? 'Paciente',
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
          child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
        ),
      ),
    );
  }

  Widget _buildErrorSection() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error ?? 'Error desconocido', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
