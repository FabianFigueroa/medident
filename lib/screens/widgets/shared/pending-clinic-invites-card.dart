import 'package:flutter/material.dart';
import 'package:medident/core/models/employee-model.dart';
import 'package:medident/core/services/employee-link-service.dart';

/// Muestra las invitaciones pendientes para unirse a una clínica.
class PendingClinicInvitesCard extends StatelessWidget {
  final String userId;
  final VoidCallback? onAccepted;

  const PendingClinicInvitesCard({
    super.key,
    required this.userId,
    this.onAccepted,
  });

  static const _accent = Color(0xFFF59E0B);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: EmployeeLinkService().streamUserRequests(userId),
      builder: (context, snapshot) {
        final requests = snapshot.data ?? const [];
        if (requests.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.mark_email_unread_outlined,
                            size: 17, color: _accent),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Invitaciones de clínicas',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _text),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${requests.length}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _accent)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...requests.map((r) => _requestTile(context, r)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _requestTile(BuildContext context, Map<String, dynamic> request) {
    final clinicName = (request['clinicName'] ?? 'Clínica').toString();
    final ownerName = (request['ownerName'] ?? '').toString();
    final position = (request['position'] ?? '').toString();
    final requestId = request['id'] as String;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(clinicName,
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _text)),
          const SizedBox(height: 2),
          Text(
            position.isNotEmpty
                ? '$ownerName · ${EmployeePositions.displayName(position)}'
                : ownerName,
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _respond(context, requestId, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _muted,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Rechazar',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _respond(context, requestId, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Aceptar',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _respond(
    BuildContext context,
    String requestId,
    bool accept,
  ) async {
    try {
      await EmployeeLinkService()
          .respondRequest(requestId: requestId, accept: accept);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept
              ? 'Te uniste a la clínica correctamente.'
              : 'Invitación rechazada.'),
          backgroundColor: accept ? _accent : const Color(0xFF64748B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      if (accept) onAccepted?.call();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo procesar: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
