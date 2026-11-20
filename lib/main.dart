import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medident/core/providers/network/network-provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:medident/firebase_options.dart';
import 'package:medident/main_export.dart';
import 'package:medident/screens/splash/splash-screen.dart';
import 'package:medident/core/data/firebase_seeder.dart';
import 'package:medident/core/utils/startup-profiler.dart';

/// Arranque rápido (patrón validado en tenderos):
///  - `runApp` NO espera a Firebase: el splash de Flutter se pinta de inmediato
///    y Firebase inicializa detrás (FutureBuilder).
///  - Configuración/persistencia y FCM se aplican después de inicializar, sin
///    bloquear el primer frame.
///  - El seeder de datos demo ya NO bloquea el arranque (solo debug y diferido).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StartupProfiler.instance.mark('main() arranque');
  

  final firebaseFuture = AppInitializer.initializeFirebaseWithRetry().then((app) async {
    // Persistencia (web: Auth LOCAL). Firestore se configura en FirebaseServices
    // antes de cualquier query.
    await AppInitializer.configurePersistence(app);
    StartupProfiler.instance.mark('Firebase listo');
    // FCM best-effort: NotificationService.init() ya difiere 1s internamente.
    NotificationService.init();
    return app;
  });

  // Datos demo: diferido, nunca en el camino crítico del arranque (el usuario
  // compila release, por lo que el gate por kDebugMode lo volvería inerte).
  unawaited(Future<void>.delayed(const Duration(seconds: 10), () async {
    try {
      await FirebaseSeeder.seedOnce();
    } catch (_) {}
  }));

  runApp(MyApp(firebaseFuture: firebaseFuture));
}

class MyApp extends StatefulWidget {
  final Future<FirebaseApp> firebaseFuture;
  const MyApp({super.key, required this.firebaseFuture});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Se construyen UNA sola vez, cuando Firebase ya está listo (evita tocar
  /// `FirebaseAuth.instance` antes de `initializeApp`).
  List<SingleChildWidget>? _firebaseProviders;

  List<SingleChildWidget> _buildFirebaseProviders() => [
        Provider(create: (_) => FirebaseServices()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => ValeriaProvider()),
        ChangeNotifierProxyProvider<User?, AuthenticateProvider>(
          create: (context) => AuthenticateProvider(
            context.read<FirebaseServices>(),
          ),
          update: (context, firebaseUser, authProvider) {
            final provider = authProvider ??
                AuthenticateProvider(context.read<FirebaseServices>());
            if (firebaseUser != null && provider.shouldListenTo(firebaseUser.uid)) {
              provider.listenToUser(firebaseUser.uid);
            }
            return provider;
          },
        ),
        ChangeNotifierProxyProvider2<FirebaseServices, AuthenticateProvider,
            AuthGateProvider>(
          create: (context) => AuthGateProvider(
            context.read<FirebaseServices>(),
            context.read<AuthenticateProvider>(),
          ),
          update: (context, firebaseServices, authProvider, previousProvider) {
            return previousProvider ??
                AuthGateProvider(firebaseServices, authProvider);
          },
        ),
        ChangeNotifierProvider(
          create: (context) => SigninProvider(
            context.read<FirebaseServices>(),
          ),
        ),
      ];

  Widget _materialApp({required Widget home}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medident',
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
        Locale('en', ''),
      ],
      locale: const Locale('es'),
      builder: (context, child) {
        return Stack(
          children: [
            Network_Utils(child: child!),
            const NetworkBanner_Utils(),
          ],
        );
      },
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
        },
      ),
      home: home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    StartupProfiler.instance.scheduleFirstFrame();
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NetworkProvider())],
      child: FutureBuilder<FirebaseApp>(
        future: widget.firebaseFuture,
        builder: (context, snapshot) {
          final ready = snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData;
          if (!ready) {
            return _materialApp(
              home: const SplashScreen(isAuthenticating: true),
            );
          }
          StartupProfiler.instance.markOnce('providers listos');
          _firebaseProviders ??= _buildFirebaseProviders();
          return MultiProvider(
            providers: _firebaseProviders!,
            child: _materialApp(home: const AuthGate()),
          );
        },
      ),
    );
  }
}
