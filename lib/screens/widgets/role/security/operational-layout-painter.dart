import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medident/screens/role/admin/security/models.dart';

import '../../../../main_export.dart';

class OperationalLayoutPainter extends CustomPainter {
  final List<RoomBlueprintModel> rooms;
  final int selectedRoom;
  final DoorSideEnums? selectedWall;
  final String wallStyle;
  final bool showGrid;

  static const double _eps = 0.004;

  const OperationalLayoutPainter({
    required this.rooms,
    required this.selectedRoom,
    required this.selectedWall,
    required this.wallStyle,
    required this.showGrid,
  });

  void _paintDoor(
    Canvas canvas,
    Rect rect,
    DoorBlueprintModel door,
    double strokeWidth,
  ) {
    const doorSize = 26.0;
    final erasePaint = Paint()
      ..color = const Color(0xFFF8F5EF)
      ..strokeWidth = strokeWidth + 4
      ..style = PaintingStyle.stroke;
    final arcPaint = Paint()
      ..color = const Color(0xFFB5ACA0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    switch (door.side) {
      case DoorSideEnums.top:
        final cx = rect.left + rect.width * door.offset;
        canvas.drawLine(
          Offset(cx - doorSize / 2, rect.top),
          Offset(cx + doorSize / 2, rect.top),
          erasePaint,
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, rect.top), radius: doorSize),
          0,
          1.57,
          false,
          arcPaint,
        );
      case DoorSideEnums.right:
        final cy = rect.top + rect.height * door.offset;
        canvas.drawLine(
          Offset(rect.right, cy - doorSize / 2),
          Offset(rect.right, cy + doorSize / 2),
          erasePaint,
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset(rect.right, cy), radius: doorSize),
          1.57,
          1.57,
          false,
          arcPaint,
        );
      case DoorSideEnums.bottom:
        final cx = rect.left + rect.width * door.offset;
        canvas.drawLine(
          Offset(cx - doorSize / 2, rect.bottom),
          Offset(cx + doorSize / 2, rect.bottom),
          erasePaint,
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, rect.bottom), radius: doorSize),
          3.14,
          1.57,
          false,
          arcPaint,
        );
      case DoorSideEnums.left:
        final cy = rect.top + rect.height * door.offset;
        canvas.drawLine(
          Offset(rect.left, cy - doorSize / 2),
          Offset(rect.left, cy + doorSize / 2),
          erasePaint,
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset(rect.left, cy), radius: doorSize),
          4.71,
          1.57,
          false,
          arcPaint,
        );
    }
  }

  void _drawSegment(
    Canvas canvas,
    Rect rect,
    DoorSideEnums side,
    _Seg seg,
    Paint paint,
  ) {
    switch (side) {
      case DoorSideEnums.top:
        canvas.drawLine(
          Offset(seg.a, rect.top),
          Offset(seg.b, rect.top),
          paint,
        );
      case DoorSideEnums.bottom:
        canvas.drawLine(
          Offset(seg.a, rect.bottom),
          Offset(seg.b, rect.bottom),
          paint,
        );
      case DoorSideEnums.left:
        canvas.drawLine(
          Offset(rect.left, seg.a),
          Offset(rect.left, seg.b),
          paint,
        );
      case DoorSideEnums.right:
        canvas.drawLine(
          Offset(rect.right, seg.a),
          Offset(rect.right, seg.b),
          paint,
        );
    }
  }

  List<_Seg> _subtractSeg(List<_Seg> source, _Seg block) {
    final result = <_Seg>[];
    for (final s in source) {
      if (block.b <= s.a || block.a >= s.b) {
        result.add(s);
        continue;
      }
      if (block.a > s.a) result.add(_Seg(s.a, block.a));
      if (block.b < s.b) result.add(_Seg(block.b, s.b));
    }
    return result.where((s) => s.b - s.a > 1).toList();
  }

  _Seg? _vertOverlap(RoomBlueprintModel a, RoomBlueprintModel b) {
    final s = max(a.y, b.y);
    final e = min(a.y + a.h, b.y + b.h);
    return e > s + 0.001 ? _Seg(s, e) : null;
  }

  _Seg _normToPixelSeg(_Seg norm, DoorSideEnums side, Size size) {
    final scale = (side == DoorSideEnums.top || side == DoorSideEnums.bottom)
        ? size.width
        : size.height;
    return _Seg(norm.a * scale, norm.b * scale);
  }

  bool _doorIsOnVisibleWall(
    int i,
    DoorSideEnums side,
    DoorBlueprintModel door,
    Size size,
  ) {
    final segs = _visibleSegments(i, side, size);
    final rect = _toPixelRect(rooms[i], size);
    final center = (side == DoorSideEnums.top || side == DoorSideEnums.bottom)
        ? rect.left + rect.width * door.offset
        : rect.top + rect.height * door.offset;
    const half = 14.0;
    return segs.any(
      (s) => center - half >= s.a - 1 && center + half <= s.b + 1,
    );
  }

  _Seg? _sharedWallRange(
    RoomBlueprintModel room,
    RoomBlueprintModel other,
    DoorSideEnums side,
  ) {
    switch (side) {
      case DoorSideEnums.top:
        if ((room.y - (other.y + other.h)).abs() > _eps) return null;
        return _horizOverlap(room, other);
      case DoorSideEnums.bottom:
        if ((room.y + room.h - other.y).abs() > _eps) return null;
        return _horizOverlap(room, other);
      case DoorSideEnums.left:
        if ((room.x - (other.x + other.w)).abs() > _eps) return null;
        return _vertOverlap(room, other);
      case DoorSideEnums.right:
        if ((room.x + room.w - other.x).abs() > _eps) return null;
        return _vertOverlap(room, other);
    }
  }

  _Seg? _horizOverlap(RoomBlueprintModel a, RoomBlueprintModel b) {
    final s = max(a.x, b.x);
    final e = min(a.x + a.w, b.x + b.w);
    return e > s + 0.001 ? _Seg(s, e) : null;
  }

  Rect _toPixelRect(RoomBlueprintModel r, Size s) => Rect.fromLTWH(
    s.width * r.x,
    s.height * r.y,
    s.width * r.w,
    s.height * r.h,
  );

  _Seg _fullSeg(Rect rect, DoorSideEnums side) => switch (side) {
    DoorSideEnums.top || DoorSideEnums.bottom => _Seg(rect.left, rect.right),
    DoorSideEnums.left || DoorSideEnums.right => _Seg(rect.top, rect.bottom),
  };

  List<_Seg> _visibleSegments(int i, DoorSideEnums side, Size size) {
    final room = rooms[i];
    final rect = _toPixelRect(room, size);
    var segs = <_Seg>[_fullSeg(rect, side)];

    for (int j = 0; j < rooms.length; j++) {
      if (j == i) continue;
      final other = rooms[j];
      final shared = _sharedWallRange(room, other, side);
      if (shared == null) continue;

      if (i > j) {
        final pxShared = _normToPixelSeg(shared, side, size);
        segs = _subtractSeg(segs, pxShared);
      }
    }

    return segs;
  }

  @override
  bool shouldRepaint(OperationalLayoutPainter oldDelegate) {
    return oldDelegate.rooms != rooms ||
        oldDelegate.selectedRoom != selectedRoom ||
        oldDelegate.selectedWall != selectedWall ||
        oldDelegate.wallStyle != wallStyle ||
        oldDelegate.showGrid != showGrid;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF8F5EF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(22)),
      bg,
    );

    if (showGrid) {
      final gridPaint = Paint()
        ..color = const Color(0xFFE8E1D6)
        ..strokeWidth = 0.6;
      for (double x = 24; x < size.width; x += 24) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 24; y < size.height; y += 24) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    final wallColor = switch (wallStyle) {
      'Muro reforzado' => const Color(0xFF4B5563),
      'Cristal controlado' => const Color(0xFF5B8DEF),
      _ => const Color(0xFF8A8175),
    };

    for (int i = 0; i < rooms.length; i++) {
      final rect = _toPixelRect(rooms[i], size);
      final fill = Paint()
        ..color = i == selectedRoom
            ? const Color(0xFFEAF0FF)
            : const Color(0x0AFFFFFF);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        fill,
      );
    }

    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      final rect = _toPixelRect(room, size);
      final isSelected = i == selectedRoom;

      final wallPaint = Paint()
        ..color = isSelected ? const Color(0xFF3A7AFE) : wallColor
        ..strokeWidth = isSelected ? 2.4 : 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (final side in DoorSideEnums.values) {
        final segments = _visibleSegments(i, side, size);
        for (final seg in segments) {
          _drawSegment(canvas, rect, side, seg, wallPaint);
        }

        for (final door in room.doors.where((d) => d.side == side)) {
          if (_doorIsOnVisibleWall(i, side, door, size)) {
            _paintDoor(canvas, rect, door, wallPaint.strokeWidth);
          }
        }

        if (isSelected && selectedWall == side) {
          final highlight = Paint()
            ..color = const Color(0xFF2563EB)
            ..strokeWidth = wallPaint.strokeWidth + 1.6
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
          _drawSegment(canvas, rect, side, _fullSeg(rect, side), highlight);
        }
      }
    }
  }
}

class _Seg {
  final double a;
  final double b;

  const _Seg(this.a, this.b);
}
