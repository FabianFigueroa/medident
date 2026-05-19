import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/main_export.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterProvider(context.read<FirebaseServices>()),
      child: const _RegisterPageView(),
    );
  }
}

class _RegisterPageView extends StatelessWidget {
  const _RegisterPageView();

  @override
  Widget build(BuildContext context) {
    final TrackingScrollController trackingScrollController = TrackingScrollController();
    return ScreenTrace(
      tag: 'SIGNUP_SCREEN',
      message: 'Pantalla de registro cargada. Preparando formulario de creacion de cuenta.',
      role: 'guest',
      child: ResponsiveUtils(
      mobile: SignupMobile(trackingScrollController: trackingScrollController),
      tablet: SignupTablet(trackingScrollController: trackingScrollController),
      desktop: SignupDesktop(trackingScrollController: trackingScrollController),
    ),
    );
  }
}
