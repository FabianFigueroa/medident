import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medident/main_export.dart';

class OnboardingContentCard extends StatefulWidget {
  const OnboardingContentCard({
    super.key,
    required this.item,
  });

  final OnboardingModel item;

  @override
  State<OnboardingContentCard> createState() => _OnboardingContentCardState();
}

class _OnboardingContentCardState extends State<OnboardingContentCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // MediaQuery.of(context).size.height * 0.2
        ///////////////////////////////////////////// fade
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.fromLTRB(25, 0, 25, 5),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [

                  ////////////////////////////////////////////////// icon
                  // Image.asset(
                  //   widget.item.image,
                  //   height: 65,
                  //   width: 65,
                  //   opacity: _fadeAnimation,
                  // ),
                  SvgPicture.asset(
                    widget.item.image,
                    width: 70, // ajustar tamaño
                    height: 80,
                    //semanticsLabel: 'Logo de la app', // útil para accesibilidad
                  ),
                  /////////////////////////////
                  const SizedBox(height: 8),
                  /////////////////////////////////////////////// title
                  Text(
                    widget.item.title,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontFamily: 'Oswald',
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  /////////////////////////////
                  const SizedBox(height: 10),
                  /////////////////////////////////////////////// slogan
                  Text(
                    widget.item.slogan,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontFamily: 'Oswald',
                      fontWeight: FontWeight.bold ,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  //////////////////////////////////////////// caption
                  Text(
                    widget.item.caption,
                    style: TextStyle(
                      color: AppColors.whiteLigthColor,
                      fontSize: 12,
                      fontFamily: 'Ubuntu-Medium',
                      fontWeight: FontWeight.normal ,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),


        const SizedBox(height: 64, width: double.infinity,),
      ],
    );
  }
}
