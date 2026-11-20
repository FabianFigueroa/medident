import 'dart:io';
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
  File? _tempFile;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      File file;
      if (widget.path.isNotEmpty && File(widget.path).existsSync()) {
        file = File(widget.path);
      } else {
        final dir = await Directory.systemTemp.createTemp('medident_video_');
        final safeName = widget.name.replaceAll(
          RegExp(r'[^a-zA-Z0-9._-]'),
          '_',
        );
        file = File('${dir.path}/$safeName');
        await file.writeAsBytes(widget.bytes, flush: true);
        _tempFile = file;
      }
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      setState(() => _controller = controller);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    final temp = _tempFile;
    if (temp != null) {
      temp.delete().catchError((_) => temp);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failed) {
      return const Center(
        child: Icon(
          Icons.play_circle_fill_rounded,
          color: Colors.white,
          size: 64,
        ),
      );
    }
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white70,
          ),
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
