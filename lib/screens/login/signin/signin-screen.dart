import 'package:flutter/material.dart';
import 'package:medident/core/providers/login/signin/signin-provider.dart';
import 'package:medident/core/services/firebase/firebase-services.dart';
import 'package:medident/core/utils/responsive.dart';
import 'package:medident/core/utils/screen-trace.dart';
import 'package:medident/screens/login/signin/signin-desktop.dart';
import 'package:medident/screens/login/signin/signin-mobile.dart';
import 'package:medident/screens/login/signin/signin-tablet.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SigninScreen extends StatelessWidget {
  final String? initialEmail;

  const SigninScreen({super.key, this.initialEmail});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SigninProvider(
        context.read<FirebaseServices>(),
        initialEmail: initialEmail,
      ),
      child: const _LoginPageView(),
    );
  }
}

class _LoginPageView extends StatelessWidget {
  const _LoginPageView();

  @override
  Widget build(BuildContext context) {
    final trackingScrollController = TrackingScrollController();
    return Scaffold(
      body: ResponsiveUtils(
        mobile: Signin_Mobile(trackingScrollController: trackingScrollController),
        tablet: Signin_Tablet(trackingScrollController: trackingScrollController),
        desktop: Signin_Desktop.Signin_Desktop(trackingScrollController: trackingScrollController),
      ),
    );
  }
}
