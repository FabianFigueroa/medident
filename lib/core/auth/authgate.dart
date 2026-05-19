import 'package:flutter/material.dart';
import 'package:medident/core/enums/user-authgate.dart';
import 'package:medident/core/models/roles/user_role.dart';
import 'package:medident/core/providers/authgate/authenticate-provider.dart';
import 'package:medident/core/providers/authgate/authgate-provider.dart';
import 'package:medident/core/providers/dentist/dentist-main-provider.dart';
import 'package:medident/core/providers/admin/admin-main-provider.dart';
import 'package:medident/core/providers/employee/employee-main-provider.dart';
import 'package:medident/core/providers/onboarding/onboarding-video-provider.dart';
import 'package:medident/core/utils/app-logger.dart';
import 'package:medident/core/utils/app-navigation.dart';
import 'package:medident/core/utils/screen-trace.dart';
import 'package:medident/screens/login/signin/signin-screen.dart';
import 'package:medident/screens/onboarding/onboarding-screen.dart';
import 'package:medident/screens/splash/splash-screen.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Selector para que el AuthGate SOLO se reconstruya si cambia el STATUS
    return Selector<AuthGateProvider, AuthGateStatus>(
      selector: (_, prov) => prov.status,
      builder: (context, status, _) {
        
        switch (status) {
          
          //////////////////////////////////////////////////////////// 1. PRIMERA VEZ: Onboarding (Vídeo/Guía)
          case AuthGateStatus.onboarding:
            return ChangeNotifierProvider(
              create: (_) => OnboardingVideoProvider(),
              child: const OnboardingScreen(),
            );
          ////////////////////////////////////////////////////////////// 2. EL PUENTE: Siempre que la app abre o carga sesión
          case AuthGateStatus.loadingSplash || AuthGateStatus.uninitialized:
            return const SplashScreen(isAuthenticating: true);
          ////////////////////////////////////////////////////////////// 3. NO HAY SESIÓN: Al login de una
          case AuthGateStatus.unauthenticated:
            final error = context.read<AuthGateProvider>().errorMessage;
            return error == null  ? const SigninScreen() : ErrorAuthLayout(message: error);

          ////////////////////////////////////////////////////////////// 4. ÉXITO: El usuario entró, ahora decidimos qué Provider darle
          case AuthGateStatus.authenticated:
            return _buildRoleBasedNavigation(context);
        }
      },
    );
  }

  // Lógica de navegación por Rol (Separada para limpieza)
  Widget _buildRoleBasedNavigation(BuildContext context) {
    final user = context.read<AuthenticateProvider>().user;

    if (user == null) return const SplashScreen(isAuthenticating: true);

    ////////////////////////////////////////////////////////// Si es DENTISTA, le entregamos su MainProvider
    if (user.role == UserRole.dentist) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DentistMainProvider(user.uid)),
        ],
        child: _NavigationWrapper(role: user.role),
      );
    }

    ////////////////////////////////////////////////////////// Si es ADMIN, le entregamos su AdminMainProvider
    if (user.role == UserRole.admin) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AdminMainProvider(user.uid)),
        ],
        child: _NavigationWrapper(role: user.role),
      );
    }

    ////////////////////////////////////////////////////////// Si es EMPLOYEE, le entregamos su EmployeeMainProvider
    if (user.role == UserRole.employee) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => EmployeeMainProvider(user.uid)),
        ],
        child: _NavigationWrapper(role: user.role),
      );
    }

    // Para los demás roles (doctor, patient, delivery) sin MainProvider propio
    return ScreenTrace(
                tag: 'AUTH_GATE',
                message: 'Usuario autenticado con rol ${AppLogger.roleName(user.role)}. Entrando a la navegacion principal.',
                role: AppLogger.roleName(user.role),
                child: NavigationsScreen(role: user.role),
              );
  }

  Widget _NavigationWrapper({required UserRole role}) {
    return Builder(
      builder: (context) {
        return NavigationsScreen(role: role);
      },
    );
  }
}



class ErrorAuthLayout extends StatelessWidget {
  final String message;
  const ErrorAuthLayout({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                '¡Ups! Algo salió mal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                // Esto reinicia el estado para reintentar
                onPressed: () => context.read<AuthGateProvider>().checkAuthStatus(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
