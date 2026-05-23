import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medident/core/providers/network/network-provider.dart';
import 'package:provider/provider.dart';
import 'package:medident/firebase_options.dart';
import 'package:medident/main_export.dart';
import 'package:medident/core/data/firebase_seeder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseApp app = await AppInitializer.initializeFirebaseWithRetry();
  await AppInitializer.configurePersistence(app);
  await FirebaseSeeder.seedOnce();

  NotificationService.init();

  runApp(MyApp(app: app));
}

class MyApp extends StatelessWidget {
  final FirebaseApp app;
  const MyApp({super.key, required this.app});
  
  @override   
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => FirebaseServices()),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => ValeriaProvider()),
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProxyProvider<User?, AuthenticateProvider>(
          create: (context) => AuthenticateProvider(
            context.read<FirebaseServices>(),
          ),
          update: (context, firebaseUser, authProvider) {
            final provider = authProvider ?? AuthenticateProvider(
              context.read<FirebaseServices>(),
            );
            if (firebaseUser != null && provider.shouldListenTo(firebaseUser.uid)) {
              provider.listenToUser(firebaseUser.uid);
            }
            return provider;
          },
        ),
        ChangeNotifierProxyProvider2<FirebaseServices, AuthenticateProvider, AuthGateProvider>(
          create: (context) => AuthGateProvider(
            context.read<FirebaseServices>(),
            context.read<AuthenticateProvider>(),
          ),
          update: (context, firebaseServices, authProvider, previousProvider) {
            return previousProvider ?? AuthGateProvider(firebaseServices, authProvider);
          },
        ),
        ChangeNotifierProvider(
          create: (context) => SigninProvider(
            context.read<FirebaseServices>(),
          ),
        ),
        
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Medient',
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
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus},
        ),
        home: const AuthGate(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
