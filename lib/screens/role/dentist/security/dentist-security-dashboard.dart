import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';
import 'widgets/rfid/rfid-readers-config.dart';
import 'widgets/rfid/rfid-logs-list.dart';
import 'widgets/alerts/alerts-list.dart';
import 'widgets/alerts/alert-detail.dart';
import 'widgets/emergency/panic-button-widget.dart';
import 'widgets/emergency/emergency-contacts-widget.dart';
import 'widgets/emergency/duress-code-config.dart';
import 'widgets/camera/camera-live-view.dart';

/// Dashboard principal de seguridad para dentist
class DentistSecurityDashboard extends StatefulWidget {
  const DentistSecurityDashboard({super.key});

  @override
  State<DentistSecurityDashboard> createState() => _DentistSecurityDashboardState();
}

class _DentistSecurityDashboardState extends State<DentistSecurityDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _OverviewTab(),
    _RfidTab(),
    _AlertsTab(),
    _EmergencyTab(),
    _CamerasTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                // Marcar todas como leídas
              },
              child: const Icon(Icons.done_all),
            )
          : _selectedIndex == 3
              ? PanicButtonWidget()
              : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Resumen',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.contactless),
            label: 'RFID',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Consumer<DentistSecurityProvider>(
                    builder: (context, provider, _) {
                      final count = provider.unreadAlertsCount;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            label: 'Alertas',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.emergency),
            label: 'Emergencia',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Cámaras',
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.85),
                  const Color(0xFF1a73e8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Seguridad',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Ubuntu-Bold',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedShield01,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Consumer<DentistSecurityProvider>(
                  builder: (context, provider, _) {
                    final data = provider.securityData;
                    return Row(
                      children: [
                        _buildStatCard(
                          icon: HugeIcons.strokeRoundedCreditCard,
                          value: '${data?.rfidCards.length ?? 0}',
                          label: 'Tarjetas',
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          icon: HugeIcons.strokeRoundedWifi01,
                          value: '${data?.sensors.length ?? 0}',
                          label: 'Sensores',
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          icon: HugeIcons.strokeRoundedActivity01,
                          value: '${provider.unreadAlertsCount}',
                          label: 'Alertas',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Accesos Recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<DentistSecurityProvider>(
                  builder: (context, provider, _) {
                    final logs = provider.rfidLogs.take(5).toList();
                    return RfidLogsListWidget(logs: logs);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Últimas Alertas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<DentistSecurityProvider>(
                  builder: (context, provider, _) {
                    final alerts = provider.alerts.take(5).toList();
                    return AlertsListWidget(
                      alerts: alerts,
                      onTap: (alert) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlertDetailWidget(
                              alert: alert,
                              onMarkRead: () =>
                                  provider.markAlertAsRead(alert.id),
                              onMarkHandled: () => provider.markAlertAsHandled(
                                  alert.id,
                                  provider.securityData?.dentistName ?? 'Dentist',
                              ),
                            ),
                          ),
                        );
                      },
                      onMarkRead: (alert) => provider.markAlertAsRead(alert.id),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required List<List<dynamic>> icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HugeIcon(icon: icon, color: AppColors.primary, size: 18),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.grey600,
                fontFamily: 'Ubuntu-Regular',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RfidTab extends StatelessWidget {
  const _RfidTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lectores RFID',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 12),
                const RfidReadersConfigWidget(),
                const SizedBox(height: 20),
                const Text(
                  'Historial de Lecturas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<DentistSecurityProvider>(
              builder: (context, provider, _) {
                return RfidLogsListWidget(
                  logs: provider.rfidLogs,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertsTab extends StatelessWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Todas las Alertas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Filtrar
                  },
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filtrar'),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<DentistSecurityProvider>(
              builder: (context, provider, _) {
                return AlertsListWidget(
                  alerts: provider.alerts,
                  onTap: (alert) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlertDetailWidget(
                          alert: alert,
                          onMarkRead: () =>
                              provider.markAlertAsRead(alert.id),
                          onMarkHandled: () => provider.markAlertAsHandled(
                              alert.id,
                              provider.securityData?.dentistName ?? 'Dentist',
                          ),
                        ),
                      ),
                    );
                  },
                  onMarkRead: (alert) => provider.markAlertAsRead(alert.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _EmergencyTab extends StatelessWidget {
  const _EmergencyTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuración de Emergencia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 16),
                const DuressCodeConfigWidget(),
                const SizedBox(height: 20),
                const EmergencyContactsWidget(),
                const SizedBox(height: 20),
                const Text(
                  'Botón de Pánico',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: PanicButtonWidget(
                    onPanic: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alerta de pánico activada'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CamerasTab extends StatelessWidget {
  const _CamerasTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cámaras en Vivo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<DentistSecurityProvider>(
                  builder: (context, provider, _) {
                    final cameras = provider.securityData?.readers ?? [];
                    if (cameras.isEmpty) {
                      return const Center(  
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No hay cámaras configuradas'),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cameras.length,
                      itemBuilder: (context, index) {
                        final cam = cameras[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CameraLiveViewWidget(
                            cameraId: cam.id,
                            streamUrl: cam.isActive
                                ? 'http://${cam.ipAddress}/cam-lo.jpg'
                                : null,
                            isActive: cam.isActive,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
