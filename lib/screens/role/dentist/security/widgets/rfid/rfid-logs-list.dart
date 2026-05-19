import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medident/core/models/rfid-log-model.dart';
import 'package:medident/main_export.dart';

/// Widget para mostrar lista de logs RFID
class RfidLogsListWidget extends StatelessWidget {
  final List<RfidLogModel> logs;
  final Function(RfidLogModel)? onTap;

  const RfidLogsListWidget({
    super.key,
    required this.logs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.contactless, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Sin lecturas registradas',
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
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: onTap != null ? () => onTap!(log) : null,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: log.granted
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                log.granted ? Icons.check_circle : Icons.cancel,
                color: log.granted ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              log.cardId,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.location),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(log.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: log.photoUrl != null
                ? const Icon(Icons.camera, color: Colors.blue, size: 20)
                : null,
          ),
        );
      },
    );
  }
}
