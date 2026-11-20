import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Lightweight startup profiler (debug/profile only, no-op in release).
///
/// Use `mark()`/`markOnce()` for stages (never per frame), `measure()` for real
/// Futures and `complete()` once the app reached login/home/onboarding.
class StartupProfiler {
  StartupProfiler._();
  static final StartupProfiler instance = StartupProfiler._();

  static const bool enabled = !kReleaseMode;
  static const int objetivoPrimerFrameMs = 1500;
  static const int objetivoArranqueMs = 3000;

  final Stopwatch _sw = Stopwatch();
  final List<StartupMark> marks = [];
  final Set<String> _once = {};

  bool _started = false;
  bool _frameWindowOpen = false;
  int _totalFrames = 0;
  int _slowFrames = 0;
  int _worstFrameMs = 0;
  int _worstUiMs = 0;
  int _worstRasterMs = 0;

  void Function(int totalMs)? onComplete;

  void mark(String name, {String? hint}) {
    if (!enabled) return;
    _ensureStarted();
    final total = _sw.elapsedMilliseconds;
    final delta = marks.isEmpty ? total : total - marks.last.atMs;
    marks.add(StartupMark(name, total, delta, hint));
    debugPrint('+${total.toString().padLeft(5)} ms  '
        '${marks.length.toString().padLeft(2)}. $name (d$delta)'
        '${hint == null ? '' : ' - $hint'}');
  }

  void markOnce(String name, {String? hint}) {
    if (!enabled) return;
    if (_once.contains(name)) return;
    _once.add(name);
    mark(name, hint: hint);
  }

  Future<T> measure<T>(String name, Future<T> Function() body,
      {String? hint}) async {
    if (!enabled) return body();
    _ensureStarted();
    final t0 = _sw.elapsedMilliseconds;
    try {
      return await body();
    } finally {
      final took = _sw.elapsedMilliseconds - t0;
      mark(name, hint: 'took $took ms${hint == null ? '' : ' - $hint'}');
    }
  }

  void _ensureStarted() {
    if (_started) return;
    _sw.start();
    _started = true;
  }

  bool _firstFrameScheduled = false;
  void scheduleFirstFrame() {
    if (!enabled || _firstFrameScheduled) return;
    _firstFrameScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _startFrameWindow();
      markOnce('primer frame pintado');
    });
  }

  void complete(String status) {
    if (!enabled) return;
    if (_once.contains('arranque completo')) return;
    _once.add('arranque completo');
    mark('arranque completo', hint: 'status=$status');
    if (!kReleaseMode) {
      debugPrint(report());
    }
    onComplete?.call(marks.isEmpty ? 0 : marks.last.atMs);
  }

  int get totalMs => marks.isEmpty ? 0 : marks.last.atMs;
  bool get hasCompleted => _once.contains('arranque completo');

  void _startFrameWindow() {
    if (_frameWindowOpen) return;
    _frameWindowOpen = true;
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (!enabled || !_frameWindowOpen) return;
    if (_sw.elapsedMilliseconds > 5000) {
      _frameWindowOpen = false;
      debugPrint('[StartupProfiler] frames 5s: total=$_totalFrames '
          'lentos(>16ms)=$_slowFrames | peor=$_worstFrameMs ms '
          '(UI $_worstUiMs / raster $_worstRasterMs)');
      return;
    }
    for (final t in timings) {
      _totalFrames++;
      final total = t.totalSpan.inMicroseconds ~/ 1000;
      final ui = t.buildDuration.inMicroseconds ~/ 1000;
      final raster = t.rasterDuration.inMicroseconds ~/ 1000;
      if (total > _worstFrameMs) _worstFrameMs = total;
      if (ui > _worstUiMs) _worstUiMs = ui;
      if (raster > _worstRasterMs) _worstRasterMs = raster;
      if (ui > 16 || raster > 16) _slowFrames++;
    }
  }

  List<String> diagnosis() {
    final out = <String>[];
    if (marks.isEmpty) return ['[SIN DATOS] Todavia no hay marcas de arranque.'];
    for (final m in marks) {
      if (m.deltaMs >= 600) {
        out.add('[ALTA] ${m.deltaMs} ms en "${m.name}"'
            '${m.hint == null ? '' : ' (${m.hint})'} - revisar red/IO.');
      } else if (m.deltaMs >= 300) {
        out.add('[MEDIA] ${m.deltaMs} ms en "${m.name}" - revisar si es espera.');
      }
    }
    if (_worstUiMs >= 33) {
      out.add('[ALTA] Hilo UI trabado: peor build $_worstUiMs ms. '
          'Accion: diferir I/O del arbol inicial.');
    }
    if (_worstRasterMs >= 33) {
      out.add('[ALTA] GPU con picos de $_worstRasterMs ms. '
          'Accion: RepaintBoundary + imagenes con cacheWidth.');
    }
    if (out.isEmpty) out.add('[OK] Sin cuellos de botella claros.');
    return out;
  }

  String report() {
    final b = StringBuffer();
    b.writeln('===== ARRANQUE MEDIDENT (debug/profile) =====');
    b.writeln('Total: $totalMs ms | marcas: ${marks.length}');
    for (var i = 0; i < marks.length; i++) {
      final m = marks[i];
      b.writeln('+${m.atMs.toString().padLeft(6)} ms  '
          '${(i + 1).toString().padLeft(2)}. ${m.name} (d${m.deltaMs})'
          '${m.hint == null ? '' : '  [${m.hint}]'}');
    }
    if (_totalFrames > 0) {
      final pct = (_slowFrames * 100) ~/ _totalFrames;
      b.writeln('frames=$_totalFrames lentos=$_slowFrames ($pct%) '
          'peor=$_worstFrameMs ms UI=$_worstUiMs raster=$_worstRasterMs');
    }
    b.writeln('--- DIAGNOSTICO ---');
    for (final line in diagnosis()) {
      b.writeln(line);
    }
    b.writeln('Objetivo: primer frame < $objetivoPrimerFrameMs ms, '
        'arranque < $objetivoArranqueMs ms');
    b.writeln('============================================');
    return b.toString();
  }

  void reset() {
    marks.clear();
    _once.clear();
    _totalFrames = 0;
    _slowFrames = 0;
    _worstFrameMs = 0;
    _worstUiMs = 0;
    _worstRasterMs = 0;
    _started = false;
    _frameWindowOpen = false;
    _firstFrameScheduled = false;
  }
}

class StartupMark {
  final String name;
  final int atMs;
  final int deltaMs;
  final String? hint;
  const StartupMark(this.name, this.atMs, this.deltaMs, this.hint);
}
