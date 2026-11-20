import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/role/dentist/home/widgets/medident_collapsing_bar.dart';
import 'package:medident/screens/widgets/shared/clinic-connect-screen.dart';
import 'package:medident/screens/widgets/shared/clinics-promotion-card.dart';
import 'package:medident/screens/widgets/shared/pending-clinic-invites-card.dart';

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
      if (!mounted) return;
      context.read<EmployeeHomeProvider>().loadInitialData();
      context.read<EmployeeMainProvider>().initializeSection('clinic');
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
    final alerts = provider.alerts;
    final globalPromotions = provider.globalPromotions;
    final main = context.read<EmployeeMainProvider>();
    final unread = context.watch<NotificationProvider>().unreadCount;
    final carouselItems = globalPromotions
        .map((promo) => MedidentCarouselItem.fromProduct(
              promo,
              promoterName: employeeName,
              promoterRole: 'Equipo Medident',
              promoterAvatar: user?.imageUrl ?? '',
              promoterUid: main.userId,
              onCtaPressed: () {},
            ))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () => context.read<EmployeeHomeProvider>().loadInitialData(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            MedidentCollapsingBar(
              collapsedTitle: 'Medident',
              expandedHeight: 420,
              isLoading: isLoading && globalPromotions.isEmpty,
              userProfile: MedidentBrandProfile(
                storeOrUserName: employeeName,
                roleOrCity: 'Equipo Medident',
                avatarUrl: user?.imageUrl ?? '',
                uid: main.userId,
              ),
              carouselItems: carouselItems,
              notificationBadgeCount: unread,
              scrollController: _scrollController,
              onNotificationPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationScreen()),
              ),
              onSearchPressed: () {},
              onScannerPressed: () {},
              onCarouselItemTapped: (_) {},
              onProfileCardTapped: (_) {},
            ),
            _buildQuickActions(),
            _buildClinicBanner(),
            const SliverToBoxAdapter(child: ClinicsPromotionCard()),
            PendingClinicInvitesCard(
              userId: main.userId,
              onAccepted: () {
                context
                    .read<EmployeeMainProvider>()
                    .clinicProvider
                    ?.checkClinicStatus(main.userId);
                context.read<EmployeeHomeProvider>().loadInitialData();
              },
            ),
            if (isLoading) ...[
              _buildShimmerSection(),
              _buildShimmerSection(),
            ] else if (error != null)
              _buildErrorSection(error)
            else ...[
              if (alerts.isNotEmpty) _buildAlertsSection(alerts),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClinicBanner() {
    final main = context.read<EmployeeMainProvider>();
    final clinicProvider = main.clinicProvider;
    if (clinicProvider == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: ListenableBuilder(
        listenable: clinicProvider,
        builder: (context, _) {
          final clinic = clinicProvider.clinic;
          final hasClinic = clinic != null;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Card(
              color: Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF6A1B9A).withOpacity(0.1),
                  child: const Icon(Icons.local_hospital,
                      color: Color(0xFF6A1B9A)),
                ),
                title: Text(
                  hasClinic ? clinic.name : 'Sin clinica vinculada',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  hasClinic
                      ? (clinicProvider.isOwner
                          ? 'Propietario (CEO)'
                          : 'Miembro del equipo')
                      : 'Crea o unite con un codigo',
                ),
                trailing: TextButton(
                  onPressed: () => _openClinic(clinicProvider),
                  child: Text(hasClinic ? 'Ver' : 'Vincular'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openClinic(DentistClinicProvider clinicProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClinicConnectScreen(
          userId: context.read<EmployeeMainProvider>().userId,
          clinicProvider: clinicProvider,
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
