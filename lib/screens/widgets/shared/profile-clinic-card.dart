import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medident/core/models/clinic-model.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/services/clinic-service.dart';
import 'package:medident/screens/shared/clinic-public-screen.dart';

/// Tarjeta que muestra la clinica vinculada al usuario en su perfil.
/// Al tocarla abre la pantalla publica de la clinica.
class ProfileClinicCard extends StatefulWidget {
  final String userId;
  final String? clinicId;
  final bool isClinicOwner;

  const ProfileClinicCard({
    super.key,
    required this.userId,
    this.clinicId,
    this.isClinicOwner = false,
  });

  factory ProfileClinicCard.fromUser(UserModel user) {
    return ProfileClinicCard(
      userId: user.uid,
      clinicId: user.clinicId,
      isClinicOwner: user.isClinicOwner,
    );
  }

  @override
  State<ProfileClinicCard> createState() => _ProfileClinicCardState();
}

class _ProfileClinicCardState extends State<ProfileClinicCard> {
  late Future<ClinicModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadClinic();
  }

  @override
  void didUpdateWidget(covariant ProfileClinicCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clinicId != widget.clinicId ||
        oldWidget.userId != widget.userId) {
      _future = _loadClinic();
    }
  }

  Future<ClinicModel?> _loadClinic() async {
    final service = ClinicService();
    try {
      final direct = widget.clinicId;
      if (direct != null && direct.isNotEmpty) {
        final clinic = await service.getClinic(direct);
        if (clinic != null) return clinic;
      }
      if (widget.userId.isEmpty) return null;

      final clinics = await service.getClinicsForUser(widget.userId);
      if (clinics.isNotEmpty) return clinics.first;

      final fs = FirebaseFirestore.instance.collection('clinics');
      final owned = await fs
          .where('ownerId', isEqualTo: widget.userId)
          .limit(1)
          .get();
      if (owned.docs.isNotEmpty) {
        return ClinicModel.fromMap(owned.docs.first.data(), owned.docs.first.id);
      }
      final member = await fs
          .where('employeeIds', arrayContains: widget.userId)
          .limit(1)
          .get();
      if (member.docs.isNotEmpty) {
        return ClinicModel.fromMap(member.docs.first.data(), member.docs.first.id);
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClinicModel?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _shell(
            child: const SizedBox(
              height: 52,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            ),
          );
        }
        final clinic = snapshot.data;
        if (clinic == null) {
          return const SizedBox.shrink();
        }
        return _card(context, clinic);
      },
    );
  }

  Widget _shell({required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _card(BuildContext context, ClinicModel clinic) {
    final isOwner = widget.isClinicOwner || clinic.ownerId == widget.userId;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClinicPublicScreen(clinic: clinic),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                _logo(clinic),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              clinic.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _badge(isOwner),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isOwner
                            ? 'Propietario de la clinica'
                            : 'Miembro de la clinica',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo(ClinicModel clinic) {
    final logoUrl = clinic.logoUrl;
    final hasLogo = logoUrl != null && logoUrl.isNotEmpty;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        image: hasLogo
            ? DecorationImage(
                image: CachedNetworkImageProvider(logoUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasLogo
          ? null
          : const Icon(
              Icons.local_hospital_rounded,
              color: Color(0xFF4F46E5),
            ),
    );
  }

  Widget _badge(bool isOwner) {
    final color = isOwner ? const Color(0xFF0EA5A4) : const Color(0xFF4F46E5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOwner ? 'Owner' : 'Miembro',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
