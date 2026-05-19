// ══════════════════════════════════════════════════════════════
//  HEADER
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:medident/screens/role/admin/security/header-chip-windget.dart';

import '../../../../main_export.dart';

class BuilderHeaderWidget extends StatelessWidget {
  final int floors;
  final int totalPoints;
  final bool canUndo;
  final VoidCallback onUndo;

  const BuilderHeaderWidget({
    required this.floors,
    required this.totalPoints,
    required this.canUndo,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Constructor de Clinica Segura',
                  style: TextStyle(fontSize: 34, fontFamily: 'Ubuntu-Bold')),
              SizedBox(height: 6),
              Text(
                'Configura el diseño de cada piso y proyecta puntos de seguridad sobre el croquis interactivo.',
                style: TextStyle(
                    fontSize: 14, color: AppColors.grey600, height: 1.5),
              ),
            ],
          ),
        ),
        if (canUndo)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.outlined(
              onPressed: onUndo,
              icon: const Icon(Icons.undo_rounded, size: 20),
              tooltip: 'Deshacer',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        HeaderChipWidget(label: '$floors pisos', icon: Icons.layers_rounded),
        const SizedBox(width: 10),
        HeaderChipWidget(
            label: '$totalPoints puntos', icon: Icons.place_rounded),
      ],
    );
  }
}
