import 'package:flutter/material.dart';

class Global_Avatar_Widget extends StatelessWidget {
  final String? imageUrl;
  final double? width, height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const Global_Avatar_Widget({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl ?? '';
    if (url.isEmpty || (!url.startsWith('http://') && !url.startsWith('https://') && !url.startsWith('assets/'))) {
      return _buildSized(placeholder ?? _buildFallback());
    }
    return _buildSized(
      ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          url,
          fit: fit,
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ?? _buildFallback();
          },
          errorBuilder: (_, __, ___) => errorWidget ?? _buildFallback(),
        ),
      ),
    );
  }

  Widget _buildSized(Widget child) {
    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: child);
    }
    return child;
  }

  Widget _buildFallback() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: (width ?? 24) > 48 ? 32 : 16),
      ),
    );
  }
}

class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width, height;
  final BoxFit fit;

  const SafeNetworkImage({super.key, this.imageUrl, this.width, this.height, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl ?? '';
    if (url.isEmpty || (!url.startsWith('http://') && !url.startsWith('https://'))) {
      return _buildFallback();
    }
    return Image.network(url, width: width, height: height, fit: fit,
      loadingBuilder: (_, child, progress) => progress == null ? child : _buildFallback(),
      errorBuilder: (_, __, ___) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(width: width, height: height, color: Colors.grey[200],
      child: Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: (width ?? 24) > 48 ? 32 : 16)));
  }
}
