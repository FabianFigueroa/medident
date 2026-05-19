class ValeriaKnowledge {
  static const cie10 = {
    'caries': 'K02.9',
    'endodoncia': 'K04.7',
    'extraccion': 'K08.1',
    'corona': 'K08.5',
    'implante': 'K08.8',
    'periodontitis': 'K05.3',
    'gingivitis': 'K05.1',
    'absceso': 'K04.7',
    'fluorosis': 'K00.3',
    'bruxismo': 'F45.8',
    'halitosis': 'R19.6',
    'sensibilidad': 'K03.8',
    'fractura dental': 'S02.5',
    'maloclusion': 'M26.4',
    'tumor oral': 'C06.9',
    'estomatitis': 'K12.1',
  };

  static const procedimientos = {
    'limpieza': 'Profilaxis dental. Eliminación de sarro y placa bacteriana.',
    'blanqueamiento': 'Aplicación de peróxido de hidrógeno para aclarar el esmalte.',
    'resina': 'Restauración estética del diente con material del color del diente.',
    'amalgama': 'Restauración con material plateado para dientes posteriores.',
    'sellante': 'Aplicación de barrera protectora en surcos de molares.',
    'fluorizacion': 'Aplicación tópica de flúor para fortalecer el esmalte.',
    'corona': 'Cobertura completa del diente con material protésico.',
    'puente': 'Prótesis fija que reemplaza uno o más dientes ausentes.',
    'endodoncia': 'Eliminación de la pulpa dental, limpieza y sellado del conducto.',
    'extraccion simple': 'Remoción de un diente visible en la boca.',
    'extraccion quirurgica': 'Remoción de un diente incluido o no erupcionado.',
    'implante': 'Inserción de un tornillo de titanio en el hueso maxilar.',
    'ortodoncia': 'Corrección de la posición dental con brackets o alineadores.',
    'periodoncia': 'Tratamiento de encías y tejidos de soporte dental.',
    'radiografia': 'Imagen diagnóstica para evaluar estructuras dentales internas.',
  };

  static const explicaciones = {
    'caries ninos': 'Tienes un huequito en tu diente que debemos tapar para que no crezca. Es rápido y no duele.',
    'caries adultos': 'Se ha detectado una caries dental. Es una pequeña cavidad que necesita ser limpiada y rellenada.',
    'caries mayores': 'Ha aparecido una caries en uno de sus dientes. Es importante tratarla pronto para evitar complicaciones.',
    'endodoncia paciente': 'El nervio del diente está dañado y necesita ser eliminado. Limpiamos el interior, lo desinfectamos y lo sellamos.',
    'extraccion paciente': 'El diente no se puede salvar y debe ser removido. Con anestesia no sentirás dolor.',
    'implante paciente': 'Vamos a colocar una raíz artificial de titanio para reemplazar el diente perdido. Es un procedimiento seguro y duradero.',
  };

  static const saludos = [
    '¡Hola! ¿En qué puedo ayudarte?',
    '¡Qué bueno verte! ¿Necesitas algo?',
    'Hola, aquí estoy para lo que necesites.',
    '¡Hey! Cuéntame, ¿en qué te ayudo hoy?',
  ];

  static const despedidas = [
    '¡Hasta luego! Aquí estaré cuando me necesites.',
    'Descansa. Si me necesitas, solo llámame.',
    '¡Chao! Fue un gusto ayudarte.',
    'Me voy a descansar. ¡Cuidate!',
  ];

  static const estados = [
    'Estoy muy bien, gracias por preguntar. ¿Y tú?',
    '¡Excelente! Siempre lista para ayudarte.',
    'Feliz de poder conversar contigo. ¿En qué te ayudo?',
    'Energizada y lista. Dime qué necesitas.',
  ];

  static String? buscarCodigo(String procedimiento) {
    final normalized = procedimiento.toLowerCase().trim();
    for (final entry in cie10.entries) {
      if (normalized.contains(entry.key)) {
        return '${entry.key.toUpperCase()}: ${entry.value}';
      }
    }
    return null;
  }

  static String? explicarProcedimiento(String nombre) {
    final normalized = nombre.toLowerCase().trim();
    for (final entry in procedimientos.entries) {
      if (normalized.contains(entry.key)) {
        return '**${entry.key.toUpperCase()}**: ${entry.value}';
      }
    }
    return null;
  }
}
