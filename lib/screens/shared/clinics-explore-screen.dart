import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medident/core/models/clinic-model.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/services/clinic-follow-service.dart';
import 'package:medident/screens/shared/clinic-public-screen.dart';
import 'package:medident/screens/widgets/follows/clinic-follow-button.dart';

class ClinicsExploreScreen extends StatelessWidget {
  const ClinicsExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthenticateProvider>().user;
    final userId = user?.uid ?? '';
    final service = ClinicFollowService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        title: const Text('Explorar clínicas',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: StreamBuilder<List<String>>(
        stream: service.streamFollowedClinicIds(userId),
        builder: (context, followSnap) {
          final followedIds = followSnap.data ?? const <String>[];
          return StreamBuilder<List<ClinicModel>>(
            stream: service.streamAllClinics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final clinics = snapshot.data ?? [];
              if (clinics.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_hospital_outlined,
                          size: 56, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('No hay clínicas registradas todavía',
                          style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                );
              }

              final following = clinics
                  .where((c) => followedIds.contains(c.id))
                  .toList();
              final others =
                  clinics.where((c) => !followedIds.contains(c.id)).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (following.isNotEmpty) ...[
                    const _SectionTitle(
                        icon: Icons.check_circle, text: 'Clínicas que sigues'),
                    const SizedBox(height: 10),
                    ...following.map((c) => _ClinicCard(
                          clinic: c,
                          userId: userId,
                          isFollowing: true,
                        )),
                    const SizedBox(height: 20),
                  ],
                  if (others.isNotEmpty) ...[
                    const _SectionTitle(
                        icon: Icons.explore, text: 'Descubre clínicas'),
                    const SizedBox(height: 10),
                    ...others.map((c) => _ClinicCard(
                          clinic: c,
                          userId: userId,
                          isFollowing: false,
                        )),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A))),
      ],
    );
  }
}

class _ClinicCard extends StatelessWidget {
  final ClinicModel clinic;
  final String userId;
  final bool isFollowing;

  const _ClinicCard({
    required this.clinic,
    required this.userId,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    final logo = clinic.logoUrl;
    final hasLogo = logo != null && logo.isNotEmpty;
    const accent = Color(0xFF4F46E5);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClinicPublicScreen(clinic: clinic),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: hasLogo
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
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
            ClinicFollowButton(
              userId: userId,
              clinicId: clinic.id,
              accentColor: accent,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Center(
      child: Text(
        clinic.name.isNotEmpty ? clinic.name[0].toUpperCase() : 'C',
        style: const TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
