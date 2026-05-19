import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key, this.isAuthenticating = false});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
  final bool isAuthenticating;
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    // final videoProvider = Provider.of<OnboardingVideoProvider>(context);
    return ScreenTrace(
      tag: 'SPLASH_SCREEN',
      message: widget.isAuthenticating
          ? 'Splash en modo autenticacion. Esperando datos del usuario.'
          : 'Splash general cargado. Preparando recursos iniciales.',
      role: 'guest',
      child: Scaffold(
      backgroundColor: Colors.white, // white to change
      body:ResponsiveUtils(
        mobile: SplashScreenMobile(isAuthenticating: widget.isAuthenticating),
        tablet: SplashScreenMobile(isAuthenticating: widget.isAuthenticating),
        desktop: SplashScreenMobile(isAuthenticating: widget.isAuthenticating),
      ),
    ),
    );
  }
}
