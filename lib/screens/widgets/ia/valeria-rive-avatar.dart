import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rive/rive.dart' hide LinearGradient;

enum ValeriaRiveExpression { idle, happy, sad, thinking, sleeping, talking }

class ValeriaRiveAvatar extends StatefulWidget {
  final double size;
  final ValeriaRiveExpression expression;
  final bool isTyping;
  final String riveAsset;
  final bool cropToTopHalf;

  const ValeriaRiveAvatar({
    super.key,
    this.size = 80,
    this.expression = ValeriaRiveExpression.idle,
    this.isTyping = false,
    this.riveAsset = 'assets/rive/valeria.riv',
    this.cropToTopHalf = false,
  });

  @override
  State<ValeriaRiveAvatar> createState() => _ValeriaRiveAvatarState();
}

class _ValeriaRiveAvatarState extends State<ValeriaRiveAvatar>
    with TickerProviderStateMixin {
  Artboard? _artboard;
  StateMachineController? _controller;
  SMIInput<double>? _expressionInput;
  SMIInput<bool>? _typingInput;
  bool _isLoaded = false;

  late AnimationController _blinkCtrl;
  late AnimationController _talkCtrl;
  late AnimationController _thinkCtrl;
  late AnimationController _breatheCtrl;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();

    _blinkCtrl = AnimationController(vsync: this);
    _talkCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _thinkCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _breatheCtrl = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _scheduleBlink();
    if (widget.isTyping || widget.expression == ValeriaRiveExpression.talking) {
      _talkCtrl.repeat(reverse: true);
    }
    if (widget.expression == ValeriaRiveExpression.thinking) {
      _thinkCtrl.repeat();
    }
  }

  void _scheduleBlink() {
    final delay = Duration(milliseconds: 2000 + math.Random().nextInt(3000));
    Future.delayed(delay, () {
      if (!mounted) return;
      _blinkCtrl.duration = const Duration(milliseconds: 150);
      _blinkCtrl.forward().then((_) {
        if (!mounted) return;
        _blinkCtrl.reverse().then((_) {
          if (mounted) _scheduleBlink();
        });
      });
    });
  }

  @override
  void didUpdateWidget(ValeriaRiveAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isLoaded) {
      if (widget.expression != oldWidget.expression && _expressionInput != null) {
        _expressionInput!.value = widget.expression.index.toDouble();
      }
      if (widget.isTyping != oldWidget.isTyping && _typingInput != null) {
        _typingInput!.value = widget.isTyping;
      }
    }

    final wasTalking = oldWidget.isTyping || oldWidget.expression == ValeriaRiveExpression.talking;
    if (widget.isTyping || widget.expression == ValeriaRiveExpression.talking) {
      if (!wasTalking) _talkCtrl.repeat(reverse: true);
    } else {
      if (wasTalking) _talkCtrl.stop();
    }

    if (widget.expression == ValeriaRiveExpression.thinking &&
        oldWidget.expression != ValeriaRiveExpression.thinking) {
      _thinkCtrl.repeat();
    } else if (widget.expression != ValeriaRiveExpression.thinking &&
        oldWidget.expression == ValeriaRiveExpression.thinking) {
      _thinkCtrl.stop();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _blinkCtrl.dispose();
    _talkCtrl.dispose();
    _thinkCtrl.dispose();
    _breatheCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRiveFile() async {
    try {
      await RiveFile.initialize();
      final bytes = await rootBundle.load(widget.riveAsset);
      final file = RiveFile.import(bytes);
      final artboard = file.mainArtboard;

      _controller = StateMachineController.fromArtboard(
        artboard,
        'State Machine 1',
      );
      if (_controller != null) {
        artboard.addController(_controller!);
        _expressionInput = _controller!.findInput('expression') as SMIInput<double>?;
        _typingInput = _controller!.findInput('typing') as SMIInput<bool>?;
      }

      setState(() {
        _artboard = artboard;
        _isLoaded = true;
      });
    } catch (e) {
      debugPrint('ValeriaRiveAvatar: $e');
      setState(() => _isLoaded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _artboard == null) {
      return _buildFallback();
    }

    Widget avatar = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Rive(artboard: _artboard!),
    );

    if (widget.cropToTopHalf) {
      avatar = ClipRect(
        clipper: _TopHalfClipper(),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(1.8, 1.8),
          child: avatar,
        ),
      );
    }

    return avatar;
  }

  Widget _buildFallback() {
    return AnimatedBuilder(
      animation: Listenable.merge([_blinkCtrl, _talkCtrl, _thinkCtrl, _breatheCtrl]),
      builder: (context, _) {
        final breathe = 1.0 + math.sin(_breatheCtrl.value * math.pi * 2) * 0.015;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1565C0),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Transform.scale(
            scale: breathe,
            child: CustomPaint(
              painter: _FallbackFacePainter(
                expression: widget.expression,
                isTyping: widget.isTyping,
                size: widget.size,
                blinkAmount: _blinkCtrl.isAnimating ? _blinkCtrl.value : 0.0,
                talkAmount: _talkCtrl.isAnimating ? _talkCtrl.value : 0.0,
                thinkPhase: _thinkCtrl.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopHalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, size.height / 2);
  }

  @override
  bool shouldReclip(_TopHalfClipper oldClipper) => false;
}

class _FallbackFacePainter extends CustomPainter {
  final ValeriaRiveExpression expression;
  final bool isTyping;
  final double size;
  final double blinkAmount;
  final double talkAmount;
  final double thinkPhase;

  _FallbackFacePainter({
    required this.expression,
    required this.isTyping,
    required this.size,
    required this.blinkAmount,
    required this.talkAmount,
    required this.thinkPhase,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final c = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final r = canvasSize.width / 2;

    if (expression == ValeriaRiveExpression.happy) _drawBlush(canvas, c, r);
    if (expression == ValeriaRiveExpression.sleeping) _drawZzz(canvas, c, r, thinkPhase);
    _drawEyes(canvas, c, r);
    _drawEyebrows(canvas, c, r);
    _drawMouth(canvas, c, r);
    if (expression == ValeriaRiveExpression.thinking) _drawThoughtBubble(canvas, c, r);
  }

  void _drawEyes(Canvas canvas, Offset c, double r) {
    final eyeOffsetX = r * 0.3;
    final eyeY = c.dy - r * 0.15;
    final eyeR = r * 0.1;
    final closed = expression == ValeriaRiveExpression.sleeping || blinkAmount > 0;

    if (closed) {
      final closeAmount = expression == ValeriaRiveExpression.sleeping ? 1.0 : blinkAmount;
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0 + closeAmount
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(c.dx - eyeOffsetX - eyeR * 0.8, eyeY),
        Offset(c.dx - eyeOffsetX + eyeR * 0.8, eyeY),
        linePaint,
      );
      canvas.drawLine(
        Offset(c.dx + eyeOffsetX - eyeR * 0.8, eyeY),
        Offset(c.dx + eyeOffsetX + eyeR * 0.8, eyeY),
        linePaint,
      );
    } else {
      final eyePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(c.dx - eyeOffsetX, eyeY), eyeR, eyePaint);
      canvas.drawCircle(Offset(c.dx + eyeOffsetX, eyeY), eyeR, eyePaint);

      final pupilPaint = Paint()..color = const Color(0xFF0D47A1);
      canvas.drawCircle(Offset(c.dx - eyeOffsetX, eyeY), eyeR * 0.5, pupilPaint);
      canvas.drawCircle(Offset(c.dx + eyeOffsetX, eyeY), eyeR * 0.5, pupilPaint);
    }
  }

  void _drawEyebrows(Canvas canvas, Offset c, double r) {
    final browY = c.dy - r * 0.38;
    final browW = r * 0.25;
    final browPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    switch (expression) {
      case ValeriaRiveExpression.happy:
        canvas.drawLine(Offset(c.dx - browW, browY + 2), Offset(c.dx - browW * 0.3, browY), browPaint);
        canvas.drawLine(Offset(c.dx + browW, browY + 2), Offset(c.dx + browW * 0.3, browY), browPaint);
      case ValeriaRiveExpression.sad:
        canvas.drawLine(Offset(c.dx - browW, browY), Offset(c.dx - browW * 0.3, browY + 3), browPaint);
        canvas.drawLine(Offset(c.dx + browW, browY), Offset(c.dx + browW * 0.3, browY + 3), browPaint);
      case ValeriaRiveExpression.thinking:
        canvas.drawLine(Offset(c.dx - browW, browY), Offset(c.dx - browW * 0.3, browY + 4), browPaint);
        canvas.drawLine(Offset(c.dx + browW, browY), Offset(c.dx + browW * 0.3, browY + 4), browPaint);
      case ValeriaRiveExpression.talking:
        canvas.drawLine(Offset(c.dx - browW, browY + 1), Offset(c.dx - browW * 0.3, browY + 1), browPaint);
        canvas.drawLine(Offset(c.dx + browW, browY + 1), Offset(c.dx + browW * 0.3, browY + 1), browPaint);
      default:
        canvas.drawLine(Offset(c.dx - browW, browY + 1), Offset(c.dx - browW * 0.3, browY + 1), browPaint);
        canvas.drawLine(Offset(c.dx + browW, browY + 1), Offset(c.dx + browW * 0.3, browY + 1), browPaint);
    }
  }

  void _drawBlush(Canvas canvas, Offset c, double r) {
    final blushPaint = Paint()..color = Colors.pink.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(c.dx - r * 0.4, c.dy + r * 0.15), r * 0.07, blushPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.4, c.dy + r * 0.15), r * 0.07, blushPaint);
  }

  void _drawThoughtBubble(Canvas canvas, Offset c, double r) {
    final bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(c.dx + r * 0.35, c.dy - r * 0.6), r * 0.08, bubblePaint);
    canvas.drawCircle(Offset(c.dx + r * 0.45, c.dy - r * 0.75), r * 0.05, bubblePaint);
    final rect = Rect.fromCenter(
      center: Offset(c.dx + r * 0.6, c.dy - r * 0.7),
      width: r * 0.4,
      height: r * 0.25,
    );
    canvas.drawOval(rect, bubblePaint);

    final dotStyle = TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: r * 0.15, fontWeight: FontWeight.bold);
    final dots = thinkPhase < 0.33
        ? '.  '
        : thinkPhase < 0.66
            ? '.. '
            : '...';
    final tp = TextPainter(text: TextSpan(text: dots, style: dotStyle), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(c.dx + r * 0.48, c.dy - r * 0.76));
  }

  void _drawZzz(Canvas canvas, Offset c, double r, double phase) {
    final alpha = 0.3 + phase * 0.4;
    final zStyle = TextStyle(color: Colors.white.withValues(alpha: alpha), fontWeight: FontWeight.bold);
    final tp1 = TextPainter(
      text: TextSpan(text: 'Z', style: zStyle.copyWith(fontSize: r * 0.2 * (0.8 + phase * 0.2))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp1.paint(canvas, Offset(c.dx + r * 0.4 - phase * 0.05, c.dy - r * 0.65 - phase * 0.05));
    final tp2 = TextPainter(
      text: TextSpan(text: 'z', style: zStyle.copyWith(fontSize: r * 0.14 * (0.8 + phase * 0.2))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas, Offset(c.dx + r * 0.55 - phase * 0.05, c.dy - r * 0.8 - phase * 0.05));
    final tp3 = TextPainter(
      text: TextSpan(text: 'z', style: zStyle.copyWith(fontSize: r * 0.1 * (0.8 + phase * 0.2))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp3.paint(canvas, Offset(c.dx + r * 0.65 - phase * 0.05, c.dy - r * 0.9 - phase * 0.05));
  }

  void _drawMouth(Canvas canvas, Offset c, double r) {
    final mouthY = c.dy + r * 0.28;
    final mouthW = r * 0.28;
    final mouthPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final isTalkingNow = isTyping || expression == ValeriaRiveExpression.talking;
    final shouldBeOpen = expression == ValeriaRiveExpression.sleeping || isTalkingNow;

    if (shouldBeOpen) {
      final openAmount = expression == ValeriaRiveExpression.sleeping ? 0.5 : 0.4 + talkAmount * 0.4;
      final openPaint = Paint()
        ..color = const Color(0xFF0D47A1)
        ..style = PaintingStyle.fill;
      final rect = Rect.fromCenter(
        center: Offset(c.dx, mouthY),
        width: mouthW * 1.2,
        height: r * 0.18 * openAmount,
      );
      canvas.drawOval(rect, openPaint);
      canvas.drawOval(rect, mouthPaint..style = PaintingStyle.stroke);
      return;
    }

    switch (expression) {
      case ValeriaRiveExpression.idle:
        final path = Path()
          ..moveTo(c.dx - mouthW, mouthY)
          ..quadraticBezierTo(c.dx, mouthY + r * 0.06, c.dx + mouthW, mouthY);
        canvas.drawPath(path, mouthPaint);
      case ValeriaRiveExpression.happy:
        final path = Path()
          ..moveTo(c.dx - mouthW, mouthY)
          ..quadraticBezierTo(c.dx, mouthY + r * 0.14, c.dx + mouthW, mouthY);
        canvas.drawPath(path, mouthPaint);
      case ValeriaRiveExpression.sad:
        final path = Path()
          ..moveTo(c.dx - mouthW * 0.8, mouthY)
          ..quadraticBezierTo(c.dx, mouthY - r * 0.08, c.dx + mouthW * 0.8, mouthY);
        canvas.drawPath(path, mouthPaint);
      case ValeriaRiveExpression.thinking:
        canvas.drawLine(Offset(c.dx - mouthW * 0.5, mouthY), Offset(c.dx + mouthW * 0.5, mouthY), mouthPaint);
      default:
        final path = Path()
          ..moveTo(c.dx - mouthW, mouthY)
          ..quadraticBezierTo(c.dx, mouthY + r * 0.06, c.dx + mouthW, mouthY);
        canvas.drawPath(path, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(_FallbackFacePainter oldDelegate) {
    return oldDelegate.expression != expression ||
        oldDelegate.size != size ||
        oldDelegate.blinkAmount != blinkAmount ||
        oldDelegate.talkAmount != talkAmount ||
        oldDelegate.thinkPhase != thinkPhase ||
        oldDelegate.isTyping != isTyping;
  }
}
