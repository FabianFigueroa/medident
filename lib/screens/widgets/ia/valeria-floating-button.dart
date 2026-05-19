import 'package:flutter/material.dart';
import 'package:medident/screens/widgets/ia/valeria-rive-avatar.dart';

class ValeriaFloatingButton extends StatefulWidget {
  final bool isSleeping;
  final VoidCallback onTap;
  final int unreadCount;

  const ValeriaFloatingButton({
    super.key,
    this.isSleeping = false,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  State<ValeriaFloatingButton> createState() => _ValeriaFloatingButtonState();
}

class _ValeriaFloatingButtonState extends State<ValeriaFloatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final glow = widget.isSleeping ? 0.0 : 0.3 + _ctrl.value * 0.2;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withValues(alpha: glow),
                    blurRadius: 12 + _ctrl.value * 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: 'valeria_fab',
                backgroundColor: widget.isSleeping
                    ? Colors.grey.shade400
                    : const Color(0xFF1565C0),
                elevation: 4,
                onPressed: widget.onTap,
                child: widget.isSleeping
                    ? const Icon(Icons.nightlight_round, color: Colors.white)
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: ValeriaRiveAvatar(
                          size: 44,
                          expression: ValeriaRiveExpression.happy,
                        ),
                      ),
              ),
            ),
            if (widget.unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${widget.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
