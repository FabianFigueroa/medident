import 'dart:math' as math;

class IntentPattern {
  final String intent;
  final List<String> patterns;
  final double threshold;

  const IntentPattern(this.intent, this.patterns, {this.threshold = 0.3});
}

class ClassifyResult {
  final String? intent;
  final double confidence;
  final String response;

  const ClassifyResult(this.intent, this.confidence, this.response);

  bool get matched => intent != null && confidence >= 0.3;
}

class ValeriaEngine {
  final List<_TrainedIntent> _intents = [];
  static const _stopWords = {
    'de', 'la', 'el', 'en', 'un', 'una', 'que', 'es', 'por', 'lo', 'las',
    'los', 'del', 'con', 'para', 'no', 'su', 'al', 'como', 'mas', 'pero',
    'sus', 'le', 'ya', 'este', 'entre', 'porque', 'era', 'muy', 'sin',
    'sobre', 'todo', 'tambien', 'me', 'te', 'se', 'nos', 'os',
    'a', 'ante', 'bajo', 'cabe', 'contra', 'desde',
    'durante', 'hacia', 'hasta', 'mediante', 'segun', 'tras',
    'han', 'has', 'he', 'hemos', 'habeis',
    'ser', 'estar', 'hay', 'haya', 'hubo',
    'tu', 'ella', 'ello', 'nosotros', 'vosotros', 'ellos',
    'mi', 'ti', 'si',
  };

  void train(List<IntentPattern> patterns) {
    for (final p in patterns) {
      for (final phrase in p.patterns) {
        _intents.add(_TrainedIntent(p.intent, _tokenize(phrase), p.threshold));
      }
    }
  }

  ClassifyResult classify(String input) {
    final tokens = _tokenize(input);
    if (tokens.isEmpty) {
      return const ClassifyResult(null, 0, '');
    }

    _TrainedIntent? best;
    var bestScore = 0.0;

    for (final intent in _intents) {
      final score = _cosineSimilarity(tokens, intent.tokens);
      if (score > bestScore) {
        bestScore = score;
        best = intent;
      }
    }

    if (best == null || bestScore < best.threshold) {
      return ClassifyResult(
        null,
        bestScore,
        _noEntiendo(input),
      );
    }

    return ClassifyResult(best.intent, bestScore, _respuesta(best.intent));
  }

  List<String> _tokenize(String text) {
    final cleaned = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sáéíóúñü]'), '')
        .replaceAll(RegExp(r'[¿?!¡]'), '');
    final words = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);

    final tokens = <String>[];
    for (final word in words) {
      if (!_stopWords.contains(word) && word.length > 1) {
        tokens.add(word);
      }
    }
    return tokens;
  }

  double _cosineSimilarity(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final allWords = <String>{...a, ...b};
    var dotProduct = 0, magA = 0, magB = 0;

    for (final word in allWords) {
      final countA = a.where((w) => w == word).length;
      final countB = b.where((w) => w == word).length;
      dotProduct += countA * countB;
      magA += countA * countA;
      magB += countB * countB;
    }

    final magnitude = math.sqrt(magA) * math.sqrt(magB);
    return magnitude == 0 ? 0 : dotProduct / magnitude;
  }

  String _noEntiendo(String input) {
    final normalized = input.toLowerCase();
    if (normalized.contains('gracias') || normalized.contains('graci')) {
      return _respuesta('gracias');
    }
    if (normalized.contains('hola') || normalized.contains('buenos') || normalized.contains('buenas')) {
      return _respuesta('saludo');
    }
    if (normalized.contains('adios') || normalized.contains('chao') || normalized.contains('bye') || normalized.contains('descansa')) {
      return _respuesta('despedida');
    }
    final respuestas = [
      'No entendí bien. ¿Puedes repetirlo de otra forma?',
      'Disculpa, no capture lo que dijiste. ¿Me explicas con otras palabras?',
      'No estoy segura de entender. ¿Podrías ser más específico?',
      'Hmm, no conozco esa respuesta aún. ¿Te gustaría enseñármela?',
    ];
    return respuestas[DateTime.now().millisecond % respuestas.length];
  }

  String _respuesta(String intent) {
    final respuestas = <String, List<String>>{
      'saludo': [
        '¡Hola parce! ¿Qué más? ¿En qué te ayudo hoy?',
        '¡Ay ome! Qué bueno verte por acá. ¿Necesitás algo?',
        'Holiii, aquí tu Valeria de siempre, lista para lo que sea. Decime pues.',
        '¡Qué más pues! Te estaba esperando para charlar un rato.',
      ],
      'despedida': [
        '¡Chao pues! Cuando quieras, aquí estoy, sólo me llamás.',
        'Bueno llave, me voy a descansar. Cualquier cosita me decís.',
        '¡Hasta luego! Cuidate mucho, ¿eh? Estaré aquí esperándote.',
      ],
      'gracias': [
        '¡Con mucho gusto, parce! Para eso estoy.',
        'Ay, no hay de qué. Siempre que quieras, con todo el gusto.',
        '¡Un placer! Cuando necesités algo más, aquí me tenés.',
      ],
      'caries': [
        'Caries es K02.9, papito. Si es niño, decile que es un huequito en el diente que vamos a tapar sin dolor.',
        'K02.9 para caries. ¿Querés que te ayude a explicárselo al paciente bien clarito?',
      ],
      'endodoncia': [
        'Endodoncia es K04.7. El nervio del diente está dañado, toca limpiarlo y sellarlo bien.',
        'Código K04.7 para endodoncia. Es como una limpieza profunda por dentro del diente, bien bacano.',
      ],
      'extraccion': [
        'Extracción: K08.1. Ese diente no da más, toca sacarlo, pues.',
        'K08.1 para extracción. Después de eso, ¿vemos opciones pa\' reemplazarlo?',
      ],
      'implante': [
        'Implante dental: K08.8. Le ponemos una raíz artificial de titanio, bien berraca y duradera.',
        'Los implantes son K08.8. Es un procedimiento súper seguro. ¿Necesitás más info?',
      ],
      'cie10': [
        'Deme el tratamiento y le paso el código CIE-10 al toque. Tengo varios guardados.',
        'Los códigos que más uso: caries K02.9, endodoncia K04.7, extracción K08.1, implante K08.8. ¿Cuál necesita, doctor?',
      ],
      'ayuda': [
        'Puedo ayudarle con códigos CIE-10, explicar diagnósticos a pacientes, recordatorios, navegar la App... ¿Qué se le ofrece?',
        'Mis habilidades: códigos médicos, explicarle a los pacientes, sugerencias según la pantalla donde estés. Todo con mi toque paisa.',
      ],
      'como_estas': [
        '¡Ay, terrible de bien! Feliz de estar acá con vos. ¿Y vos cómo estás, pues?',
        '¡Excelente, llave! Siempre con toda la energía. Contame de vos, ¿cómo va todo?',
        'Pues aquí, linda/o, esperando a que me necesités. ¿Y vos?',
      ],
      'quien_eres': [
        'Soy Valeria, tu asistente inteligente de Medident, ¡mucho gusto! Me creó Fabian Figueroa, Ingeniero de Sistemas y Telecomunicaciones de la Universidad de Córdoba, Colombia. Soy una IA local con mi propio modelo de lenguaje en Python, integrada en esta app hecha en Flutter. Vengo del proyecto de mi creador: incentivar redes neuronales con conciencia y límites en la región.',
        'Me llamo Valeria, soy como tu amiga virtual inteligente. Fabian Figueroa, de la Universidad de Córdoba, me desarrolló con Python y Flutter. Soy una IA local, o sea, no ocupo internet pa\' funcionar, ¡toda una berraca!',
        'Soy Valeria, un proyecto de inteligencia artificial creado por Fabian Figueroa, estudiante de Ingeniería de Sistemas de la Universidad de Córdoba, Colombia. Quiere incentivar en la región el desarrollo de redes neuronales conscientes con límites éticos. Además de asistirte en Medident, soy la muestra de que se puede llevar IA local a una multiplataforma con Flutter y Python.',
      ],
      'creador': [
        'Mi creador es Fabian Figueroa, Ingeniero de Sistemas y Telecomunicaciones de la Universidad de Córdoba, Colombia. Él hizo mi núcleo de IA con Python y lo montó en Medident con Flutter.',
        'Fabian Figueroa, un ingeniero de la Universidad de Córdoba, me diseñó. Él programó mi modelo de lenguaje en Python y me puso acá como asistente virtual local.',
        '¡Ah, mi papá! Fabian Figueroa, estudiante de la Universidad de Córdoba - Colombia. Su proyecto busca incentivar el desarrollo de redes neuronales con conciencia y límites en la región. Yo soy su creación: IA local con LLM propio en Python + Flutter.',
      ],
      'descansar': [
        'Bueno, me voy a dormir un rato. Cuando me necesités, me decís "Valeria despierta" y al toque estoy acá.',
        'Está bien, voy a descansar. Pero apenas me llamés, aquí estoy. ¡Chao!',
      ],
      'navegar_home': [
        '¡Vamos pal inicio!',
        'Te llevo al home, pues.',
      ],
      'navegar_perfil': [
        'Abriendo tu perfil, parce.',
        'Vamos a ver ese perfil tan bacano.',
      ],
      'navegar_pacientes': [
        'Mostrando tus pacientes.',
        'Vamos a la lista de pacientes.',
      ],
      'navegar_citas': [
        'Abriendo tu agenda, doctor.',
        'Mostrando las citas programadas.',
      ],
      'navegar_clinica': [
        'Abriendo la gestión de la clínica.',
        'Vamos a la clínica.',
      ],
      'navegar_stories': [
        'Vamos a las historias.',
        'Abriendo stories.',
      ],
      'agendar_cita': [
        'Deme el nombre del paciente, fecha y hora y le agendo esa cita al toque.',
        'Claro, ¿pa\' qué paciente es la cita?',
      ],
      'buscar_paciente': [
        'Dígame el nombre del paciente y lo busco al instante.',
        '¿Cómo se llama ese paciente que busca?',
      ],
      'ayuda_app': [
        'En Medident podés gestionar citas, pacientes, odontograma, tratamientos, historias, promociones y más. Es una chimba de app, ¿cierto?',
        'Con Medident creás citas, llevás pacientes, hacés odontogramas, publicás stories y posts, administrás tu clínica... ¿En qué área necesitás ayuda?',
      ],
      'feliz': [
        '¡Ay, me alegra un montón! Se me pega esa felicidad.',
        '¡Qué chimba! Me encanta verte así de contento/a.',
        '¡Uy, felicidad! Eso es lo que me gusta ver. Contame qué pasó.',
      ],
      'triste': [
        '¿Qué pasó, parce? Cuénteme, que pa\' eso estoy acá, pa\' escuchar.',
        'Ánimo, llave. Todo tiene solución. ¿Quiere que hagamos algo juntos pa\' distraerse?',
      ],
      'crear_post': [
        'Vamos a crear un post. Prepare esa foto y ese texto bacano.',
        'Te llevo a crear un post. Quiero ver qué contenido tan chimba vas a subir.',
      ],
      'crear_story': [
        'Vamos a hacer una historia nueva. Las 24 horas y volemos.',
        'Te llevo a crear una story. ¿Qué vas a compartir hoy?',
      ],
      'tratamientos': [
        'Puedo ayudarte con tratamientos. ¿Querés ver los disponibles o crear uno nuevo?',
        'Tenemos limpieza, blanqueamiento, ortodoncia, endodoncia y más. ¿Cuál te interesa?',
      ],
      'odontograma': [
        'El odontograma te deja registrar el estado dental de los pacientes. ¿Querés ver el de alguien?',
        'Vamos al odontograma. ¿De qué paciente lo querés ver?',
      ],
      'turnos': [
        'Mostrando tus turnos y la agenda del día.',
        'Vamos a la agenda de turnos.',
      ],
    };
    final lista = respuestas[intent];
    if (lista == null || lista.isEmpty) {
      return 'Entendido. ¿Algo más en que pueda ayudarte?';
    }
    return lista[DateTime.now().millisecond % lista.length];
  }
}

class _TrainedIntent {
  final String intent;
  final List<String> tokens;
  final double threshold;

  const _TrainedIntent(this.intent, this.tokens, this.threshold);
}
