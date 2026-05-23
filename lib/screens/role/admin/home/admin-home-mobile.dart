import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';
import 'package:medident/core/models/product-model.dart';
import 'package:medident/screens/widgets/carousel/promotions-carousel-widget.dart';
import 'package:medident/screens/widgets/creator/creator-hub-widget.dart';
import 'package:medident/screens/widgets/new-post/create_newposts_widget.dart';

class AdminHomeMobileWidget extends StatelessWidget {
  const AdminHomeMobileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMainProvider>().homeProvider;
    if (provider == null) return const SizedBox();

    final mainProv = context.watch<AdminMainProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => provider.refreshData(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            _Header(provider: provider),
            const SizedBox(height: 16),
            const _CreatePostSection(),
            const SizedBox(height: 16),
            _QuickStats(provider: provider),
            const SizedBox(height: 16),
            _PromotionsSection(provider: provider),
            const SizedBox(height: 16),
            _ReelsSection(provider: provider),
            const SizedBox(height: 16),
            _ModerationCard(provider: provider),
            const SizedBox(height: 16),
            _ActivityCard(provider: provider),
          ],
        ),
      ),
      floatingActionButton: CreatorHubWidget(
        userId: mainProv.userId.isNotEmpty ? mainProv.userId : 'admin',
        userName: context.select<AuthenticateProvider, String>((p) => p.user?.fullName ?? 'Admin'),
        userPhoto: context.select<AuthenticateProvider, String>((p) => p.user?.imageUrl ?? ''),
      ),
    );
  }
}

// ─── CREATE POST ─────

class _CreatePostSection extends StatelessWidget {
  const _CreatePostSection();

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthenticateProvider>();
    final user = authProv.user;
    return Create_Newposts_Widget(
      userId: user?.uid ?? '',
      userName: user?.fullName ?? 'Admin',
      userPhoto: user?.imageUrl ?? '',
      promoScope: 'global',
    );
  }
}

// ─── HEADER ─────

class _Header extends StatelessWidget {
  final AdminHomeProvider provider;
  const _Header({required this.provider});

  @override
  Widget build(BuildContext context) {
    final stats = provider.dashboardStats;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panel Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${stats['activeUsers'] ?? 0} usuarios activos',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                ),
                child: _AdminNotificationBadge(),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Activo',
                      style: TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── QUICK STATS ─────

class _QuickStats extends StatelessWidget {
  final AdminHomeProvider provider;
  const _QuickStats({required this.provider});

  @override
  Widget build(BuildContext context) {
    final stats = provider.dashboardStats;
    return Row(
      children: [
        Expanded(child: _StatCard(
          icon: Icons.people_rounded,
          value: '${stats['activeUsers'] ?? 0}',
          label: 'Usuarios',
          color: const Color(0xFF6EC6E8),
          lightColor: const Color(0xFFF0F9FF),
        )),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(
          icon: Icons.article_rounded,
          value: '${stats['totalPosts'] ?? 0}',
          label: 'Posts',
          color: const Color(0xFFA78BFA),
          lightColor: const Color(0xFFF3EEFF),
        )),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(
          icon: Icons.flag_rounded,
          value: '${stats['openReports'] ?? 0}',
          label: 'Reportes',
          color: const Color(0xFFFB7185),
          lightColor: const Color(0xFFFFF1F2),
        )),
        Expanded(child: _StatCard(
          icon: Icons.person_add_rounded,
          value: '${stats['newUsersThisWeek'] ?? 0}',
          label: 'Nuevos',
          color: const Color(0xFF34D399),
          lightColor: const Color(0xFFECFDF5),
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color lightColor;

  const _StatCard({
    required this.icon, required this.value, required this.label,
    required this.color, required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ─── PROMOTIONS SECTION ─────

class _PromotionsSection extends StatelessWidget {
  final AdminHomeProvider provider;
  const _PromotionsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.card_giftcard_rounded, size: 18, color: Color(0xFFFBBF24)),
            const SizedBox(width: 6),
            const Text(
              'Promociones globales',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showAddPromoDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: Color(0xFFFBBF24)),
                    SizedBox(width: 3),
                    Text('Agregar', style: TextStyle(fontSize: 12, color: Color(0xFFFBBF24), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.globalPromotions.isNotEmpty)
          Promotions_Carousel_Widget(
            products: provider.globalPromotions.take(5).toList(),
            onProductTap: (product) {},
            onDelete: (product) => _deletePromo(context, product.id),
          )
        else
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9E7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.2)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.card_giftcard_outlined, size: 40, color: const Color(0xFFFBBF24).withOpacity(0.4)),
                  const SizedBox(height: 8),
                  Text('Sin promociones globales',
                      style: TextStyle(color: const Color(0xFFFBBF24).withOpacity(0.6), fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Toca + para crear una',
                      style: TextStyle(color: const Color(0xFFFBBF24).withOpacity(0.4), fontSize: 12)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _deletePromo(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar promoción'),
        content: const Text('¿Estás seguro de eliminar esta promoción?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deletePromotion(id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFFB7185))),
          ),
        ],
      ),
    );
  }

  void _showAddPromoDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Nueva promoción global',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl,
                decoration: _input('Título', Icons.card_giftcard, const Color(0xFFFBBF24))),
            const SizedBox(height: 10),
            TextField(controller: descCtrl, maxLines: 3,
                decoration: _input('Descripción', Icons.description, const Color(0xFFFBBF24))),
            const SizedBox(height: 10),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number,
                decoration: _input('Precio', Icons.attach_money, const Color(0xFFFBBF24))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await provider.createPromotion({
                    'userId': provider.userId,
                    'name': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'price': double.tryParse(priceCtrl.text.trim()) ?? 0,
                    'scope': 'global',
                    'isActive': true,
                    'isFeatured': false,
                    'imageUrls': [],
                  });
                  Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Promoción global creada'),
                        backgroundColor: const Color(0xFFFBBF24),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBBF24),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Crear promoción', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _input(String hint, IconData icon, Color color) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: Icon(icon, size: 18, color: color.withOpacity(0.6)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true, fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

// ─── REELS SECTION ─────

class _ReelsSection extends StatelessWidget {
  final AdminHomeProvider provider;
  const _ReelsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.videocam_rounded, size: 18, color: Color(0xFFFB7185)),
            const SizedBox(width: 6),
            const Text(
              'Reels / Videos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showAddReelDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFB7185).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: Color(0xFFFB7185)),
                    SizedBox(width: 3),
                    Text('Agregar', style: TextStyle(fontSize: 12, color: Color(0xFFFB7185), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.reels.isNotEmpty)
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.reels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final reel = provider.reels[i];
                return _ReelCard(
                  reel: reel,
                  onDelete: () => _deleteReel(context, reel['id'] as String),
                );
              },
            ),
          )
        else
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFB7185).withOpacity(0.2)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_outlined, size: 36, color: const Color(0xFFFB7185).withOpacity(0.4)),
                  const SizedBox(height: 6),
                  Text('Sin reels todavía',
                      style: TextStyle(color: const Color(0xFFFB7185).withOpacity(0.6), fontSize: 13)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _deleteReel(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar reel'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteReel(id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFFB7185))),
          ),
        ],
      ),
    );
  }

  void _showAddReelDialog(BuildContext context) {
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Nuevo reel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            TextField(controller: descCtrl, maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Descripción',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(Icons.description, size: 18, color: Color(0xFFFB7185)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true, fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                )),
            const SizedBox(height: 10),
            TextField(controller: urlCtrl,
                decoration: InputDecoration(
                  hintText: 'URL del video',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(Icons.link, size: 18, color: Color(0xFFFB7185)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true, fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await provider.createReel({
                    'userId': provider.userId,
                    'description': descCtrl.text.trim(),
                    'videoUrl': urlCtrl.text.trim(),
                  });
                  Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Reel creado'),
                        backgroundColor: const Color(0xFFFB7185),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB7185),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Crear reel', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminNotificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          const Icon(Icons.notifications, color: Colors.white, size: 22),
          if (unreadCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
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

class _ReelCard extends StatelessWidget {
  final Map<String, dynamic> reel;
  final VoidCallback onDelete;

  const _ReelCard({required this.reel, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: reel['thumbnailUrl'] != null
                    ? DecorationImage(image: NetworkImage(reel['thumbnailUrl']), fit: BoxFit.cover)
                    : null,
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB7185).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Color(0xFFFB7185), size: 28),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    reel['description'] ?? 'Sin descripción',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.close, size: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MODERATION ─────

class _ModerationCard extends StatelessWidget {
  final AdminHomeProvider provider;
  const _ModerationCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, size: 18, color: Color(0xFFA78BFA)),
              const SizedBox(width: 6),
              const Text('Cola de moderación',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              if (provider.moderationQueue.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA78BFA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${provider.moderationQueue.length}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFA78BFA), fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (provider.moderationQueue.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Sin elementos pendientes',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            )
          else
            ...provider.moderationQueue.take(4).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(color: Color(0xFFA78BFA), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item['id']?.toString().substring(0, 8) ?? 'Item',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                  ),
                  Text(item['status']?.toString() ?? '',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

// ─── ACTIVITY ─────

class _ActivityCard extends StatelessWidget {
  final AdminHomeProvider provider;
  const _ActivityCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 18, color: Color(0xFF6EC6E8)),
              const SizedBox(width: 6),
              const Text('Actividad reciente',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.activityFeed.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Sin actividad reciente',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            )
          else
            ...provider.activityFeed.take(5).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF6EC6E8), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['action'] ?? item['id']?.toString().substring(0, 12) ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
