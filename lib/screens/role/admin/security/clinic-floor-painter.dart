// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  CUSTOM PAINTER â€“ Clinic Floor
//  (within epsilon), the shared segment is drawn ONLY by the
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medident/screens/role/admin/security/models.dart';

import '../../../../main_export.dart';

class ClinicFloorPainterWidget extends CustomPainter {
  final List<RoomBlueprintModel> rooms;
  final int selectedRoom;
  final DoorSideEnums? selectedWall;
  final String wallStyle;
  final bool showGrid;

  /// Epsilon in NORMALIZED coordinates for detecting shared walls.
  /// 0.004 â‰ˆ 2â€“3 pixels on a 600px canvas â€” tight but reliable.
  static const double _eps = 0.004;

  const ClinicFloorPainterWidget({
    required this.rooms,
    required this.selectedRoom,
    required this.selectedWall,
    required this.wallStyle,
    required this.showGrid,
  });

  // â”€â”€ Paint door opening â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  /////////////////////////
  // â”€â”€ Draw a wall segment â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€ Subtract one segment from a list of segments â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  /// Vertical overlap range (normalized Y)
  _Seg? _vertOverlap(RoomBlueprintModel a, RoomBlueprintModel b) {
    final s = max(a.y, b.y);
    final e = min(a.y + a.h, b.y + b.h);
    return e > s + 0.001 ? _Seg(s, e) : null;
  }

  /// Convert a normalized segment to pixel coordinates
  _Seg _normToPixelSeg(_Seg norm, DoorSideEnums side, Size size) {
    final scale = (side == DoorSideEnums.top || side == DoorSideEnums.bottom)
        ? size.width
        : size.height;
    return _Seg(norm.a * scale, norm.b * scale);
  }

  /// Returns the shared range (in normalized coords) if room[i].side
  /// touches the opposite side of `other`, or null.
  _Seg? _sharedWallRange(
    RoomBlueprintModel room,
    RoomBlueprintModel other,
    DoorSideEnums side,
  ) {
    switch (side) {
      case DoorSideEnums.top:
        // room's top vs other's bottom
        if ((room.y - (other.y + other.h)).abs() > _eps) return null;
        return _horizOverlap(room, other);
      case DoorSideEnums.bottom:
        // room's bottom vs other's top
        if ((room.y + room.h - other.y).abs() > _eps) return null;
        return _horizOverlap(room, other);
      case DoorSideEnums.left:
        // room's left vs other's right
        if ((room.x - (other.x + other.w)).abs() > _eps) return null;
        return _vertOverlap(room, other);
      case DoorSideEnums.right:
        // room's right vs other's left
        if ((room.x + room.w - other.x).abs() > _eps) return null;
        return _vertOverlap(room, other);
    }
  }

  /// Horizontal overlap range (normalized X)
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

  // â”€â”€ Compute visible (non-shared) segments for room[i].side
  //    Uses NORMALIZED coordinates for reliable comparison.
  List<_Seg> _visibleSegments(int i, DoorSideEnums side, Size size) {
    final room = rooms[i];
    final rect = _toPixelRect(room, size);
    var segs = <_Seg>[_fullSeg(rect, side)];

    for (int j = 0; j < rooms.length; j++) {
      if (j == i) continue;
      final other = rooms[j];

      final shared = _sharedWallRange(room, other, side);
      if (shared == null) continue;

      // Only the lower index draws shared walls.
      // Higher index subtracts the shared portion.
      if (i > j) {
        // Convert shared range (normalized) to pixels
        final pxShared = _normToPixelSeg(shared, side, size);
        segs = _subtractSeg(segs, pxShared);
      }
      // if i < j: keep (this room draws it)
    }

    return segs;
  }

  @override
  bool shouldRepaint(ClinicFloorPainterWidget old) {
    return old.rooms != rooms ||
        old.selectedRoom != selectedRoom ||
        old.selectedWall != selectedWall ||
        old.wallStyle != wallStyle ||
        old.showGrid != showGrid;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // â”€â”€ Background â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    final bg = Paint()..color = const Color(0xFFF8F5EF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(22)),
      bg,
    );

    // â”€â”€ Grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

    // â”€â”€ Wall color â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    final wallColor = switch (wallStyle) {
      'Muro reforzado' => const Color(0xFF4B5563),
      'Cristal controlado' => const Color(0xFF5B8DEF),
      _ => const Color(0xFF8A8175),
    };

    // â”€â”€ Room fills â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    for (int i = 0; i < rooms.length; i++) {
      final r = rooms[i];
      final rect = _toPixelRect(r, size);
      final fill = Paint()
        ..color = i == selectedRoom
            ? const Color(0xFFEAF0FF)
            : const Color(0x0AFFFFFF);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        fill,
      );
    }

    // â”€â”€ Draw walls with shared-wall deduplication â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      final rect = _toPixelRect(room, size);
      final isSelected = i == selectedRoom;

      final wPaint = Paint()
        ..color = isSelected ? const Color(0xFF3A7AFE) : wallColor
        ..strokeWidth = isSelected ? 2.4 : 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (final side in DoorSideEnums.values) {
        final segments = _visibleSegments(i, side, size);
        for (final seg in segments) {
          _drawSegment(canvas, rect, side, seg, wPaint);
        }

        // Doors stay visible even when the wall segment is shared with another
        // room. The merge removes duplicate wall strokes, not user access.
        for (final door in room.doors.where((d) => d.side == side)) {
          _paintDoor(canvas, rect, door, wPaint.strokeWidth);
        }

        // Selected wall highlight
        if (isSelected && selectedWall == side) {
          final highlight = Paint()
            ..color = const Color(0xFF2563EB)
            ..strokeWidth = wPaint.strokeWidth + 1.6
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
          final full = _fullSeg(rect, side);
          _drawSegment(canvas, rect, side, full, highlight);
        }
      }
    }
  }
}

/// A 1D segment [a, b).
class _Seg {
  final double a;
  final double b;
  const _Seg(this.a, this.b);
}
