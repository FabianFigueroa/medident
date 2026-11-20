import 'dart:typed_data';

import 'video_trim_result.dart';

Future<Duration?> probeVideoDuration(String path) async => null;

Future<VideoTrimResult> trimVideo({
  required String path,
  required Uint8List bytes,
  required String name,
  required Duration start,
  required Duration end,
}) async {
  return const VideoTrimResult(
    unsupported: true,
    error: 'El recorte de video no está disponible en esta plataforma.',
  );
}
