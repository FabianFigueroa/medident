import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeSecurityScreen extends StatefulWidget {
  const EmployeeSecurityScreen({super.key});

  @override
  State<EmployeeSecurityScreen> createState() => _EmployeeSecurityScreenState();
}

class _EmployeeSecurityScreenState extends State<EmployeeSecurityScreen> {
  String? _initializedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainProvider = context.read<EmployeeMainProvider>();
    final userId = mainProvider.userId;

    if (userId.isEmpty || _initializedForUserId == userId) return;

    _initializedForUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EmployeeMainProvider>().initializeSection('security');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTrace(
      tag: 'ROLE_EMPLOYEE_SECURITY',
      message: 'Entrando a la pantalla de seguridad del empleado.',
      role: 'employee',
      child: Selector<EmployeeMainProvider, bool>(
        selector: (_, p) => p.isSectionLoading('security'),
        builder: (context, isLoading, _) {
          if (isLoading) {
            return Scaffold(body: _buildShimmer());
          }

          final mainProvider = context.watch<EmployeeMainProvider>();
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
                      onPressed: () => mainProvider.initializeSection('security'),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final securityProvider = mainProvider.securityProvider;

          if (securityProvider == null) {
            return Scaffold(body: _buildShimmer());
          }

          return ChangeNotifierProvider.value(
            value: securityProvider,
            child: _SecurityContent(),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _SecurityContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeSecurityProvider>();
    final securityData = provider.securityData;
    final accessLogs = (securityData?['accessLogs'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Seguridad',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => provider.initialize(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.initialize(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusCard(),
            const SizedBox(height: 20),
            const Text(
              'Registro de Accesos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (accessLogs.isEmpty)
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.shield_outlined, color: Colors.grey, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'No hay registros de acceso',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...accessLogs.map((log) => _AccessLogCard(log: log as Map<String, dynamic>)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.shield,
                color: Color(0xFFF59E0B),
                size: 40,
              ),
            ),
            const SizedBox(width: 20),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistema de Seguridad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Monitoreo de accesos en tiempo real',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessLogCard extends StatelessWidget {
  final Map<String, dynamic> log;

  const _AccessLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final timestamp = log['timestamp'];
    final location = log['location'] ?? 'Desconocido';
    final granted = log['granted'] ?? false;

    String timeStr;
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      timeStr = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      timeStr = 'Sin fecha';
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: granted
                ? const Color(0xFF10B981).withOpacity(0.1)
                : const Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 24,
          ),
        ),
        title: Text(
          location,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          timeStr,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: granted
                ? const Color(0xFF10B981).withOpacity(0.1)
                : const Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            granted ? 'Permitido' : 'Denegado',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: granted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
        ),
      ),
    );
  }
}
