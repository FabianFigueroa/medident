import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medident/core/models/clinic-model.dart';
import 'package:medident/core/models/post-model.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/services/clinic-service.dart';
import 'package:medident/screens/widgets/follows/clinic-follow-button.dart';

class ClinicPublicScreen extends StatelessWidget {
  final ClinicModel clinic;
  final Color accentColor;

  const ClinicPublicScreen({
    super.key,
    required this.clinic,
    this.accentColor = const Color(0xFF4F46E5),
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthenticateProvider>().user;
    final userId = user?.uid ?? '';
    final isMember = user?.clinicId == clinic.id;
    final service = ClinicService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildHeader(context, userId, isMember)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.grid_on_rounded, size: 18, color: Color(0xFF334155)),
                  const SizedBox(width: 8),
                  const Text('Publicaciones',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A))),
                  const Spacer(),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: service.streamClinicPosts(clinic.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.photo_library_outlined,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Esta clínica aún no ha publicado nada',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  ),
                );
              }
              final posts = docs.map((d) {
                final data = Map<String, dynamic>.from(d.data());
                data['id'] = d.id;
                return PostModel.fromJson(data, d.id);
              }).toList();
              return SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _PostTile(post: posts[i], accent: accentColor),
                    childCount: posts.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        clinic.name,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userId, bool isMember) {
    final logo = clinic.logoUrl;
    final hasLogo = logo != null && logo.isNotEmpty;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: hasLogo
                    ? CachedNetworkImage(
                        imageUrl: logo,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _logoFallback(),
                      )
                    : _logoFallback(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (clinic.description != null &&
                        clinic.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        clinic.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.5, color: Colors.grey[600], height: 1.3),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (clinic.address != null && clinic.address!.isNotEmpty)
            _infoRow(Icons.location_on_outlined, clinic.address!),
          if (clinic.phone != null && clinic.phone!.isNotEmpty)
            _infoRow(Icons.phone_outlined, clinic.phone!),
          if (clinic.email != null && clinic.email!.isNotEmpty)
            _infoRow(Icons.email_outlined, clinic.email!),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.people_alt_outlined,
                  size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                '${clinic.employeeIds.length} miembro(s) del equipo',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isMember)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 16, color: accentColor),
                  const SizedBox(width: 6),
                  Text('Eres miembro de esta clínica',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accentColor)),
                ],
              ),
            )
          else if (userId.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ClinicFollowButton(
                userId: userId,
                clinicId: clinic.id,
                accentColor: accentColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _logoFallback() {
    return Center(
      child: Text(
        clinic.name.isNotEmpty ? clinic.name[0].toUpperCase() : 'C',
        style: const TextStyle(
            color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  final PostModel post;
  final Color accent;

  const _PostTile({required this.post, required this.accent});

  @override
  Widget build(BuildContext context) {
    final image = post.media.isNotEmpty
        ? post.media.first.thumbnailUrl ?? post.media.first.url
        : (post.imageUrls != null && post.imageUrls!.isNotEmpty
            ? post.imageUrls!.first
            : null);
    final hasImage = image != null && image.isNotEmpty;

    return Container(
      clipBehavior: Clip.antiAlias,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[100]),
                    errorWidget: (_, __, ___) => _textFallback(),
                  )
                : _textFallback(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.description.isNotEmpty)
                  Text(
                    post.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF334155),
                        height: 1.25),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.favorite,
                        size: 12, color: Colors.redAccent.withOpacity(0.8)),
                    const SizedBox(width: 3),
                    Text('${post.likesCount}',
                        style: TextStyle(
                            fontSize: 10.5, color: Colors.grey[500])),
                    const Spacer(),
                    Text(post.timeAgo,
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey[400])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textFallback() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.15), accent.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.local_hospital, color: accent.withOpacity(0.5), size: 28),
      ),
    );
  }
}
