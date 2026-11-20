import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'local_video_preview.dart';
import 'video_trim_result.dart';
import 'video_trim_service.dart';

class VideoEditorScreen extends StatefulWidget {
  final String path;
  final Uint8List bytes;
  final String name;
  final Duration? duration;

  const VideoEditorScreen({
    super.key,
    required this.path,
    required this.bytes,
    required this.name,
    this.duration,
  });

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  Duration? _duration;
  RangeValues _range = const RangeValues(0, 1000);
  bool _busy = false;

  static const Color _accent = Color(0xFF22D3EE);

  @override
  void initState() {
    super.initState();
    _duration = widget.duration;
    _syncRange();
    if (_duration == null) {
      _probeDuration();
    }
  }

  Future<void> _probeDuration() async {
    final duration = await probeVideoDuration(widget.path);
    if (!mounted || duration == null) return;
    setState(() {
      _duration = duration;
      _syncRange();
    });
  }

  void _syncRange() {
    final max = _maxMs;
    if (max <= 0) return;
    final start = _range.start.clamp(0, max).toDouble();
    final end = _range.end <= start ? max : _range.end.clamp(0, max).toDouble();
    _range = RangeValues(start, end);
  }

  double get _maxMs {
    final duration = _duration;
    if (duration == null) return 1000;
    final value = duration.inMilliseconds.toDouble();
    return value <= 0 ? 1000 : value;
  }

  Duration get _start =>
      Duration(milliseconds: _range.start.round().clamp(0, _maxMs.round()));

  Duration get _end {
    final max = _maxMs.round();
    return Duration(milliseconds: _range.end.round().clamp(0, max));
  }

  Future<void> _applyTrim() async {
    final duration = _duration;
    if (duration == null || _busy) return;
    final start = _start;
    final end = _end;
    if (end - start < const Duration(milliseconds: 500)) {
      _showError('El recorte debe durar al menos medio segundo.');
      return;
    }
    if (start == Duration.zero && end >= duration) {
      Navigator.pop(context);
      return;
    }
    setState(() => _busy = true);
    final result = await trimVideo(
      path: widget.path,
      bytes: widget.bytes,
      name: widget.name,
      start: start,
      end: end,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!result.hasBytes) {
      _showError(result.error ?? 'No se pudo recortar el video.');
      return;
    }
    Navigator.pop(context, result);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = _duration;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        foregroundColor: Colors.white,
        title: const Text(
          'Editar video',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LocalVideoPreview(
                      path: widget.path,
                      bytes: widget.bytes,
                      name: widget.name,
                    ),
                    if (_busy)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: _accent),
                              SizedBox(height: 12),
                              Text(
                                'Recortando video...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF111827),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.content_cut_rounded,
                        color: _accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Recortar video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _format(_end - _start),
                        style: const TextStyle(
                          color: _accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (duration == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'No se pudo leer la duración del video. Puedes '
                        'reemplazarlo o quitarlo desde el editor de publicación.',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    )
                  else ...[
                    RangeSlider(
                      values: _range,
                      min: 0,
                      max: _maxMs,
                      activeColor: _accent,
                      inactiveColor: Colors.white24,
                      labels: RangeLabels(_format(_start), _format(_end)),
                      onChanged: _busy
                          ? null
                          : (values) => setState(() => _range = values),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Inicio ${_format(_start)}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            'Fin ${_format(_end)}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: duration == null || _busy ? null : _applyTrim,
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: const Color(0xFF0B1220),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text(
                        'Aplicar recorte',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
