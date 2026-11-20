import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medident/core/models/clinic-model.dart';
import 'package:medident/core/models/post-model.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/services/global-search-service.dart';
import 'package:medident/screens/shared/clinic-public-screen.dart';
import 'package:medident/screens/shared/public-profile-screen.dart';
import 'package:medident/screens/role/dentist/posts/post-detail-screen.dart';
import 'package:medident/screens/widgets/follows/clinic-follow-button.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen>
    with SingleTickerProviderStateMixin {
  static const _accent = Color(0xFF4F46E5);
  static const _bg = Color(0xFFF8FAFC);
  static const _text = Color(0xFF0F172A);

  final GlobalSearchService _service = GlobalSearchService();
  final TextEditingController _searchCtrl = TextEditingController();
  late final TabController _tabController;

  late final Stream<List<UserModel>> _usersStream;
  late final Stream<List<ClinicModel>> _clinicsStream;
  late final Stream<List<PostModel>> _postsStream;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _usersStream = _service.streamUsers();
    _clinicsStream = _service.streamClinics();
    _postsStream = _service.streamPosts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  bool _userMatches(UserModel u) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return u.fullName.toLowerCase().contains(q) ||
        (u.userName ?? '').toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q) ||
        (u.clinicName ?? '').toLowerCase().contains(q);
  }

  bool _clinicMatches(ClinicModel c) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return c.name.toLowerCase().contains(q) ||
        (c.address ?? '').toLowerCase().contains(q) ||
        (c.description ?? '').toLowerCase().contains(q);
  }

  bool _postMatches(PostModel p) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return p.title.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q) ||
        p.sourceName.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: _text,
        titleSpacing: 0,
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _query = v.trim()),
          decoration: InputDecoration(
            hintText: 'Buscar usuarios, clínicas o publicaciones...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: const Icon(Icons.search, size: 20, color: _accent),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: _accent,
          labelColor: _accent,
          unselectedLabelColor: Colors.grey[500],
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Todo'),
            Tab(text: 'Usuarios'),
            Tab(text: 'Clínicas'),
            Tab(text: 'Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTab(),
          _buildUsersTab(),
          _buildClinicsTab(),
          _buildPostsTab(),
        ],
      ),
    );
  }

  Widget _buildAllTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionWithUsers(limit: 5),
          const SizedBox(height: 8),
          _sectionWithClinics(limit: 5),
          const SizedBox(height: 8),
          _sectionWithPosts(limit: 5),
        ],
      ),
    );
  }

  // ── Secciones para la pestaña "Todo" ──────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: _accent),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _text)),
        ],
      ),
    );
  }

  Widget _sectionWithUsers({required int limit}) {
    final currentUserId = context.read<AuthenticateProvider>().user?.uid ?? '';
    return StreamBuilder<List<UserModel>>(
      stream: _usersStream,
      builder: (context, snap) {
        final list = (snap.data ?? []).where(_userMatches).take(limit).toList();
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Usuarios', Icons.person_search),
            ...list.map((u) => _UserTile(
                  user: u,
                  currentUserId: currentUserId,
                )),
          ],
        );
      },
    );
  }

  Widget _sectionWithClinics({required int limit}) {
    final user = context.read<AuthenticateProvider>().user;
    final currentUserId = user?.uid ?? '';
    final myClinicId = user?.clinicId;
    return StreamBuilder<List<ClinicModel>>(
      stream: _clinicsStream,
      builder: (context, snap) {
        final list = (snap.data ?? []).where(_clinicMatches).take(limit).toList();
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Clínicas', Icons.local_hospital_outlined),
            ...list.map((c) => _ClinicTile(
                  clinic: c,
                  currentUserId: currentUserId,
                  isMember: myClinicId == c.id,
                )),
          ],
        );
      },
    );
  }

  Widget _sectionWithPosts({required int limit}) {
    final currentUserId = context.read<AuthenticateProvider>().user?.uid ?? '';
    return StreamBuilder<List<PostModel>>(
      stream: _postsStream,
      builder: (context, snap) {
        final list = (snap.data ?? []).where(_postMatches).take(limit).toList();
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Publicaciones', Icons.article_outlined),
            ...list.map((p) => _PostTile(post: p, currentUserId: currentUserId)),
          ],
        );
      },
    );
  }

  // ── Pestañas individuales ─────────────────────────────────────
  Widget _buildUsersTab() {
    final currentUserId = context.read<AuthenticateProvider>().user?.uid ?? '';
    return StreamBuilder<List<UserModel>>(
      stream: _usersStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = (snap.data ?? []).where(_userMatches).toList();
        return _resultList(
          list,
          emptyText: _query.isEmpty
              ? 'Aún no hay usuarios'
              : 'Sin usuarios para "$_query"',
          itemBuilder: (i) => _UserTile(user: list[i], currentUserId: currentUserId),
        );
      },
    );
  }

  Widget _buildClinicsTab() {
    final user = context.read<AuthenticateProvider>().user;
    final currentUserId = user?.uid ?? '';
    final myClinicId = user?.clinicId;
    return StreamBuilder<List<ClinicModel>>(
      stream: _clinicsStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = (snap.data ?? []).where(_clinicMatches).toList();
        return _resultList(
          list,
          emptyText: _query.isEmpty
              ? 'Aún no hay clínicas'
              : 'Sin clínicas para "$_query"',
          itemBuilder: (i) => _ClinicTile(
            clinic: list[i],
            currentUserId: currentUserId,
            isMember: myClinicId == list[i].id,
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    final currentUserId = context.read<AuthenticateProvider>().user?.uid ?? '';
    return StreamBuilder<List<PostModel>>(
      stream: _postsStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = (snap.data ?? []).where(_postMatches).toList();
        return _resultList(
          list,
          emptyText: _query.isEmpty
              ? 'Aún no hay publicaciones'
              : 'Sin publicaciones para "$_query"',
          itemBuilder: (i) => _PostTile(post: list[i], currentUserId: currentUserId),
        );
      },
    );
  }

  Widget _resultList<T>(
    List<T> list, {
    required String emptyText,
    required Widget Function(int) itemBuilder,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(emptyText, style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) => itemBuilder(i),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final String currentUserId;
  const _UserTile({required this.user, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final photo = user.imageUrl ?? '';
    return _Card(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PublicProfileScreen(
            userId: user.uid,
            currentUserId: currentUserId,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
            backgroundImage:
                photo.isNotEmpty ? CachedNetworkImageProvider(photo) : null,
            child: photo.isEmpty
                ? Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.isNotEmpty ? user.fullName : 'Usuario',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF0F172A)),
                ),
                Text(
                  user.clinicName?.isNotEmpty == true
                      ? user.clinicName!
                      : user.role.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _ClinicTile extends StatelessWidget {
  final ClinicModel clinic;
  final String currentUserId;
  final bool isMember;
  const _ClinicTile({
    required this.clinic,
    required this.currentUserId,
    required this.isMember,
  });

  @override
  Widget build(BuildContext context) {
    final logo = clinic.logoUrl ?? '';
    return _Card(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ClinicPublicScreen(clinic: clinic)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: logo.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logo,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _fallback(),
                  )
                : _fallback(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinic.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF0F172A)),
                ),
                Text(
                  clinic.address?.isNotEmpty == true
                      ? clinic.address!
                      : '${clinic.employeeIds.length} miembros',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isMember && currentUserId.isNotEmpty)
            ClinicFollowButton(
              userId: currentUserId,
              clinicId: clinic.id,
              compact: true,
            ),
        ],
      ),
    );
  }

  Widget _fallback() => Center(
        child: Text(
          clinic.name.isNotEmpty ? clinic.name[0].toUpperCase() : 'C',
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
}

class _PostTile extends StatelessWidget {
  final PostModel post;
  final String currentUserId;
  const _PostTile({required this.post, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final image = post.media.isNotEmpty
        ? (post.media.first.thumbnailUrl ?? post.media.first.url)
        : (post.imageUrls != null && post.imageUrls!.isNotEmpty
            ? post.imageUrls!.first
            : null);
    final hasImage = image != null && image.isNotEmpty;

    return _Card(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PostDetailScreen(post: post, currentUserId: currentUserId),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(
                        Icons.article_outlined,
                        color: Colors.grey),
                  )
                : const Icon(Icons.article_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title.isNotEmpty
                      ? post.title
                      : (post.description.isNotEmpty
                          ? post.description
                          : 'Publicación'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  post.sourceName.isNotEmpty
                      ? post.sourceName
                      : (post.userName ?? 'Usuario'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Card({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: child,
          ),
        ),
      ),
    );
  }
}
