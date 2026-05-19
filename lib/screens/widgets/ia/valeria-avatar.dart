import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ValeriaExpression {
  idle,
  thinking,
  happy,
  sad,
  sleeping,
}

class ValeriaAvatar extends StatefulWidget {
  final double size;
  final ValeriaExpression expression;
  final bool isTyping;

  const ValeriaAvatar({
    super.key,
    this.size = 80,
    this.expression = ValeriaExpression.idle,
    this.isTyping = false,
  });

  @override
  State<ValeriaAvatar> createState() => _ValeriaAvatarState();
}

class _ValeriaAvatarState extends State<ValeriaAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.isTyping) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ValeriaAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTyping && !oldWidget.isTyping) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isTyping && oldWidget.isTyping) {
      _pulseCtrl.stop();
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _pulseCtrl]),
      builder: (context, _) {
        final floatY = math.sin(_floatCtrl.value * math.pi * 2) * 4;
        final pulse = widget.isTyping ? 1 + _pulseCtrl.value * 0.08 : 1.0;
        return Transform.translate(
          offset: Offset(0, floatY),
          child: Transform.scale(
            scale: pulse,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _ValeriaFacePainter(
                  expression: widget.expression,
                  size: widget.size,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ValeriaFacePainter extends CustomPainter {
  final ValeriaExpression expression;
  final double size;

  _ValeriaFacePainter({required this.expression, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = canvasSize.width / 2;

    _drawBody(canvas, center, radius);
    switch (expression) {
      case ValeriaExpression.idle:
        _drawIdle(canvas, center, radius);
      case ValeriaExpression.thinking:
        _drawThinking(canvas, center, radius);
      case ValeriaExpression.happy:
        _drawHappy(canvas, center, radius);
      case ValeriaExpression.sad:
        _drawSad(canvas, center, radius);
      case ValeriaExpression.sleeping:
        _drawSleeping(canvas, center, radius);
    }
  }

  void _drawBody(Canvas canvas, Offset c, double r) {
    final bgPaint = Paint()..color = const Color(0xFF1565C0);
    canvas.drawCircle(c, r, bgPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(c, r, borderPaint);
  }

  void _drawEyes(Canvas canvas, Offset c, double r, {bool closed = false}) {
    final eyeOffsetX = r * 0.3;
    final eyeY = c.dy - r * 0.15;
    final eyeR = r * 0.1;

    if (closed) {
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(c.dx - eyeOffsetX - eyeR, eyeY),
        Offset(c.dx - eyeOffsetX + eyeR, eyeY),
        linePaint,
      );
      canvas.drawLine(
        Offset(c.dx + eyeOffsetX - eyeR, eyeY),
        Offset(c.dx + eyeOffsetX + eyeR, eyeY),
        linePaint,
      );
    } else {
      final eyePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(c.dx - eyeOffsetX, eyeY), eyeR, eyePaint);
      canvas.drawCircle(Offset(c.dx + eyeOffsetX, eyeY), eyeR, eyePaint);

      final pupilPaint = Paint()..color = const Color(0xFF0D47A1);
      canvas.drawCircle(
        Offset(c.dx - eyeOffsetX, eyeY),
        eyeR * 0.5,
        pupilPaint,
      );
      canvas.drawCircle(
        Offset(c.dx + eyeOffsetX, eyeY),
        eyeR * 0.5,
        pupilPaint,
      );
    }
  }

  void _drawMouth(Canvas canvas, Offset c, double r,
      {bool smile = false, bool open = false, double offsetY = 0}) {
    final mouthY = c.dy + r * 0.25 + offsetY;
    final mouthW = r * 0.3;
    final mouthPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (open) {
      final openPaint = Paint()
        ..color = const Color(0xFF0D47A1)
        ..style = PaintingStyle.fill;
      final rect = Rect.fromCenter(
        center: Offset(c.dx, mouthY),
        width: mouthW,
        height: r * 0.15,
      );
      canvas.drawOval(rect, openPaint);
      canvas.drawOval(rect, mouthPaint..style = PaintingStyle.stroke);
    } else if (smile) {
      final path = Path()
        ..moveTo(c.dx - mouthW, mouthY)
        ..quadraticBezierTo(c.dx, mouthY + r * 0.12, c.dx + mouthW, mouthY);
      canvas.drawPath(path, mouthPaint);
    } else {
      canvas.drawLine(
        Offset(c.dx - mouthW, mouthY),
        Offset(c.dx + mouthW, mouthY),
        mouthPaint,
      );
    }
  }

  void _drawIdle(Canvas canvas, Offset c, double r) {
    _drawEyes(canvas, c, r);
    _drawMouth(canvas, c, r, smile: true);
  }

  void _drawHappy(Canvas canvas, Offset c, double r) {
    _drawEyes(canvas, c, r);
    _drawMouth(canvas, c, r, smile: true, offsetY: 0.02);
    final blushPaint = Paint()
      ..color = Colors.pink.withValues(alpha: 0.3);
    canvas.drawCircle(
      Offset(c.dx - r * 0.4, c.dy + r * 0.15),
      r * 0.08,
      blushPaint,
    );
    canvas.drawCircle(
      Offset(c.dx + r * 0.4, c.dy + r * 0.15),
      r * 0.08,
      blushPaint,
    );
  }

  void _drawThinking(Canvas canvas, Offset c, double r) {
    _drawEyes(canvas, c, r);
    final handPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(c.dx + r * 0.5, c.dy - r * 0.5), width: r * 0.2, height: r * 0.3),
      0,
      math.pi,
      false,
      handPaint,
    );
    _drawMouth(canvas, c, r);
  }

  void _drawSad(Canvas canvas, Offset c, double r) {
    _drawEyes(canvas, c, r);
    final mouthY = c.dy + r * 0.25;
    final mouthW = r * 0.25;
    final mouthPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(c.dx - mouthW, mouthY)
      ..quadraticBezierTo(c.dx, mouthY - r * 0.08, c.dx + mouthW, mouthY);
    canvas.drawPath(path, mouthPaint);
  }

  void _drawSleeping(Canvas canvas, Offset c, double r) {
    _drawEyes(canvas, c, r, closed: true);
    _drawMouth(canvas, c, r, open: true);

    final zStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.6),
      fontSize: r * 0.2,
      fontWeight: FontWeight.bold,
    );
    final tp = TextPainter(
      text: TextSpan(text: 'ðŸ’¤', style: zStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx + r * 0.5, c.dy - r * 0.6));
  }

  @override
  bool shouldRepaint(_ValeriaFacePainter oldDelegate) {
    return oldDelegate.expression != expression || oldDelegate.size != size;
  }
}
