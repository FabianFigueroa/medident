import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medident/core/models/alert-model.dart';
import 'package:medident/main_export.dart';

/// Widget para mostrar lista de alertas
class AlertsListWidget extends StatelessWidget {
  final List<AlertModel> alerts;
  final Function(AlertModel)? onTap;
  final Function(AlertModel)? onMarkRead;

  const AlertsListWidget({
    super.key,
    required this.alerts,
    this.onTap,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.notifications_off, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Sin alertas',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: alert.read ? null : Colors.blue.withOpacity(0.05),
          child: ListTile(
            onTap: onTap != null ? () => onTap!(alert) : null,
            leading: Text(
              alert.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!alert.read)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('dd/MM HH:mm').format(alert.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSeverityBadge(alert.severity),
                if (!alert.read && onMarkRead != null)
                  IconButton(
                    icon: const Icon(Icons.mark_email_read, size: 18),
                    onPressed: () => onMarkRead!(alert),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity) {
      case 'critical':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.yellow[700]!;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
