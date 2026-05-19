import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medident/main_export.dart';

/// Widget mejorado para visualizar cámara ESP32-CAM en vivo
/// Soporta streaming MJPEG, captures RFID y fotos almacenadas
class CameraLiveViewWidget extends StatefulWidget {
  final String cameraId;
  final String? streamUrl;
  final String? lastCaptureUrl;
  final bool isActive;
  final String? associatedRfid;
  final DateTime? lastAccessTime;

  const CameraLiveViewWidget({
    super.key,
    required this.cameraId,
    this.streamUrl,
    this.lastCaptureUrl,
    this.isActive = false,
    this.associatedRfid,
    this.lastAccessTime,
  });

  @override
  State<CameraLiveViewWidget> createState() => _CameraLiveViewWidgetState();
}

class _CameraLiveViewWidgetState extends State<CameraLiveViewWidget> {
  Timer? _refreshTimer;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.lastCaptureUrl ?? widget.streamUrl;
    if (widget.isActive && widget.streamUrl != null) {
      _startRefreshTimer();
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {
          _currentImageUrl = '${widget.streamUrl}?t=${DateTime.now().millisecondsSinceEpoch}';
        });
      }
    });
  }

  @override
  void didUpdateWidget(CameraLiveViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastCaptureUrl != oldWidget.lastCaptureUrl) {
      setState(() {
        _currentImageUrl = widget.lastCaptureUrl;
      });
    }
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startRefreshTimer();
      } else {
        _refreshTimer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          _buildCameraView(),
          if (widget.associatedRfid != null || widget.lastAccessTime != null)
            _buildRfidInfo(),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.videocam,
            color: widget.isActive ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cámara ${widget.cameraId}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isActive ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.isActive ? 'EN VIVO' : 'OFFLINE',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: widget.isActive && _currentImageUrl != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: _currentImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 40, color: Colors.red),
                          SizedBox(height: 8),
                          Text(
                            'Error al cargar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatTime(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                if (widget.isActive)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'REC',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : Container(
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_off,
                      size: 50,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isActive
                          ? 'Esperando stream...'
                          : 'Cámara no disponible',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRfidInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        border: Border(top: BorderSide(color: Colors.blue.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.associatedRfid != null)
                  Text(
                    'RFID: ${widget.associatedRfid}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (widget.lastAccessTime != null)
                  Text(
                    'Último acceso: ${_formatTime(widget.lastAccessTime!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlButton(
            icon: Icons.camera,
            label: 'Capturar',
            onPressed: widget.isActive
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto capturada'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                : null,
          ),
          _controlButton(
            icon: Icons.refresh,
            label: 'Actualizar',
            onPressed: () {
              setState(() {
                _currentImageUrl =
                    '${widget.streamUrl}?t=${DateTime.now().millisecondsSinceEpoch}';
              });
            },
          ),
          _controlButton(
            icon: Icons.fullscreen,
            label: 'Pantalla completa',
            onPressed: widget.isActive && _currentImageUrl != null
                ? () => _showFullscreen(context)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 20),
          onPressed: onPressed,
          color: onPressed != null ? Colors.grey[800] : Colors.grey[400],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: onPressed != null ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  void _showFullscreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'Cámara ${widget.cameraId}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: _currentImageUrl != null
                ? InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: _currentImageUrl!,
                      fit: BoxFit.contain,
                    ),
                  )
                : const Text(
                    'Sin imagen',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
