import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medident/core/ia/ia-export.dart';
import 'package:medident/screens/widgets/ia/valeria-rive-avatar.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? intent;
  final bool isAction;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.intent,
    this.isAction = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ValeriaProvider extends ChangeNotifier {
  final ValeriaEngine _engine = ValeriaEngine();
  ValeriaRiveExpression _expression = ValeriaRiveExpression.idle;
  bool _isVisible = true;
  bool _isChatOpen = false;
  bool _isTyping = false;
  int _unreadCount = 0;
  String? _currentScreen;
  String? _currentPatient;
  String? _currentProcedure;
  String? _odontologistName;
  String _lastResponse = '';
  String? _lastMatchedIntent;
  String? _actionInProgress;

  final List<ChatMessage> _messages = [];
  final List<Map<String, dynamic>> _interactionHistory = [];
  Map<String, dynamic> _preferences = {};
  Map<String, int> _procedureFrequency = {};
  final Map<String, Function(Map<String, dynamic>)?> _tools = {};

  ValeriaProvider() {
    _loadPreferences();
  }

  ValeriaEngine get engine => _engine;
  ValeriaRiveExpression get expression => _expression;
  bool get isVisible => _isVisible;
  bool get isChatOpen => _isChatOpen;
  bool get isTyping => _isTyping;
  int get unreadCount => _unreadCount;
  String? get currentScreen => _currentScreen;
  String? get currentPatient => _currentPatient;
  String? get currentProcedure => _currentProcedure;
  String? get odontologistName => _odontologistName;
  String get lastResponse => _lastResponse;
  String? get lastMatchedIntent => _lastMatchedIntent;
  String? get actionInProgress => _actionInProgress;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  TrainingStatus get trainingStatus => checkTrainingStatus();

  void registerTool(String name, Function(Map<String, dynamic>)? callback) {
    _tools[name] = callback;
  }

  void unregisterTool(String name) {
    _tools.remove(name);
  }

  bool _engineInitialized = false;

  void _ensureEngineInitialized() {
    if (_engineInitialized) return;
    _engineInitialized = true;
    _initEngine();
  }

  void _initEngine() {
    _engine.train([
      const IntentPattern('saludo', [
        'hola', 'buenos dias', 'buenas tardes', 'buenas noches',
        'que tal', 'hey', 'holi', 'hola valeria',
      ]),
      const IntentPattern('despedida', [
        'adios', 'chao', 'bye', 'hasta luego', 'nos vemos',
        'descansa', 'voy a descansar', 'vete a dormir',
      ]),
      const IntentPattern('gracias', [
        'gracias', 'muchas gracias', 'te agradezco', 'thank you',
        'gracias valeria',
      ]),
      const IntentPattern('como_estas', [
        'como estas', 'como estas valeria', 'como vas',
        'todo bien', 'que tal estas', 'como te sientes',
      ]),
      const IntentPattern('quien_eres', [
        'quien eres', 'que eres', 'como te llamas',
        'presentate', 'cuentame de ti', 'que eres valeria',
        'quien te creo', 'quien te hizo', 'quien es tu creador',
        'quien te desarrollo', 'fabian figueroa',
      ]),
      const IntentPattern('creador', [
        'quien te creo', 'quien te hizo', 'quien es tu creador',
        'quien te desarrollo', 'quien te programo',
        'fabian figueroa', 'universidad de cordoba',
        'de donde eres', 'que proyecto eres',
      ]),
      const IntentPattern('caries', [
        'codigo caries', 'cie10 caries', 'caries codigo',
        'como clasificar caries', 'diagnostico caries', 'que codigo caries',
      ]),
      const IntentPattern('endodoncia', [
        'codigo endodoncia', 'cie10 endodoncia',
        'como codificar endodoncia', 'diagnostico endodoncia',
        'que codigo endodoncia',
      ]),
      const IntentPattern('extraccion', [
        'codigo extraccion', 'cie10 extraccion',
        'extraccion dental codigo', 'codigo para extraer',
      ]),
      const IntentPattern('implante', [
        'codigo implante', 'cie10 implante',
        'implante dental codigo', 'codigo de implante',
      ]),
      const IntentPattern('cie10', [
        'codigo cie10', 'que codigo', 'recomienda codigo',
        'codigo diagnostico', 'buscar codigo', 'ayuda codigo',
        'dame codigo', 'necesito codigo',
      ]),
      const IntentPattern('ayuda', [
        'ayuda', 'que puedes hacer', 'que sabes hacer',
        'funciones', 'capacidades', 'que haces',
        'como funciona', 'tutorial', 'ayuda valeria',
      ]),
      const IntentPattern('descansar', [
        'vete a descansar', 'vete a dormir', 'descansa valeria',
        'duermete', 'apagate', 'desactivar',
        'ponte a descansar',
      ]),
      const IntentPattern('despertar', [
        'despierta', 'valeria despierta', 'despertar',
        'activa valeria', 'vuelve valeria', 'enciende',
      ]),
      const IntentPattern('explicar_caries', [
        'explica caries paciente', 'explicar caries',
        'como explico caries', 'decir caries paciente',
      ]),
      const IntentPattern('explicar_endodoncia', [
        'explica endodoncia', 'explicar endodoncia paciente',
        'como explico endodoncia',
      ]),
      const IntentPattern('explicar_extraccion', [
        'explica extraccion', 'explicar extraccion paciente',
        'como explico extraccion',
      ]),
      const IntentPattern('procedimiento', [
        'explica procedimiento', 'como se hace',
        'en que consiste', 'describe procedimiento',
        'informacion procedimiento',
      ]),
      const IntentPattern('recordatorio', [
        'recuerdame', 'recordatorio', 'pon recordatorio',
        'no olvides', 'acuerdame',
      ]),
      const IntentPattern('cita', [
        'proxima cita', 'agendar cita', 'cita programada',
        'paciente cita', 'turno',
      ]),
      const IntentPattern('navegar_home', [
        'llevame al inicio', 'ir al inicio', 'abrir home',
        'vamos al home', 'muestra el inicio', 'pagina principal',
        'quiero ver el inicio', 'regresar al inicio',
        'navegar a home', 'ir a home', 'abrir home',
      ]),
      const IntentPattern('navegar_perfil', [
        'llevame al perfil', 'abrir perfil', 'ir a mi perfil',
        'muestra mi perfil', 'quiero ver mi perfil', 'navegar a perfil',
        'abrir mi perfil', 'ver perfil',
      ]),
      const IntentPattern('navegar_pacientes', [
        'muestra pacientes', 'lista de pacientes', 'ver pacientes',
        'abrir pacientes', 'ir a pacientes', 'llevame a pacientes',
        'navegar a pacientes', 'quiero ver pacientes',
        'muestrame los pacientes', 'tus pacientes',
      ]),
      const IntentPattern('navegar_citas', [
        'muestra citas', 'ver citas', 'abrir agenda',
        'ir a agenda', 'llevame a la agenda', 'navegar a citas',
        'quiero ver mis citas', 'muestrame las citas', 'agenda',
      ]),
      const IntentPattern('navegar_clinica', [
        'abrir clinica', 'ir a clinica', 'gestion clinica',
        'llevame a la clinica', 'navegar a clinica', 'administrar clinica',
      ]),
      const IntentPattern('navegar_stories', [
        'ver stories', 'abrir historias', 'ir a historias',
        'muestra historias', 'navegar a stories', 'ver historias',
      ]),
      const IntentPattern('agendar_cita', [
        'agenda cita', 'crear cita', 'nueva cita',
        'agendar una cita', 'quiero agendar', 'programar cita',
        'registrar cita', 'poner cita',
      ]),
      const IntentPattern('buscar_paciente', [
        'buscar paciente', 'encuentra paciente', 'localiza paciente',
        'busca a', 'donde esta el paciente', 'encontrar paciente',
        'buscar un paciente',
      ]),
      const IntentPattern('ayuda_app', [
        'como uso la app', 'ayuda app', 'tutorial app',
        'como funciona medident', 'que hace la app', 'explica app',
        'funciones de la app',
      ]),
      const IntentPattern('feliz', [
        'estoy feliz', 'que bien', 'me alegra', 'excelente',
        'estoy bien', 'todo bien', 'perfecto',
      ]),
      const IntentPattern('triste', [
        'estoy triste', 'que mal', 'no funciona', 'esta mal',
        'estoy cansado', 'problemas', 'error',
      ]),
      const IntentPattern('crear_post', [
        'crear post', 'nuevo post', 'publicar post',
        'hacer una publicacion', 'crear publicacion',
      ]),
      const IntentPattern('crear_story', [
        'crear story', 'nueva historia', 'publicar historia',
        'hacer una story', 'subir historia',
      ]),
      const IntentPattern('tratamientos', [
        'ver tratamientos', 'lista tratamientos', 'tratamientos disponibles',
        'que tratamientos hay', 'mostrar tratamientos',
        'tipo de tratamientos',
      ]),
      const IntentPattern('odontograma', [
        'abrir odontograma', 'ver odontograma', 'mostrar odontograma',
        'ir a odontograma', 'navegar odontograma',
      ]),
      const IntentPattern('turnos', [
        'ver turnos', 'mis turnos', 'agenda turnos',
        'turnos del dia', 'mostrar turnos',
      ]),
      const IntentPattern('seguridad', [
        'ir a seguridad', 'abrir seguridad', 'navegar a seguridad',
        'configuracion seguridad', 'ver seguridad',
      ]),
      const IntentPattern('entregas', [
        'ver entregas', 'ir a entregas', 'navegar a delivery',
        'abrir delivery', 'seguimiento entregas',
      ]),
      const IntentPattern('sugerencias', [
        'que sugieres', 'dame una sugerencia', 'que recomiendas',
        'sugiere algo', 'que puedo hacer',
      ]),
    ]);
  }

  void observe(String screen, {String? patient, String? procedure}) {
    _currentScreen = screen;
    _currentPatient = patient;
    _currentProcedure = procedure;

    _interactionHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'screen': screen,
      'patient': patient,
      'procedure': procedure,
    });

    if (_interactionHistory.length > 200) {
      _interactionHistory.removeAt(0);
    }

    if (_isVisible && !_isChatOpen) {
      _lastResponse = getSuggestion();
    }

    notifyListeners();
  }

  void setOdontologistName(String name) {
    _odontologistName = name;
    _preferences['odontologist_name'] = name;
    _savePreferences();
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text.trim(), isUser: true));
    _isTyping = true;
    _expression = ValeriaRiveExpression.thinking;
    notifyListeners();

    if (_interactionHistory.length > 500) {
      _interactionHistory.removeRange(0, _interactionHistory.length - 400);
    }

    String? intent;
    String response;

    final grokKey = ValeriaConfig.grokApiKey;
    if (grokKey != null && grokKey.isNotEmpty) {
      final grokResult = await _callGrok(text);
      if (grokResult != null) {
        intent = grokResult['intent'] as String?;
        response = grokResult['response'] as String? ?? '';
        _lastMatchedIntent = intent;
        final shouldNavigate = grokResult['should_navigate'] == true;
        if (shouldNavigate) {
          final target = grokResult['navigation_target'] as String?;
          if (target != null) {
            _tools['navigate']?.call({'screen': target});
          }
        }
      } else if (ValeriaConfig.useLocalFallback) {
        _ensureEngineInitialized();
        final result = _engine.classify(text);
        intent = result.intent;
        response = result.response;
        _lastMatchedIntent = result.matched ? result.intent : null;
        if (intent != null) {
          await _executeTool(intent);
        }
      } else {
        response = 'Lo siento, no pude contactar a Grok en este momento.';
      }
    } else if (ValeriaConfig.useLocalFallback) {
      _ensureEngineInitialized();
      final result = _engine.classify(text);
      intent = result.intent;
      response = result.response;
      _lastMatchedIntent = result.matched ? result.intent : null;
      if (intent != null) {
        await _executeTool(intent);
      }
    } else {
      response = 'Lo siento, no tengo conexión en este momento.';
    }

    _messages.add(ChatMessage(text: response, isUser: false, intent: intent));
    _lastResponse = response;
    _isTyping = false;
    _expression = _getExpressionForIntent(intent);
    _unreadCount = 0;

    _interactionHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'chat',
      'user_message': text.trim(),
      'valeria_response': response,
      'intent': intent,
      'confidence': 0.0,
    });

    notifyListeners();
  }

  Future<Map<String, dynamic>?> _callGrok(String text) async {
    try {
      final historyCount = (_messages.length - 1).clamp(0, 20);
      final messages = [
        {'role': 'system', 'content': ValeriaConfig.systemPrompt},
        ..._messages.take(historyCount).map((m) => {
          'role': m.isUser ? 'user' : 'assistant',
          'content': m.text,
        }),
        {'role': 'user', 'content': text},
      ];

      final body = jsonEncode({
        'model': ValeriaConfig.grokModel,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 300,
      });

      final response = await http.post(
        Uri.parse(ValeriaConfig.grokEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ValeriaConfig.grokApiKey}',
        },
        body: body,
      ).timeout(Duration(milliseconds: ValeriaConfig.timeoutMs));

      if (response.statusCode != 200) {
        debugPrint('Grok error ${response.statusCode}: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) return null;

      final content = choices[0]['message']['content'] as String?;
      if (content == null || content.isEmpty) return null;

      final lower = content.toLowerCase();
      String? detectedIntent;
      if (lower.contains('navegar') || lower.contains('ir a') || lower.contains('llevar')) {
        if (lower.contains('inicio') || lower.contains('home')) detectedIntent = 'navegar_home';
        else if (lower.contains('perfil')) detectedIntent = 'navegar_perfil';
        else if (lower.contains('paciente')) detectedIntent = 'navegar_pacientes';
        else if (lower.contains('cita') || lower.contains('agenda')) detectedIntent = 'navegar_citas';
        else if (lower.contains('story') || lower.contains('historia')) detectedIntent = 'navegar_stories';
      } else if (lower.contains('agendar') || lower.contains('crear cita')) {
        detectedIntent = 'agendar_cita';
      }

      return {
        'response': content,
        'intent': detectedIntent,
        'should_navigate': detectedIntent != null && detectedIntent.startsWith('navegar_'),
        if (detectedIntent != null && detectedIntent.startsWith('navegar_'))
          'navigation_target': _navigationTarget(detectedIntent),
      };
    } catch (e) {
      debugPrint('Grok call error: $e');
      return null;
    }
  }

  String? _navigationTarget(String intent) {
    switch (intent) {
      case 'navegar_home': return 'home';
      case 'navegar_perfil': return 'profile';
      case 'navegar_pacientes': return 'patients';
      case 'navegar_citas': return 'appointments';
      case 'navegar_stories': return 'stories';
      default: return null;
    }
  }

  ValeriaRiveExpression _getExpressionForIntent(String? intent) {
    if (intent == null) return ValeriaRiveExpression.sad;
    switch (intent) {
      case 'saludo':
      case 'gracias':
      case 'feliz':
      case 'como_estas':
      case 'navegar_home':
      case 'navegar_perfil':
      case 'navegar_pacientes':
      case 'navegar_citas':
      case 'agendar_cita':
      case 'crear_post':
      case 'crear_story':
        return ValeriaRiveExpression.happy;
      case 'triste':
      case 'descansar':
        return ValeriaRiveExpression.sad;
      case 'ayuda':
      case 'ayuda_app':
      case 'sugerencias':
        return ValeriaRiveExpression.thinking;
      default:
        return ValeriaRiveExpression.happy;
    }
  }

  Future<void> _executeTool(String intent) async {
    switch (intent) {
      case 'navegar_home':
        _tools['navigate']?.call({'screen': 'home'});
      case 'navegar_perfil':
        _tools['navigate']?.call({'screen': 'profile'});
      case 'navegar_pacientes':
        _tools['navigate']?.call({'screen': 'patients'});
      case 'navegar_citas':
        _tools['navigate']?.call({'screen': 'appointments'});
      case 'navegar_clinica':
        _tools['navigate']?.call({'screen': 'clinic'});
      case 'navegar_stories':
        _tools['navigate']?.call({'screen': 'stories'});
      case 'agendar_cita':
        _tools['navigate']?.call({'screen': 'create_appointment'});
      case 'buscar_paciente':
        _tools['navigate']?.call({'screen': 'patients'});
      case 'crear_post':
        _tools['navigate']?.call({'screen': 'create_post'});
      case 'crear_story':
        _tools['navigate']?.call({'screen': 'create_story'});
      case 'odontograma':
        _tools['navigate']?.call({'screen': 'odontogram'});
      case 'turnos':
        _tools['navigate']?.call({'screen': 'schedule'});
      case 'tratamientos':
        _tools['navigate']?.call({'screen': 'treatments'});
      case 'seguridad':
        _tools['navigate']?.call({'screen': 'security'});
      case 'entregas':
        _tools['navigate']?.call({'screen': 'delivery'});
    }
  }

  Future<void> executeAction(String intent) async {
    _actionInProgress = intent;
    notifyListeners();

    _messages.add(ChatMessage(
      text: _respuestaEjecucion(intent),
      isUser: false,
      intent: intent,
      isAction: true,
    ));
    _expression = ValeriaRiveExpression.happy;
    _actionInProgress = null;
    notifyListeners();
  }

  String _respuestaEjecucion(String intent) {
    switch (intent) {
      case 'agendar_cita': return 'Cita agendada correctamente. ¿Necesitas algo más?';
      case 'buscar_paciente': return 'Paciente encontrado. ¿Qué necesitas hacer?';
      case 'crear_post': return 'Post creado exitosamente.';
      case 'crear_story': return 'Historia publicada con éxito.';
      case 'cancelar_cita': return 'Cita cancelada. ¿Quieres reagendar?';
      default: return 'Acción completada. ¿Algo más?';
    }
  }

  String getSuggestion() {
    switch (_currentScreen) {
      case 'dashboard':
        return _getDashboardSuggestion();
      case 'patients':
        return _getPatientsSuggestion();
      case 'patient_detail':
        return _getPatientDetailSuggestion();
      case 'odontogram':
        return _getOdontogramSuggestion();
      case 'rips':
        return _getRipsSuggestion();
      case 'reels':
        return _getReelsSuggestion();
      case 'profile':
        return _getProfileSuggestion();
      default:
        return _getDefaultSuggestion();
    }
  }

  String _getDashboardSuggestion() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 18
            ? 'Buenas tardes'
            : 'Buenas noches';
    final name = _odontologistName ?? '';
    return '$greeting$name. ¿Necesitas revisar algo en especial? Puedes pedirme que navegue a pacientes, citas o tu perfil.';
  }

  String _getPatientsSuggestion() {
    if (_currentPatient != null) {
      return 'Estás viendo a $_currentPatient. ¿Quieres que busque información de sus tratamientos anteriores?';
    }
    return 'Aquí están todos tus pacientes. Puedes buscar por nombre o filtrar por estado.';
  }

  String _getPatientDetailSuggestion() {
    return '¿Quieres generar un RIPS para $_currentPatient? También puedes ver su odontograma.';
  }

  String _getOdontogramSuggestion() {
    if (_currentProcedure != null) {
      final code = _getRecommendedCode(_currentProcedure!);
      return 'Para $_currentProcedure, el código CIE-10 recomendado es $code.';
    }
    return 'Toca cualquier diente para ver opciones de tratamiento. Yo te ayudaré con los códigos.';
  }

  String _getRipsSuggestion() {
    return 'Los RIPS se generan automáticamente desde el odontograma. ¿Quieres exportar el último tratamiento?';
  }

  String _getReelsSuggestion() {
    return 'Aquí puedes ver videos educativos. ¿Quieres que te recomiende contenido sobre endodoncias?';
  }

  String _getProfileSuggestion() {
    return 'Desde aquí puedes configurar tus preferencias. ¿Sabías que puedes ajustar mi nivel de intervención?';
  }

  String _getDefaultSuggestion() {
    return '¿En qué puedo ayudarte hoy? Puedes pedirme que vaya al inicio, pacientes, citas o perfil.';
  }

  String _getRecommendedCode(String procedure) {
    final p = procedure.toLowerCase();
    if (p.contains('caries')) return 'K02.9';
    if (p.contains('endodoncia')) return 'K04.7';
    if (p.contains('extracción') || p.contains('extraccion')) return 'K08.1';
    if (p.contains('corona')) return 'K08.5';
    if (p.contains('implante')) return 'K08.8';
    return ValeriaKnowledge.buscarCodigo(p) ?? 'Z01.2';
  }

  void toggleChat() {
    _isChatOpen = !_isChatOpen;
    if (_isChatOpen) {
      _unreadCount = 0;
      if (_messages.isEmpty) {
        _messages.add(ChatMessage(
          text: '¡Hola! Soy Valeria, tu asistente de Medident. Puedes pedirme que navegue a secciones, busque pacientes, agende citas, o consulte códigos CIE-10.',
          isUser: false,
        ));
      }
    }
    notifyListeners();
  }

  void openChat() {
    if (!_isChatOpen) toggleChat();
  }

  void closeChat() {
    if (_isChatOpen) toggleChat();
  }

  void clearMessages() {
    _messages.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  void toggleVisibility() {
    _isVisible = !_isVisible;
    if (!_isVisible) {
      _expression = ValeriaRiveExpression.sleeping;
      closeChat();
    } else {
      _expression = ValeriaRiveExpression.happy;
    }
    _savePreferences();
    notifyListeners();
  }

  void setVisibility(bool visible) {
    _isVisible = visible;
    _expression = visible
        ? ValeriaRiveExpression.happy
        : ValeriaRiveExpression.sleeping;
    if (!visible) closeChat();
    _savePreferences();
    notifyListeners();
  }

  void learnFromAction(String suggestion, bool accepted) {
    _interactionHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'feedback',
      'suggestion': suggestion,
      'accepted': accepted,
    });
    final key = '${_currentScreen}_${_currentProcedure ?? 'general'}';
    _procedureFrequency[key] = (_procedureFrequency[key] ?? 0) + 1;
    _savePreferences();
  }

  String explainToPatient(String diagnosis, {int patientAge = 30}) {
    final d = diagnosis.toLowerCase();
    if (d.contains('caries')) {
      if (patientAge < 12) {
        return 'Tienes un huequito en tu diente que debemos tapar para que no crezca. Es rápido y no duele.';
      } else if (patientAge > 60) {
        return 'Ha aparecido una caries. Es importante tratarla pronto para evitar complicaciones.';
      }
      return 'Se ha detectado una caries. Es una pequeña cavidad que necesita ser limpiada y rellenada.';
    }
    if (d.contains('endodoncia')) {
      return 'El nervio del diente está dañado y necesita ser eliminado. Limpiamos el interior, lo desinfectamos y lo sellamos.';
    }
    if (d.contains('extracción') || d.contains('extraccion')) {
      return 'El diente no se puede salvar y debe ser removido. Con anestesia no sentirás dolor.';
    }
    if (d.contains('implante')) {
      return 'Vamos a colocar una raíz artificial de titanio para reemplazar el diente perdido.';
    }
    return 'El odontólogo te explicará el diagnóstico en detalle. ¿Tienes alguna pregunta?';
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isVisible = prefs.getBool('valeria_visible') ?? true;
      _odontologistName = prefs.getString('odontologist_name') ?? 'Dr.';
      if (!_isVisible) _expression = ValeriaRiveExpression.sleeping;
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando preferencias de Valeria: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('valeria_visible', _isVisible);
      if (_odontologistName != null) {
        await prefs.setString('odontologist_name', _odontologistName!);
      }
    } catch (e) {
      debugPrint('Error guardando preferencias de Valeria: $e');
    }
  }

  /// ═══════════════════════════════════════════════
  /// SISTEMA DE ENTRENAMIENTO
  /// ═══════════════════════════════════════════════
  /// 
  /// Valeria guarda TODAS las interacciones en [_interactionHistory].
  /// Cuando tengamos suficientes datos, este método lo notificará
  /// para que podamos fine-tunear un modelo propio con datos reales.
  /// 
  /// Criterio para considerar "suficiente":
  /// - Mínimo 50 interacciones de chat
  /// - Mínimo 5 intents diferentes detectados
  /// - Mínimo 10 feedbacks (aceptar/ignorar sugerencias)

  TrainingStatus checkTrainingStatus() {
    final chatCount = _interactionHistory.where((i) => i['type'] == 'chat').length;
    final feedbackCount = _interactionHistory.where((i) => i['type'] == 'feedback').length;
    final uniqueIntents = _interactionHistory
        .where((i) => i['intent'] != null)
        .map((i) => i['intent'] as String)
        .toSet()
        .length;
    final uniqueScreens = _interactionHistory
        .where((i) => i['screen'] != null)
        .map((i) => i['screen'] as String)
        .toSet()
        .length;

    final isReady = chatCount >= 50 && uniqueIntents >= 5;
    final progress = ((chatCount / 50).clamp(0.0, 1.0) * 0.5 +
            (uniqueIntents / 5).clamp(0.0, 1.0) * 0.3 +
            (feedbackCount / 10).clamp(0.0, 1.0) * 0.2)
        .clamp(0.0, 1.0);

    return TrainingStatus(
      isReady: isReady,
      progress: progress,
      chatCount: chatCount,
      feedbackCount: feedbackCount,
      uniqueIntents: uniqueIntents,
      uniqueScreens: uniqueScreens,
      totalInteractions: _interactionHistory.length,
    );
  }

  /// Exporta los datos de interacción en formato JSON lista para fine-tuning
  List<Map<String, dynamic>> exportTrainingData() {
    return List.from(_interactionHistory);
  }

  /// Reinicia el historial de entrenamiento después de exportar
  void resetTrainingData() {
    _interactionHistory.clear();
    _procedureFrequency.clear();
    _savePreferences();
    notifyListeners();
  }
}

/// Resultado del análisis de datos de entrenamiento de Valeria
class TrainingStatus {
  final bool isReady;
  final double progress;
  final int chatCount;
  final int feedbackCount;
  final int uniqueIntents;
  final int uniqueScreens;
  final int totalInteractions;

  const TrainingStatus({
    required this.isReady,
    required this.progress,
    required this.chatCount,
    required this.feedbackCount,
    required this.uniqueIntents,
    required this.uniqueScreens,
    required this.totalInteractions,
  });
}
