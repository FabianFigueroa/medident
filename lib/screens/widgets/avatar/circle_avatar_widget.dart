import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircleAvatar_Widget extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double radius;
  final IconData placeholderIcon;

  const CircleAvatar_Widget({
    super.key,
    this.imageUrl,
    this.imageBytes,
    this.radius = 50,
    this.placeholderIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: MemoryImage(imageBytes!),
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (_, __) => CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            child: Icon(placeholderIcon, size: radius * 0.8, color: Colors.grey.shade400),
          ),
          errorWidget: (_, __, ___) => CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            child: Icon(placeholderIcon, size: radius * 0.8, color: Colors.grey.shade400),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: Icon(placeholderIcon, size: radius * 0.8, color: Colors.grey.shade400),
    );
  }
}
