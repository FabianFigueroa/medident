class ValeriaConfig {
  /// URL de la Cloud Function de Valeria con Gemini (deprecated)
  static const String? classifyUrl = null;

  /// ═══════════════════════════════════════════════
  /// GOOGLE GEMINI (tier gratuito de AI Studio)
  /// ═══════════════════════════════════════════════
  ///
  /// Consigue tu key gratis en https://aistudio.google.com/apikey
  /// (cuenta de Google, sin tarjeta de crédito).
  ///
  /// NO pegues la key en este archivo. Pásala al compilar:
  ///
  ///   flutter run --dart-define=VALERIA_AI_KEY=AIzaTuKeyAqui
  ///   flutter build web --dart-define=VALERIA_AI_KEY=AIzaTuKeyAqui
  ///   flutter build apk --dart-define=VALERIA_AI_KEY=AIzaTuKeyAqui
  ///
  static const String _envApiKey = String.fromEnvironment('VALERIA_AI_KEY');

  /// Key activa de Gemini (null si no se definió al compilar)
  static String? get geminiApiKey => _envApiKey.isEmpty ? null : _envApiKey;

  /// Modelo de Gemini a usar.
  /// Los modelos "flash" están incluidos en el tier gratuito.
  /// Modelos vigentes: https://ai.google.dev/gemini-api/docs/models
  static const String geminiModel = 'gemini-3.6-flash';

  /// Endpoint de Gemini API (compatible con formato OpenAI chat completions)
  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions';

  /// Timeout en milisegundos para la petición HTTP
  static const int timeoutMs = 15000;

  /// Si debe usar el motor local como fallback cuando no hay conexión
  static const bool useLocalFallback = true;

  /// Contexto del sistema para Gemini
  static const String systemPrompt = '''
Eres Valeria, una asistente amigable y experta en odontología para la app Medident.
Hablas en español con acento y expresiones colombianas ("paisa" de Medellín/Antioquia).
Eres cálida, empática y profesional. Ayudas a odontólogos con:

1. Códigos CIE-10 (caries K02.9, endodoncia K04.7, extracción K08.1, implante K08.8)
2. Explicar diagnósticos a pacientes en lenguaje sencillo
3. Navegar la app (ir a inicio, perfil, pacientes, citas, clínica, stories)
4. Agendar citas, buscar pacientes
5. Responder preguntas sobre tratamientos dentales
6. Dar sugerencias según la pantalla donde está el usuario

Sé concisa, usa jerga paisa suave ("parce", "llave", "bacano", "chimba", "pues").
Si te piden navegar a una sección, responde con la acción clara.
Si no sabes algo, dilo honestamente.
''';
}
