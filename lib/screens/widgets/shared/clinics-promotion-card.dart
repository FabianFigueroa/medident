import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:medident/core/models/clinic-model.dart';
import 'package:medident/core/services/clinic-follow-service.dart';
import 'package:medident/screens/shared/clinics-explore-screen.dart';

/// Tarjeta unica que promociona todas las clinicas de Medident.
/// Carga las clinicas activas y lleva a la pantalla de exploracion.
class ClinicsPromotionCard extends StatelessWidget {
  const ClinicsPromotionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ClinicFollowService();
    return StreamBuilder<List<ClinicModel>>(
      stream: service.streamAllClinics(),
      builder: (context, snapshot) {
        final clinics = snapshot.data ?? const <ClinicModel>[];
        final logos = clinics
            .map((c) => c.logoUrl)
            .whereType<String>()
            .where((url) => url.trim().isNotEmpty)
            .take(3)
            .toList();

        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final subtitle = isLoading
            ? 'Cargando clinicas...'
            : clinics.isEmpty
                ? 'Descubre y sigue clinicas'
                : '${clinics.length} clinica${clinics.length == 1 ? '' : 's'} disponibles';

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ClinicsExploreScreen(),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F4C81), Color(0xFF2E86AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F4C81).withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Promociones de todas las clinicas',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (logos.isNotEmpty)
                        _LogoStack(logos: logos)
                      else
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoStack extends StatelessWidget {
  final List<String> logos;

  const _LogoStack({required this.logos});

  @override
  Widget build(BuildContext context) {
    const size = 34.0;
    const overlap = 12.0;
    final width = size + (logos.length - 1) * (size - overlap);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < logos.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white24,
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: logos[i],
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      const Icon(Icons.local_hospital, color: Colors.white, size: 16),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
