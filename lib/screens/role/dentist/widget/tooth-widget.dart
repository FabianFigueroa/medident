import 'package:flutter/material.dart';
import 'package:medident/core/models/odontogram-constants.dart';

class ToothWidget extends StatelessWidget {
  final ToothData tooth;
  final bool isSelected;
  final VoidCallback onTap;

  const ToothWidget({
    super.key,
    required this.tooth,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUpper = isUpperTooth(tooth.number);
    final color = Color(tooth.state.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: const Size(40, 44),
        painter: _ToothPainter(
          stateColor: color,
          isUpper: isUpper,
          isSelected: isSelected,
          isMissing: tooth.state == ToothState.missing,
        ),
      ),
    );
  }
}

class _ToothPainter extends CustomPainter {
  final Color stateColor;
  final bool isUpper;
  final bool isSelected;
  final bool isMissing;

  _ToothPainter({
    required this.stateColor,
    required this.isUpper,
    required this.isSelected,
    required this.isMissing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMissing ? Colors.grey.shade300 : stateColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final borderPaint = Paint()
      ..color = isSelected ? Colors.blue : Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.5;

    final w = size.width;
    final h = size.height;
    final r = w * 0.35;

    final path = Path();

    if (isMissing) {
      final center = Offset(w / 2, h / 2);
      canvas.drawLine(
        Offset(center.dx - 8, center.dy - 8),
        Offset(center.dx + 8, center.dy + 8),
        Paint()..color = Colors.grey.shade400..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset(center.dx + 8, center.dy - 8),
        Offset(center.dx - 8, center.dy + 8),
        Paint()..color = Colors.grey.shade400..strokeWidth = 2,
      );
      return;
    }

    if (isUpper) {
      path.moveTo(0, h);
      path.lineTo(0, h * 0.4);
      path.quadraticBezierTo(w / 2, -r, w, h * 0.4);
      path.lineTo(w, h);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(0, h * 0.6);
      path.quadraticBezierTo(w / 2, h + r, w, h * 0.6);
      path.lineTo(w, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    if (isUpper) {
      final lineY = h * 0.65;
      canvas.drawLine(Offset(w * 0.15, lineY), Offset(w * 0.85, lineY),
          Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 1);
      canvas.drawLine(Offset(w * 0.15, lineY + 3), Offset(w * 0.85, lineY + 3),
          Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 1);
    } else {
      final lineY = h * 0.35;
      canvas.drawLine(Offset(w * 0.15, lineY), Offset(w * 0.85, lineY),
          Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 1);
      canvas.drawLine(Offset(w * 0.15, lineY + 3), Offset(w * 0.85, lineY + 3),
          Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant _ToothPainter old) =>
      old.stateColor != stateColor ||
      old.isSelected != isSelected ||
      old.isMissing != isMissing;
}
