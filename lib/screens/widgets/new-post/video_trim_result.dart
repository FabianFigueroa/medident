import 'dart:typed_data';

class VideoTrimResult {
  final Uint8List? bytes;
  final String? fileName;
  final Duration? duration;
  final String? error;
  final bool unsupported;

  const VideoTrimResult({
    this.bytes,
    this.fileName,
    this.duration,
    this.error,
    this.unsupported = false,
  });

  bool get hasBytes => bytes != null && bytes!.isNotEmpty;
}
