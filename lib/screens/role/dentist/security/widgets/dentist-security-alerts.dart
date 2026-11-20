import 'package:flutter/material.dart';
import 'package:medident/core/utils/app-colors.dart';
import 'package:medident/core/utils/app-constant.dart';
import 'package:medident/core/widgets/app_card.dart';
import 'package:medident/core/providers/dentist/dentist-security-provider.dart';
import 'package:provider/provider.dart';

class DentistSecurityAlerts extends StatelessWidget {
  const DentistSecurityAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DentistSecurityProvider>();
    final alerts = provider.alerts;
    final displayAlerts = alerts.take(5).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppConstants.paddingM, AppConstants.paddingS, AppConstants.paddingM, AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alertas',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                if (provider.unreadAlertsCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                    ),
                    child: Text(
                      '${provider.unreadAlertsCount} sin leer',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (displayAlerts.isEmpty)
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 32),
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 40, color: AppColors.success.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    const Text('Sin alertas', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  ],
                ),
              )
            else
              ...displayAlerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  margin: EdgeInsets.zero,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _severityColor(alert.severity).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
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
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (alert.room != null) Text(
                              alert.room!,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTime(alert.timestamp),
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
      case 'critical': return AppColors.error;
      case 'high': return const Color(0xFFFF9500);
      case 'medium': return const Color(0xFFFFCC00);
      case 'low': return AppColors.success;
      default: return AppColors.textSecondary;
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
