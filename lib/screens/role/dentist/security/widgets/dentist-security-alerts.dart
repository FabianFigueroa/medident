import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';
import 'package:provider/provider.dart';

class DentistSecurityAlerts extends StatelessWidget {
  const DentistSecurityAlerts({super.key});

  static const _darkText = Color(0xFF1D1D1F);
  static const _mediumText = Color(0xFF86868B);
  static const _cardBg = Color(0xFFF5F5F7);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistSecurityProvider>();
    final alerts = provider.alerts;
    final displayAlerts = alerts.take(5).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alertas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                    letterSpacing: -0.3,
                  ),
                ),
                if (provider.unreadAlertsCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${provider.unreadAlertsCount} sin leer',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF3B30),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (displayAlerts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 40, color: const Color(0xFF34C759).withOpacity(0.5)),
                    const SizedBox(height: 8),
                    const Text('Sin alertas', style: TextStyle(color: _mediumText, fontSize: 15)),
                  ],
                ),
              )
            else
              ...displayAlerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border(
                      left: BorderSide(
                        color: _severityColor(alert.severity),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _severityColor(alert.severity).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _severityIcon(alert.severity),
                          color: _severityColor(alert.severity),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _darkText,
                              ),
                            ),
                            if (alert.room != null) Text(
                              alert.room!,
                              style: TextStyle(fontSize: 12, color: _mediumText),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTime(alert.timestamp),
                        style: TextStyle(fontSize: 11, color: _mediumText),
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

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical': return const Color(0xFFFF3B30);
      case 'high': return const Color(0xFFFF9500);
      case 'medium': return const Color(0xFFFFCC00);
      case 'low': return const Color(0xFF34C759);
      default: return const Color(0xFF86868B);
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'critical': return Icons.dangerous_outlined;
      case 'high': return Icons.warning_amber_outlined;
      case 'medium': return Icons.info_outline;
      case 'low': return Icons.check_circle_outline;
      default: return Icons.circle_outlined;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${dt.day}/${dt.month}';
  }
}
