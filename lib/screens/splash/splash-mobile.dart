import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class SplashScreenMobile extends StatefulWidget {
  final bool isAuthenticating;
  const SplashScreenMobile({
    super.key,
    this.isAuthenticating = false
  });

  @override
  State<SplashScreenMobile> createState() => _SplashScreenMobileState();
}

class _SplashScreenMobileState extends State<SplashScreenMobile> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  final String name = 'assets/logos/logus.png';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _topAlignmentAnimation = Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight).animate(_controller);
    _bottomAlignmentAnimation = Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.bottomRight).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.whiteLigthColor, AppColors.grey50],
                begin: _topAlignmentAnimation.value,
                end: _bottomAlignmentAnimation.value,
              ),
            ),
            child: Stack(
              children: [
                /////////////////////////////////////////////////////
                Center(
                    child: Image.asset(
                      name,
                      width: 80, 
                      height: 80,
                    ),
                  ),
                /////////////////////////////////////////////////////
                /* Positioned(
                  left: 10,
                  right: 10,
                  top: 340,
                  child: Center(
                    child: GradientText(
                      text: 'medident',
                      colors: [
                        AppColors.primary,
                        AppColors.tealLightColor,
                        AppColors.primary
                      ],
                      style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ), */
                /////////////////////////////////////////////////////
                Positioned(
                  left: 10, right: 10, bottom: 20,
                  child: Center(
                    child: Text(
                      'Medident es la Multiplataforma Odontológica de Montería',
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 12,

                      ),
                    ),
                  ),
                ),
                if (widget.isAuthenticating)
                  Positioned(
                    bottom: 60, left: 0, right: 0,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.primaryDark),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
