import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medident/core/models/media-item.dart';

class MediaViewer extends StatelessWidget {
  final MediaItem media;
  final double? width, height;
  final BoxFit fit;
  final double borderRadius;
  final VoidCallback? onTap;

  const MediaViewer({
    super.key,
    required this.media,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return switch (media.type) {
      MediaType.image => _buildImage(),
      MediaType.video => _buildVideo(context),
      MediaType.document => _buildDocument(),
    };
  }

  Widget _buildImage() {
    if (media.url.isEmpty) return _buildFallback(Icons.image_not_supported_outlined);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: media.url,
          width: width,
          height: height,
          fit: fit,
          placeholder: (_, __) => _buildPlaceholder(),
          errorWidget: (_, __, ___) => _buildFallback(Icons.broken_image_outlined),
        ),
      ),
    );
  }

  Widget _buildVideo(BuildContext context) {
    final thumb = media.thumbnailUrl ?? MediaItem.extractThumbnail(media.url);
    return GestureDetector(
      onTap: () => _openVideo(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumb != null && thumb.isNotEmpty)
              CachedNetworkImage(imageUrl: thumb, width: width, height: height, fit: fit,
                placeholder: (_, __) => _buildPlaceholder(),
                errorWidget: (_, __, ___) => _buildFallback(Icons.videocam_outlined),
              )
            else
              _buildFallback(Icons.videocam_outlined),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
                ),
                child: const Icon(Icons.play_arrow, color: Colors.black87, size: 30),
              ),
            ),
            if (media.name != null)
              Positioned(
                bottom: 8, left: 8, right: 8,
                child: Text(media.name!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocument() {
    final ext = media.url.split('.').last.toUpperCase();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height ?? 120,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_documentIcon(ext), size: 32, color: Colors.blue[400]),
          const SizedBox(height: 6),
          Text(ext, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.blue[600])),
          if (media.name != null) ...[
            const SizedBox(height: 2),
            Text(media.name!, style: TextStyle(fontSize: 11, color: Colors.blue[800]),
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          ],
        ]),
      ),
    );
  }

  void _openVideo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.play_circle_outline, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                Text('Reproducir video', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                if (media.url.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(media.url, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                      maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(width: width, height: height, color: Colors.grey[200]);
  }

  Widget _buildFallback(IconData icon) {
    return Container(width: width, height: height, color: Colors.grey[200],
      child: Center(child: Icon(icon, color: Colors.grey[400], size: (width ?? 40) > 48 ? 32 : 18)));
  }

  IconData _documentIcon(String ext) {
    switch (ext) {
      case 'PDF': return Icons.picture_as_pdf;
      case 'DOC': case 'DOCX': return Icons.description;
      case 'XLS': case 'XLSX': return Icons.table_chart;
      case 'TXT': return Icons.text_snippet;
      case 'ZIP': case 'RAR': return Icons.folder_zip;
      default: return Icons.insert_drive_file;
    }
  }
}
