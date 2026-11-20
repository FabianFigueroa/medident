import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter_new_https/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_https/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_https/return_code.dart';

import 'video_trim_result.dart';

Future<Duration?> probeVideoDuration(String path) async {
  if (path.isEmpty || !File(path).existsSync()) return null;
  try {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = await session.getMediaInformation();
    final raw = info?.getDuration();
    final seconds = double.tryParse(raw ?? '');
    if (seconds == null || seconds <= 0) return null;
    return Duration(milliseconds: (seconds * 1000).round());
  } catch (_) {
    return null;
  }
}

Future<VideoTrimResult> trimVideo({
  required String path,
  required Uint8List bytes,
  required String name,
  required Duration start,
  required Duration end,
}) async {
  File? temporaryInput;
  File? output;
  try {
    var input = path.isNotEmpty ? File(path) : null;
    if (input == null || !input.existsSync()) {
      temporaryInput = await _writeTemporaryInput(bytes, name);
      input = temporaryInput;
    }

    final extension = _outputExtension(name);
    output = File(
      '${Directory.systemTemp.path}/medident_trim_'
      '${DateTime.now().microsecondsSinceEpoch}.$extension',
    );

    final session = await FFmpegKit.executeWithArguments([
      '-y',
      '-ss',
      _seconds(start),
      '-i',
      input.path,
      '-t',
      _seconds(end - start),
      '-c',
      'copy',
      '-avoid_negative_ts',
      'make_zero',
      output.path,
    ]);
    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getOutput();
      return VideoTrimResult(error: _shortError(logs));
    }
    if (!output.existsSync()) {
      return const VideoTrimResult(
        error: 'El recorte no generó un archivo válido.',
      );
    }
    final outputBytes = await output.readAsBytes();
    return VideoTrimResult(
      bytes: outputBytes,
      fileName: 'recortado_${DateTime.now().millisecondsSinceEpoch}.$extension',
      duration: end - start,
    );
  } catch (e) {
    return VideoTrimResult(error: 'No se pudo recortar el video: $e');
  } finally {
    try {
      if (output != null && output.existsSync()) await output.delete();
    } catch (_) {}
    try {
      if (temporaryInput != null && temporaryInput.existsSync()) {
        await temporaryInput.delete();
      }
    } catch (_) {}
  }
}

Future<File> _writeTemporaryInput(Uint8List bytes, String name) async {
  final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  final file = File(
    '${Directory.systemTemp.path}/medident_input_'
    '${DateTime.now().microsecondsSinceEpoch}_$safeName',
  );
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

String _outputExtension(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.webm')) return 'webm';
  if (lower.endsWith('.mkv')) return 'mkv';
  if (lower.endsWith('.avi')) return 'avi';
  return 'mp4';
}

String _seconds(Duration duration) {
  return (duration.inMilliseconds / 1000).toStringAsFixed(3);
}

String _shortError(String? logs) {
  final text = (logs ?? '').trim();
  if (text.isEmpty) return 'No se pudo recortar el video.';
  final short = text.length > 400 ? text.substring(text.length - 400) : text;
  return 'No se pudo recortar el video. $short';
}
