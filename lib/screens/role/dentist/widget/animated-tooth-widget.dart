import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medident/core/models/odontogram-constants.dart';

class AnimatedToothWidget extends StatefulWidget {
  final ToothData tooth;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedToothWidget({
    super.key,
    required this.tooth,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AnimatedToothWidget> createState() => _AnimatedToothWidgetState();
}

class _AnimatedToothWidgetState extends State<AnimatedToothWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedToothWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUpper = isUpperTooth(widget.tooth.number);
    final isMissing = widget.tooth.state == ToothState.missing;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSelected ? _pulseAnimation.value : 1.0,
            child: child,
          );
        },
        child: SizedBox(
          width: 42,
          height: 50,
          child: isMissing
              ? _buildMissingTooth()
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildToothBase(isUpper),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _buildStateLayer(widget.tooth.state, isUpper),
                    ),
                    if (widget.isSelected)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.check, size: 8, color: Colors.white),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildToothBase(bool isUpper) {
    final svgString = isUpper ? _upperToothSvg : _lowerToothSvg;
    return SvgPicture.string(
      svgString,
      width: 42,
      height: 50,
      fit: BoxFit.contain,
    );
  }

  Widget _buildMissingTooth() {
    return SvgPicture.string(
      _missingToothSvg,
      width: 42,
      height: 50,
      fit: BoxFit.contain,
    );
  }

  Widget _buildStateLayer(ToothState state, bool isUpper) {
    switch (state) {
      case ToothState.healthy:
        return SvgPicture.string(
          _healthyOverlaySvg,
          width: 42,
          height: 50,
          fit: BoxFit.contain,
        );
      case ToothState.caries:
        return SvgPicture.string(
          _cariesOverlaySvg,
          width: 42,
          height: 50,
          fit: BoxFit.contain,
        );
      case ToothState.filled:
        return SvgPicture.string(
          _filledOverlaySvg,
          width: 42,
          height: 50,
          fit: BoxFit.contain,
        );
      case ToothState.rootCanal:
        return SvgPicture.string(
          _rootCanalOverlaySvg,
          width: 42,
          height: 50,
          fit: BoxFit.contain,
        );
      case ToothState.crown:
        return SvgPicture.string(
          _crownOverlaySvg,
          width: 42,
          height: 50,
          fit: BoxFit.contain,
        );
      case ToothState.implant:
        return SvgPicture.string(
          _implantOverlaySvg,
          width: 42,
          height: 50,
          fit: BoxFit.contain,
        );
      case ToothState.fracture:
        return SvgPicture.string(
          _fractureOverlaySvg,
          width: 42,
          height: 50,
          fit: BoxFit.contain,
        );
      case ToothState.sealant:
        return SvgPicture.string(
          _sealantOverlaySvg,
          width: 42,
          height: 50,
          fit: BoxFit.contain,
        );
      case ToothState.missing:
        return const SizedBox.shrink();
    }
  }
}

const _upperToothSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 42 50">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0%" stop-color="#FFFFFF"/><stop offset="100%" stop-color="#F5F5F5"/>
  </linearGradient></defs>
  <path d="M5,46 L5,22 C5,8 13,2 21,4 C29,2 37,8 37,22 L37,46 C37,48 35,50 32,50 L10,50 C7,50 5,48 5,46 Z"
        fill="url(#g)" stroke="#BDBDBD" stroke-width="1.5" stroke-linejoin="round"/>
  <path d="M14,22 Q18,18 21,20 Q24,18 28,22" fill="none" stroke="#D0D0D0" stroke-width="1.2" stroke-linecap="round"/>
  <path d="M8,28 Q21,24 34,28" fill="none" stroke="#D6D6D6" stroke-width="1" stroke-linecap="round"/>
  <line x1="9" y1="38" x2="33" y2="38" stroke="#E8E8E8" stroke-width="0.8" stroke-linecap="round"/>
  <line x1="10" y1="42" x2="32" y2="42" stroke="#E8E8E8" stroke-width="0.8" stroke-linecap="round"/>
</svg>''';

const _lowerToothSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 42 50">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0%" stop-color="#FFFFFF"/><stop offset="100%" stop-color="#F5F5F5"/>
  </linearGradient></defs>
  <path d="M5,4 L5,28 C5,42 13,48 21,46 C29,48 37,42 37,28 L37,4 C37,2 35,0 32,0 L10,0 C7,0 5,2 5,4 Z"
        fill="url(#g)" stroke="#BDBDBD" stroke-width="1.5" stroke-linejoin="round"/>
  <path d="M14,28 Q18,32 21,30 Q24,32 28,28" fill="none" stroke="#D0D0D0" stroke-width="1.2" stroke-linecap="round"/>
  <path d="M8,22 Q21,26 34,22" fill="none" stroke="#D6D6D6" stroke-width="1" stroke-linecap="round"/>
  <line x1="9" y1="12" x2="33" y2="12" stroke="#E8E8E8" stroke-width="0.8" stroke-linecap="round"/>
  <line x1="10" y1="8" x2="32" y2="8" stroke="#E8E8E8" stroke-width="0.8" stroke-linecap="round"/>
</svg>''';

const _missingToothSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 42 50">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0%" stop-color="#EEEEEE"/><stop offset="100%" stop-color="#E0E0E0"/>
  </linearGradient></defs>
  <path d="M5,46 L5,22 C5,8 13,2 21,4 C29,2 37,8 37,22 L37,46 C37,48 35,50 32,50 L10,50 C7,50 5,48 5,46 Z"
        fill="url(#g)" stroke="#B0B0B0" stroke-width="1.5" stroke-linejoin="round"/>
  <line x1="10" y1="10" x2="32" y2="40" stroke="#B0B0B0" stroke-width="2.5" stroke-linecap="round"/>
  <line x1="32" y1="10" x2="10" y2="40" stroke="#B0B0B0" stroke-width="2.5" stroke-linecap="round"/>
</svg>''';

const _healthyOverlaySvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 42 50">
  <path d="M5,46 L5,22 C5,8 13,2 21,4 C29,2 37,8 37,22 L37,46 C37,48 35,50 32,50 L10,50 C7,50 5,48 5,46 Z"
        fill="#4CAF50" opacity="0.12"/>
</svg>''';

const _cariesOverlaySvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 42 50">
  <ellipse cx="21" cy="34" rx="12" ry="10" fill="#E53935" opacity="0.45"/>
  <ellipse cx="28" cy="30" rx="5" ry="4" fill="#C62828" opacity="0.5"/>
  <ellipse cx="15" cy="38" rx="4" ry="3" fill="#C62828" opacity="0.4"/>
</svg>''';

const _filledOverlaySvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 42 50">
  <ellipse cx="21" cy="36" rx="11" ry="9" fill="#1E88E5" opacity="0.4"/>
  <rect x="14" y="30" width="14" height="12" rx="4" fill="#1565C0" opacity="0.3"/>
</svg>''';

const _rootCanalOverlaySvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 42 50">
  <line x1="21" y1="8" x2="21" y2="44" stroke="#8E24AA" stroke-width="3" stroke-linecap="round" opacity="0.7"/>
  <circle cx="21" cy="36" r="5" fill="#8E24AA" opacity="0.8"/>
  <line x1="18" y1="36" x2="24" y2="36" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="21" y1="33" x2="21" y2="39" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
</svg>''';

const _crownOverlaySvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 42 50">
  <path d="M5,46 L5,26 C5,20 37,20 37,26 L37,46 C37,48 35,50 32,50 L10,50 C7,50 5,48 5,46 Z"
        fill="#F9A825" opacity="0.5" stroke="#F57F17" stroke-width="1"/>
  <path d="M8,28 L34,28" stroke="#F57F17" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="12" y1="34" x2="30" y2="34" stroke="#F57F17" stroke-width="0.8" stroke-linecap="round" opacity="0.5"/>
</svg>''';

const _implantOverlaySvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 42 50">
  <line x1="21" y1="4" x2="21" y2="46" stroke="#00ACC1" stroke-width="4" stroke-linecap="round" opacity="0.7"/>
  <rect x="16" y="8" width="10" height="14" rx="2" fill="#00ACC1" opacity="0.5"/>
  <circle cx="21" cy="4" r="4" fill="#00838F" opacity="0.8"/>
</svg>''';

const _fractureOverlaySvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 42 50">
  <path d="M12,12 L18,22 L15,26 L22,36 L19,40 L28,48" stroke="#FF6F00" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" fill="none" opacity="0.8"/>
  <path d="M30,14 L26,22 L29,26 L24,34" stroke="#E65100" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none" opacity="0.5"/>
</svg>''';

const _sealantOverlaySvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 42 50">
  <path d="M5,46 L5,30 Q21,24 37,30 L37,46 C37,48 35,50 32,50 L10,50 C7,50 5,48 5,46 Z"
        fill="#43A047" opacity="0.2"/>
  <path d="M8,32 Q21,26 34,32" stroke="#43A047" stroke-width="2" stroke-linecap="round" fill="none" opacity="0.5"/>
</svg>''';
