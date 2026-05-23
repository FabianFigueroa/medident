import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/main_export.dart';
import 'package:intl/intl.dart';
import 'package:medident/screens/shared/widgets/calendar_table.dart';
import 'package:medident/screens/widgets/shared/create_appointment_sheet.dart';

class PatientHomeMobile extends StatefulWidget {
  const PatientHomeMobile({super.key});

  @override
  State<PatientHomeMobile> createState() => _PatientHomeMobileState();
}

class _PatientHomeMobileState extends State<PatientHomeMobile> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthenticateProvider>().user;
    final homeProvider = context.watch<PatientHomeProvider>();
    final userName = user?.fullName ?? 'Paciente';
    final isLoading = homeProvider.isLoading;
    final error = homeProvider.error;
    final data = homeProvider.dashboardData;

    final appointments = (data['appointments'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final promotions = (data['promotions'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final treatments = (data['treatments'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final globalPromotions = homeProvider.globalPromotions;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () => homeProvider.loadInitialData(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(userName),
            _buildQuickActions(),
            _buildGlobalPromotions(globalPromotions),
            if (isLoading) ...[
              _buildShimmerSection(),
              _buildShimmerSection(),
              _buildShimmerSection(),
            ] else if (error != null)
              _buildErrorSection(error, homeProvider)
            else ...[
              _buildNextAppointment(user, appointments),
              _buildPromotionsSection(promotions),
              _buildTreatmentsSection(treatments),
              _buildHealthTips(),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String userName) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF008080), Color(0xFF20B2AA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hola,', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text(userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
              iconWidget: HugeIcon(icon: HugeIcons.strokeRoundedCalendar01, color: const Color(0xFF008080), size: 24),
              label: 'Mis Citas',
              color: const Color(0xFF008080),
              onTap: () {},
            ),
            _quickActionCard(
              iconWidget: const Icon(Icons.history, color: Color(0xFF20B2AA), size: 24),
              label: 'Historial',
              color: const Color(0xFF20B2AA),
              onTap: () {},
            ),
            _quickActionCard(
              iconWidget: const Icon(Icons.face, color: Color(0xFF5F9EA0), size: 24),
              label: 'Odontograma',
              color: const Color(0xFF5F9EA0),
              onTap: () {},
            ),
            _quickActionCard(
              iconWidget: const Icon(Icons.shopping_bag, color: Color(0xFF008B8B), size: 24),
              label: 'Tienda',
              color: const Color(0xFF008B8B),
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
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: iconWidget,
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildNextAppointment(user, List<Map<String, dynamic>> appointments) {
    final appts = appointments
        .map((m) => AppointmentModel.fromJson(Map<String, dynamic>.from(m), m['id'] as String? ?? ''))
        .toList();
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    final todayAppts = appts.where((a) => DateFormat('yyyy-MM-dd').format(a.date) == todayStr).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, size: 20, color: const Color(0xFF008080)),
                const SizedBox(width: 8),
                Text('Mis Citas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            CalendarTable(
              date: today,
              appointments: todayAppts,
              onTap: (a) => _showApptDetail(context, a),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateAppointment_Widget(
                        initialPatientId: user?.uid,
                        initialPatientName: user?.fullName,
                        clinicId: user?.clinicId,
                        isPatientMode: true,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Solicitar Cita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008080),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApptDetail(BuildContext context, AppointmentModel a) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(a.patientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _detailRow(Icons.access_time, '${a.timeSlot} — ${a.treatmentName}'),
            _detailRow(Icons.person, a.dentistName.isNotEmpty ? a.dentistName : 'Sin especialista'),
            _detailRow(Icons.info_outline, 'Estado: ${a.status}'),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
      ]),
    );
  }

  Widget _buildPromotionsSection(List<Map<String, dynamic>> promotions) {
    if (promotions.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Promociones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                  final promo = promotions[index];
                  return Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF008080), Color(0xFF20B2AA)]),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(promo['name'] ?? 'Promoción',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (promo['discountPrice'] != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('\$${promo['price'] ?? 0}',
                                  style: const TextStyle(color: Colors.white70, decoration: TextDecoration.lineThrough, fontSize: 14)),
                              const SizedBox(width: 8),
                              Text('\$${promo['discountPrice']}',
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ],
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

  Widget _buildTreatmentsSection(List<Map<String, dynamic>> treatments) {
    if (treatments.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tratamientos Disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.3, crossAxisSpacing: 12, mainAxisSpacing: 12,
              ),
              itemCount: treatments.length > 4 ? 4 : treatments.length,
              itemBuilder: (context, index) {
                final t = treatments[index];
                return Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF008080).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.face, color: Color(0xFF008080), size: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(t['name'] ?? 'Tratamiento',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('\$${t['price'] ?? 0}',
                            style: const TextStyle(color: Color(0xFF008080), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTips() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.info, color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('Consejos de Salud Dental',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                _tipItem('Cepilla tus dientes al menos 3 veces al día'),
                _tipItem('Usa hilo dental diariamente'),
                _tipItem('Visita al dentista cada 6 meses'),
                _tipItem('Evita alimentos azucarados'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF008080)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
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
                    colors: [Color(0xFF008080), Color(0xFF20B2AA)],
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

  Widget _buildShimmerSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
        ),
      ),
    );
  }

  Widget _buildErrorSection(String error, PatientHomeProvider provider) {
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
            ElevatedButton(onPressed: () => provider.loadInitialData(), child: const Text('Reintentar')),
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
