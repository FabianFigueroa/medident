import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LocalVideoPreview extends StatefulWidget {
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
  State<LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<LocalVideoPreview> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.path.isEmpty) return;
    try {
      final uri = Uri.tryParse(widget.path);
      if (uri == null) return;
      final controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      setState(() => _controller = controller);
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: Icon(
          Icons.play_circle_fill_rounded,
          color: Colors.white,
          size: 64,
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          controller.value.isPlaying ? controller.pause() : controller.play();
        });
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              VideoPlayer(controller),
              if (!controller.value.isPlaying)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
