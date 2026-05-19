import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OnboardingVideoProvider>(context, listen: false)
          .initializeVideo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<OnboardingVideoProvider>(context);

    return ScreenTrace(
      tag: 'ONBOARDING_SCREEN',
      message: videoProvider.isVideoPlaying
          ? 'Onboarding listo. Mostrando experiencia principal al usuario.'
          : 'Onboarding cargando video inicial antes de mostrar la experiencia.',
      role: 'guest',
      child: Scaffold(
      backgroundColor: Colors.white, // Cambiado a blanco
      body: videoProvider.isVideoPlaying
          ? const ResponsiveUtils(
        mobile: OnboardingMobile(),
        tablet: OnboardingMobile(),
        desktop: OnboardingMobile(),
      )
          : const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    ),
    );
  }
}
