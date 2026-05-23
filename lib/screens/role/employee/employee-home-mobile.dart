import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/main_export.dart';

class EmployeeHomeMobile extends StatefulWidget {
  const EmployeeHomeMobile({super.key});

  @override
  State<EmployeeHomeMobile> createState() => _EmployeeHomeMobileState();
}

class _EmployeeHomeMobileState extends State<EmployeeHomeMobile> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeHomeProvider>().loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthenticateProvider>().user;
    final provider = context.watch<EmployeeHomeProvider>();
    final employeeName = user?.fullName ?? 'Empleado';
    final isLoading = provider.isLoading;
    final error = provider.error;
    final turnos = provider.turnos;
    final alerts = provider.alerts;
    final globalPromotions = provider.globalPromotions;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () => context.read<EmployeeHomeProvider>().loadInitialData(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(employeeName),
            _buildQuickActions(),
            _buildGlobalPromotions(globalPromotions),
            if (isLoading) ...[
              _buildShimmerSection(),
              _buildShimmerSection(),
            ] else if (error != null)
              _buildErrorSection(error)
            else ...[
              _buildTurnosSection(turnos),
              if (alerts.isNotEmpty) _buildAlertsSection(alerts),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String name) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hola,', style: TextStyle(color: Colors.white70, fontSize: 16)),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
              child: _NotificationBadge(),
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
              iconWidget: HugeIcon(icon: HugeIcons.strokeRoundedCalendar01, color: const Color(0xFF6A1B9A), size: 24),
              label: 'Mis Turnos',
              color: const Color(0xFF6A1B9A),
              onTap: () {},
            ),
            _quickActionCard(
              iconWidget: const Icon(Icons.shield, color: Color(0xFFAB47BC), size: 24),
              label: 'Seguridad',
              color: const Color(0xFFAB47BC),
              onTap: () {},
            ),
            _quickActionCard(
              iconWidget: const Icon(Icons.shopping_bag, color: Color(0xFF8E24AA), size: 24),
              label: 'Tienda',
              color: const Color(0xFF8E24AA),
              onTap: () {},
            ),
            _quickActionCard(
              iconWidget: const Icon(Icons.person, color: Color(0xFF4A148C), size: 24),
              label: 'Perfil',
              color: const Color(0xFF4A148C),
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

  Widget _buildGlobalPromotions(List<ProductModel> promos) {
    if (promos.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: promos.length,
            itemBuilder: (context, index) {
              final promo = promos[index];
              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(promo.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (promo.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(promo.description,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTurnosSection(List<Map<String, dynamic>> turnos) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mis Turnos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Ver todos')),
              ],
            ),
            const SizedBox(height: 12),
            if (turnos.isEmpty)
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.schedule, color: Colors.grey, size: 48),
                      const SizedBox(height: 12),
                      const Text('No tienes turnos asignados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              )
            else
              ...turnos.map((turno) => _turnoCard(turno)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _turnoCard(Map<String, dynamic> turno) {
    final date = (turno['date'] as Timestamp?)?.toDate();
    final status = turno['status'] ?? 'scheduled';
    Color statusColor;
    switch (status) {
      case 'in_progress': statusColor = Colors.orange; break;
      case 'completed': statusColor = Colors.green; break;
      case 'cancelled': statusColor = Colors.red; break;
      default: statusColor = Colors.blue;
    }
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.schedule, color: statusColor, size: 24),
        ),
        title: Text(date != null ? '${date.day}/${date.month}/${date.year}' : 'Sin fecha',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${turno['startTime'] ?? ''} - ${turno['endTime'] ?? ''}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildAlertsSection(List<Map<String, dynamic>> alerts) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Ver todas')),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map((alert) => _alertCard(alert)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _alertCard(Map<String, dynamic> alert) {
    final severity = alert['severity'] ?? 'low';
    IconData icon;
    Color color;
    switch (severity) {
      case 'high': icon = Icons.error; color = Colors.red; break;
      case 'medium': icon = Icons.warning; color = Colors.orange; break;
      default: icon = Icons.info; color = Colors.blue;
    }
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(alert['title'] ?? 'Notificación'),
        subtitle: Text(alert['message'] ?? ''),
        trailing: const Icon(Icons.chevron_right),
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

  Widget _buildErrorSection(String error) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<EmployeeHomeProvider>().loadInitialData(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          const Icon(Icons.notifications, color: Colors.white, size: 24),
          if (unreadCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
