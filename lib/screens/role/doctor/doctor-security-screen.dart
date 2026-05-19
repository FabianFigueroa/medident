import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSecurityScreen extends StatefulWidget {
  const DoctorSecurityScreen({super.key});

  @override
  State<DoctorSecurityScreen> createState() => _DoctorSecurityScreenState();
}

class _DoctorSecurityScreenState extends State<DoctorSecurityScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _accessLogs = [];
  List<Map<String, dynamic>> _alerts = [];
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
      if (user == null) return;

      final fs = FirebaseFirestore.instance;
      final results = await Future.wait([
        fs
            .collection('rfid_logs')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get(),
        fs
            .collection('alerts')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get(),
      ]);

      setState(() {
        _accessLogs =
            results[0].docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _alerts =
            results[1].docs.map((d) => {'id': d.id, ...d.data()}).toList();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Seguridad'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSecurityStatus(),
        const SizedBox(height: 24),
        const Text(
          'Accesos Recientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_accessLogs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Sin registros de acceso')),
            ),
          )
        else
          ..._accessLogs.take(5).map((log) => _accessLogCard(log)).toList(),
        const SizedBox(height: 24),
        const Text(
          'Alertas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_alerts.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Sin alertas')),
            ),
          )
        else
          ..._alerts.take(5).map((alert) => _alertCard(alert)).toList(),
      ],
    );
  }

  Widget _buildSecurityStatus() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedShield02,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sistema Activo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Todos los dispositivos operativos',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _accessLogCard(Map<String, dynamic> log) {
    final granted = log['granted'] ?? true;
    final timestamp = (log['timestamp'] as Timestamp?)?.toDate();

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          granted ? Icons.check_circle : Icons.cancel,
          color: granted ? Colors.green : Colors.red,
        ),
        title: Text(log['cardId'] ?? 'Tarjeta'),
        subtitle: Text(
          timestamp != null
              ? '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
              : 'Sin fecha',
        ),
        trailing: log['photoUrl'] != null
            ? const Icon(Icons.camera_alt, color: Colors.blue)
            : null,
      ),
    );
  }

  Widget _alertCard(Map<String, dynamic> alert) {
    final severity = alert['severity'] ?? 'low';
    IconData icon;
    Color color;

    switch (severity) {
      case 'high':
        icon = Icons.error;
        color = Colors.red;
        break;
      case 'medium':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info;
        color = Colors.blue;
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(alert['title'] ?? 'Alerta'),
        subtitle: Text(alert['message'] ?? ''),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedAlert01,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(_error ?? 'Error desconocido'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
