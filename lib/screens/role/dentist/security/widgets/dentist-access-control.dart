import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class DentistAccessControl extends StatelessWidget {
  const DentistAccessControl({super.key});

  static const _darkText = Color(0xFF1D1D1F);
  static const _cardBg = Color(0xFFF5F5F7);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistSecurityProvider>();
    final profile = provider.securityData;

    final doors = profile?.doors ?? [];
    if (doors.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control de Acceso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _darkText,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            ...doors.map((door) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (door.isOn ? const Color(0xFF34C759) : const Color(0xFFFF3B30)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        door.isOn ? Icons.lock_open_outlined : Icons.lock_outlined,
                        color: door.isOn ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            door.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _darkText,
                            ),
                          ),
                          Text(
                            door.isOn ? 'Desbloqueada' : 'Bloqueada',
                            style: TextStyle(
                              fontSize: 12,
                              color: door.isOn ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      door.isOn ? Icons.check_circle : Icons.cancel,
                      color: door.isOn ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
                      size: 22,
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
