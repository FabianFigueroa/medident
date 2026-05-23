import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';
import 'package:medident/screens/widgets/new-post/create_newposts_widget.dart';

class AdminHomeTabletWidget extends StatelessWidget {
  const AdminHomeTabletWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().homeProvider;
    if (provider == null) return const SizedBox();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: RefreshIndicator(
        onRefresh: () => provider.refreshData(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader(provider),
            const SizedBox(height: 16),
            _buildCreatePost(context),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildLeftColumn(provider)),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: _buildRightColumn(provider)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdminHomeProvider p) {
    final stats = p.dashboardStats;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Panel de Control Admin', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${stats['activeUsers'] ?? 0} usuarios activos en la plataforma', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
            child: const Text('Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePost(BuildContext context) {
    final user = context.watch<AuthenticateProvider>().user;
    return Create_Newposts_Widget(
      userId: user?.uid ?? '',
      userName: user?.fullName ?? 'Admin',
      userPhoto: user?.imageUrl ?? '',
      promoScope: 'global',
    );
  }

  Widget _buildLeftColumn(AdminHomeProvider p) {
    final stats = p.dashboardStats;
    return Column(
      children: [
        Row(children: [
          Expanded(child: _statCard('Usuarios activos', '${stats['activeUsers'] ?? 0}', Icons.people, const Color(0xFF3A7AFE))),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Posts totales', '${stats['totalPosts'] ?? 0}', Icons.article, const Color(0xFF111827))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statCard('Reportes abiertos', '${stats['openReports'] ?? 0}', Icons.flag, const Color(0xFFFF7A59))),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Nuevos esta semana', '${stats['newUsersThisWeek'] ?? 0}', Icons.person_add, const Color(0xFF0EA5A4))),
        ]),
        const SizedBox(height: 16),
        _buildSectionCard('Actividad reciente', p.activityFeed.take(5).map((item) => ListTile(
          dense: true,
          leading: const Icon(Icons.circle, size: 8, color: Color(0xFF3A7AFE)),
          title: Text(item['action'] ?? item['id'] ?? '', style: const TextStyle(fontSize: 13)),
          subtitle: Text(item['timestamp']?.toString() ?? ''),
        )).toList()),
      ],
    );
  }

  Widget _buildRightColumn(AdminHomeProvider p) {
    return Column(
      children: [
        _buildSectionCard('Moderacion pendiente', p.moderationQueue.take(5).map((item) => ListTile(
          dense: true,
          title: Text(item['id'] ?? 'Item', style: const TextStyle(fontSize: 14)),
          subtitle: Text(item['status'] ?? ''),
        )).toList()),
        const SizedBox(height: 16),
        _buildSectionCard('Aprobaciones pendientes', p.pendingApprovals.take(5).map((item) => ListTile(
          dense: true,
          title: Text(item['id'] ?? 'Item', style: const TextStyle(fontSize: 14)),
          subtitle: Text(item['status'] ?? ''),
        )).toList()),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 14),
        Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      ]),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (children.isEmpty) const Text('Sin datos', style: TextStyle(color: Colors.grey)) else ...children,
      ]),
    );
  }
}
