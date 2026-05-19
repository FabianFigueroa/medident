import 'package:flutter/material.dart';
import 'package:medident/core/models/media-item.dart';
import 'package:medident/screens/widgets/media/media_viewer.dart';

/// Múltiples items de media con layout inteligente según cantidad y tipos.
class MediaGrid extends StatelessWidget {
  final List<MediaItem> items;
  final double borderRadius;
  final double spacing;
  final void Function(MediaItem item, int index)? onItemTap;

  const MediaGrid({
    super.key,
    required this.items,
    this.borderRadius = 8,
    this.spacing = 6,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    if (items.length == 1) return _buildSingle(items.first);
    if (items.length == 2) return _buildPair();
    if (items.length == 3) return _buildTriple();
    return _buildGrid();
  }

  Widget _buildSingle(MediaItem item) {
    return SizedBox(
      width: double.infinity,
      child: MediaViewer(
        media: item,
        height: 240,
        borderRadius: borderRadius,
        onTap: () => onItemTap?.call(item, 0),
      ),
    );
  }

  Widget _buildPair() {
    return Row(children: [
      Expanded(child: MediaViewer(media: items[0], height: 200, borderRadius: borderRadius, onTap: () => onItemTap?.call(items[0], 0))),
      SizedBox(width: spacing),
      Expanded(child: MediaViewer(media: items[1], height: 200, borderRadius: borderRadius, onTap: () => onItemTap?.call(items[1], 1))),
    ]);
  }

  Widget _buildTriple() {
    return Column(children: [
      MediaViewer(media: items[0], height: 180, borderRadius: borderRadius, onTap: () => onItemTap?.call(items[0], 0)),
      SizedBox(height: spacing),
      Row(children: [
        Expanded(child: MediaViewer(media: items[1], height: 140, borderRadius: borderRadius, onTap: () => onItemTap?.call(items[1], 1))),
        SizedBox(width: spacing),
        Expanded(child: MediaViewer(media: items[2], height: 140, borderRadius: borderRadius, onTap: () => onItemTap?.call(items[2], 2))),
      ]),
    ]);
  }

  Widget _buildGrid() {
    final gridItems = items.take(4).toList();
    final remaining = items.length - 4;

    return Column(children: [
      Row(children: [
        Expanded(child: MediaViewer(media: gridItems[0], height: 160, borderRadius: borderRadius, onTap: () => onItemTap?.call(gridItems[0], 0))),
        SizedBox(width: spacing),
        Expanded(child: MediaViewer(media: gridItems[1], height: 160, borderRadius: borderRadius, onTap: () => onItemTap?.call(gridItems[1], 1))),
      ]),
      SizedBox(height: spacing),
      Row(children: [
        Expanded(child: Stack(children: [
          MediaViewer(media: gridItems[2], height: 160, borderRadius: borderRadius, onTap: () => onItemTap?.call(gridItems[2], 2)),
          if (remaining > 0)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => onItemTap?.call(gridItems[2], 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Center(child: Text('+$remaining', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
                ),
              ),
            ),
        ])),
        SizedBox(width: spacing),
        Expanded(child: MediaViewer(media: gridItems[3], height: 160, borderRadius: borderRadius, onTap: () => onItemTap?.call(gridItems[3], 3))),
      ]),
    ]);
  }
}
