import 'package:flutter_test/flutter_test.dart';
import 'package:medident/core/ia/valeria-engine.dart';

void main() {
  group('ValeriaEngine', () {
    test('classify returns correct intent for greetings', () {
      final engine = ValeriaEngine();
      engine.train([
        const IntentPattern('saludo', ['hola', 'buenos dias', 'hola valeria']),
        const IntentPattern('despedida', ['adios', 'chao', 'hasta luego']),
      ]);

      final result = engine.classify('hola valeria');
      expect(result.intent, equals('saludo'));
      expect(result.matched, isTrue);
      expect(result.confidence, greaterThan(0.5));
    });

    test('classify returns default for unknown input', () {
      final engine = ValeriaEngine();
      engine.train([
        const IntentPattern('saludo', ['hola', 'buenos dias']),
      ]);

      final result = engine.classify('xyz unknown text');
      expect(result.matched, isFalse);
      expect(result.intent, isNull);
    });

    test('classify is case insensitive', () {
      final engine = ValeriaEngine();
      engine.train([
        const IntentPattern('saludo', ['hola', 'buenos dias']),
      ]);

      final result = engine.classify('HOLA');
      expect(result.intent, equals('saludo'));
      expect(result.matched, isTrue);
    });
  });
}
