import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/alert-model.dart';
import 'package:medident/core/providers/doctor/doctor-main-provider.dart';
import 'package:medident/core/providers/doctor/doctor-security-provider.dart';
import 'package:medident/core/utils/responsive.dart';

class DoctorSecurityScreen extends StatefulWidget {
  const DoctorSecurityScreen({super.key});

  @override
  State<DoctorSecurityScreen> createState() => _DoctorSecurityScreenState();
}

class _DoctorSecurityScreenState extends State<DoctorSecurityScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<DoctorMainProvider>();
    final userId = mainProvider.userId;

    if (userId.isEmpty || _initializedForUserId == userId) return;

    _initializedForUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DoctorMainProvider>().initializeSection('security');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DoctorMainProvider, bool>(
      selector: (_, p) => p.isSectionLoading('security'),
      builder: (context, isLoading, _) {
        if (isLoading) {
          return Scaffold(
            body: _buildScreenShimmer(),
          );
        }

        final mainProvider = context.watch<DoctorMainProvider>();
        final error = mainProvider.getSectionError('security');

        if (error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error al cargar seguridad: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        mainProvider.initializeSection('security'),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final securityProvider = mainProvider.securityProvider;

        if (securityProvider == null) {
          return Scaffold(
            body: _buildScreenShimmer(),
          );
        }

        return ChangeNotifierProvider.value(
          value: securityProvider,
          child: ResponsiveUtils(
            mobile: const _DoctorSecurityBody(),
            tablet: const _DoctorSecurityBody(),
            desktop: const _DoctorSecurityBody(),
          ),
        );
      },
    );
  }

  Widget _buildScreenShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 14,
                    width: 120,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorSecurityBody extends StatefulWidget {
  const _DoctorSecurityBody();

  @override
  State<_DoctorSecurityBody> createState() => _DoctorSecurityBodyState();
}

class _DoctorSecurityBodyState extends State<_DoctorSecurityBody> {
  List<Map<String, dynamic>> _accessLogs = [];
  bool _accessLogsLoading = true;
  String? _accessLogsError;

  @override
  void initState() {
    super.initState();
    _loadAccessLogs();
  }

  Future<void> _loadAccessLogs() async {
    setState(() {
      _accessLogsLoading = true;
      _accessLogsError = null;
    });
    try {
      final fs = FirebaseFirestore.instance;
      final snap = await fs
          .collection('rfid_logs')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
      if (!mounted) return;
      setState(() {
        _accessLogs =
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _accessLogsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _accessLogsError = 'Error al cargar accesos: $e';
        _accessLogsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final secProvider = context.watch<DoctorSecurityProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Seguridad'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAccessLogs,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSecurityStatus(),
            const SizedBox(height: 24),
            const Text(
              'Accesos Recientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_accessLogsLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_accessLogsError != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(_accessLogsError!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                          onPressed: _loadAccessLogs,
                          child: const Text('Reintentar')),
                    ],
                  ),
                ),
              )
            else if (_accessLogs.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Sin registros de acceso')),
                ),
              )
            else
              ..._accessLogs
                  .take(5)
                  .map((log) => _accessLogCard(log))
                  .toList(),
            const SizedBox(height: 24),
            const Text(
              'Alertas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (secProvider.isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (secProvider.error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: ${secProvider.error}',
                      style: const TextStyle(color: Colors.red)),
                ),
              )
            else if (secProvider.alerts.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Sin alertas')),
                ),
              )
            else
              ...secProvider.alerts
                  .take(5)
                  .map((alert) => _alertCardFromModel(alert))
                  .toList(),
          ],
        ),
      ),
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

  Widget _alertCardFromModel(AlertModel alert) {
    final severity = alert.severity;
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
        title: Text(alert.title),
        subtitle: Text(alert.description),
      ),
    );
  }
}
