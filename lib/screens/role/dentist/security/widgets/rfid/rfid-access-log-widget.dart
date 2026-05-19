import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medident/core/models/rfid-log-model.dart';
import 'package:medident/main_export.dart';

/// Widget mejorado para mostrar logs RFID con captures de ESP32-CAM
/// Muestra foto capturada cuando se lee una tarjeta
class RfidAccessLogWidget extends StatelessWidget {
  final List<RfidLogModel> logs;
  final Function(RfidLogModel)? onTap;
  final bool showPhotos;

  const RfidAccessLogWidget({
    super.key,
    required this.logs,
    this.onTap,
    this.showPhotos = true,
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
              const SizedBox(height: 8),
              Text(
                'Los accesos aparecerán aquí cuando se lean tarjetas RFID',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center,
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
        return _buildLogTile(context, log);
      },
    );
  }

  Widget _buildLogTile(BuildContext context, RfidLogModel log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap != null ? () => onTap!(log) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildStatusIndicator(log.granted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.badge, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                log.cardId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              log.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm:ss').format(log.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(log.granted),
                ],
              ),
            ),
            if (showPhotos && log.photoUrl != null)
              _buildCapturePhoto(log.photoUrl!, log.granted),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool granted) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: granted
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        granted ? Icons.check_circle : Icons.cancel,
        color: granted ? Colors.green : Colors.red,
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge(bool granted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: granted
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        granted ? 'ACCESO' : 'DENEGADO',
        style: TextStyle(
          color: granted ? Colors.green : Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCapturePhoto(String photoUrl, bool granted) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: granted
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
          ),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: photoUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.grey),
                    SizedBox(height: 4),
                    Text('Error al cargar foto', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Capture ESP32-CAM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showPhotoFullscreen(photoUrl),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoFullscreen(String photoUrl) {
    // This would need a BuildContext from the widget tree
    // For now, we'll just show a snackbar
    debugPrint('Photo fullscreen: $photoUrl');
  }
}

/// Widget para mostrar resumen de accesos del día
class RfidAccessSummaryWidget extends StatelessWidget {
  final List<RfidLogModel> logs;

  const RfidAccessSummaryWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final todayLogs = logs.where((log) {
      final now = DateTime.now();
      return log.timestamp.year == now.year &&
          log.timestamp.month == now.month &&
          log.timestamp.day == now.day;
    }).toList();

    final grantedCount = todayLogs.where((l) => l.granted).length;
    final deniedCount = todayLogs.length - grantedCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.contactless, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Resumen de Hoy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem('Total', todayLogs.length.toString(), Colors.blue),
                _summaryItem('Accesos', grantedCount.toString(), Colors.green),
                _summaryItem('Denegados', deniedCount.toString(), Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
