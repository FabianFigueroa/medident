import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medident/main.dart';
import 'package:medident/screens/splash/splash-screen.dart';

Future<void> _pumpApp(WidgetTester tester, Completer<FirebaseApp> completer) async {
  await tester.pumpWidget(MyApp(firebaseFuture: completer.future));
  // Deja correr los timers de arranque del NetworkProvider.
  await tester.pump(const Duration(milliseconds: 10));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (call) async => <String>['wifi'],
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
      (call) async => null,
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
      null,
    );
  });

  group('App()', () {
    testWidgets('muestra el splash mientras Firebase inicializa',
        (WidgetTester tester) async {
      final completer = Completer<FirebaseApp>();

      await _pumpApp(tester, completer);

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('la app se llama Medident', (WidgetTester tester) async {
      final completer = Completer<FirebaseApp>();

      await _pumpApp(tester, completer);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, 'Medident');
      expect(app.debugShowCheckedModeBanner, isFalse);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
