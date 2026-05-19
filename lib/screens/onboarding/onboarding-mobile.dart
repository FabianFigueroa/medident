import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:medident/main_export.dart';

class OnboardingMobile extends StatefulWidget {
  const OnboardingMobile({super.key});

  @override
  State<OnboardingMobile> createState() => _OnboardingMobileState();
}

class _OnboardingMobileState extends State<OnboardingMobile> {
  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      Provider.of<OnboardingVideoProvider>(context, listen: false).initializeVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<OnboardingVideoProvider>(context);
    final videoController = videoProvider.controller;
    final onboardingProvider =
    Provider.of<OnboardingProvider>(context, listen: false);

    final Widget staticContent = Stack(
      children: <Widget>[
        Positioned(
          left: 10,
          right: 6,
          top: 80,
          child: Image.asset(
            'assets/logos/logus.png',
            height: 60,
            width: 60,
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          top: 135,
          child: Center(
            child: Text(
              'I.P.S. Medident',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Oswald',
                fontSize: 40,
                color: AppColors.whiteLigthColor,
              ),
            ),
          ),
        ),
        PageView.builder(
          controller: onboardingProvider.pageController,
          onPageChanged: onboardingProvider.onPageChanged,
          itemCount: onboardingDatabase.length,
          itemBuilder: (context, index) {
            return OnboardingContentCard(
              key: ValueKey(index),
              item: onboardingDatabase[index],
            );
          },
        ),
        Positioned(
          bottom: 10,
          left: 15,
          right: 15,
          child: Consumer<OnboardingProvider>(
            builder: (context, provider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Opacity(
                    opacity: provider.pageIndex > 0 ? 1.0 : 0.0,
                    child: TextButton(
                      onPressed:
                      provider.pageIndex > 0 ? provider.previousPage : null,
                      child: const Text('Atrás',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Expanded(
                    child: DotsIndicator(
                      dotsCount: onboardingDatabase.length,
                      position: provider.pageIndex,
                    ),
                  ),
                  TextButton(
                    child: Text(
                      provider.pageIndex == onboardingDatabase.length - 1
                          ? 'Empezar'
                          : 'Siguiente',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (provider.pageIndex == onboardingDatabase.length - 1) {
                        provider.completeOnboarding(context);
                      } else {
                        provider.nextPage();
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: <Widget>[
          // Fondo dinámico
          if (videoProvider.hasError)
          // Fallback: Entrada con un degradado si el video falla
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background,
                    AppColors.primary.withOpacity(0.8)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            )
          else if (videoProvider.isInitialized && videoController != null)
          // Muestra el video si está listo
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: videoController.value.size.width,
                  height: videoController.value.size.height,
                  child: VideoPlayer(videoController),
                ),
              ),
            )
          else if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)
             Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background,
                    AppColors.primary.withOpacity(0.8)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            )
          else
          // Muestra un indicador de carga mientras el video se inicializa
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),

          // Contenido principal (siempre visible si hay error o no es plataforma móvil)
          if (videoProvider.isInitialized || videoProvider.hasError || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS))
            staticContent,
        ],
      ),
    );
  }
}
