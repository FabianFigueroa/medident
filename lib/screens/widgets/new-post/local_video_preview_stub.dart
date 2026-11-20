import 'dart:typed_data';

import 'package:flutter/material.dart';

class LocalVideoPreview extends StatelessWidget {
  final String path;
  final Uint8List bytes;
  final String name;

  const LocalVideoPreview({
    super.key,
    required this.path,
    required this.bytes,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.play_circle_fill_rounded,
        color: Colors.white,
        size: 64,
      ),
    );
  }
}
