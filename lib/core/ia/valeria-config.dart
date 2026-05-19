class ValeriaConfig {
  /// URL de la Cloud Function de Valeria con Gemini (deprecated)
  static const String? classifyUrl = null;

  /// API Key de xAI Grok (https://console.x.ai)
  /// ⚠️ No subas este archivo a git con la key expuesta
  static const String? grokApiKey = null;

  /// Modelo de Grok a usar
  static const String grokModel = 'grok-2-latest';

  /// Endpoint de Grok API
  static const String grokEndpoint = 'https://api.x.ai/v1/chat/completions';

  /// Timeout en milisegundos para la petición HTTP
  static const int timeoutMs = 15000;

  /// Si debe usar el motor local como fallback cuando no hay conexión
  static const bool useLocalFallback = true;

  /// Contexto del sistema para Grok
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
