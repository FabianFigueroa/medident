import 'package:flutter/material.dart';
import 'package:medident/screens/role/dentist/profile/dentist-profile-screen.dart';
import 'package:medident/screens/role/dentist/clinic/clinic-edit-screen.dart';

class NavigationService {
  static Route<dynamic> standard(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }

  static Route<dynamic> fade(Widget page, {int duration = 300}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: duration),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Route<dynamic> slide(Widget page, {int duration = 300}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: duration),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static Route<dynamic> scale(Widget page, {int duration = 300}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: duration),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
    );
  }
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/profile':
      case '/dentist/profile':
        return MaterialPageRoute(builder: (_) => const DentistProfileScreen());
      case '/clinic/edit':
        return MaterialPageRoute(builder: (_) => const ClinicEditScreen());
      default:
        return null;
    }
  }
}
