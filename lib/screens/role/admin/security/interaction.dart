// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  INTERACTION GUIDE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

// ignore: unused_element
import 'package:flutter/material.dart';

import '../../../../main_export.dart';

class InteractionGuideWidget extends StatelessWidget {
  const InteractionGuideWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E8F0)),
      ),
      child: const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _GuidePill(
              icon: Icons.touch_app_rounded,
              title: 'Tap habitacion',
              text: 'Instalar o editar'),
          _GuidePill(
              icon: Icons.crop_16_9_rounded,
              title: 'Tap pared',
              text: 'Instalar sobre muro'),
          _GuidePill(
              icon: Icons.pan_tool_alt_rounded,
              title: 'Long-press',
              text: 'Mover habitacion'),
          _GuidePill(
              icon: Icons.open_with_rounded,
              title: 'Esquinas',
              text: 'Redimensionar'),
        ],
      ),
    );
  }
}


class _GuidePill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _GuidePill(
      {required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EAEE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF3A7AFE)),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 10, fontFamily: 'Ubuntu-Bold')),
                Text(text,
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.grey600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
