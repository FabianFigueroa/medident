import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  /// El texto completo a mostrar
  final String text;

  /// La parte del texto que tendrá gradiente (opcional)
  /// Si es null, todo el texto tendrá gradiente
  final String? gradientPart;

  /// Lista de colores para el gradiente (mínimo 2, máximo los que quieras)
  final List<Color> colors;

  /// Estilo base para todo el texto
  final TextStyle? style;
  /// Tipo de gradiente: lineal, radial o sweep
  final GradientType gradientType;
  /// Puntos de inicio/fin para gradiente lineal
  final Alignment? begin;
  final Alignment? end;
  final Alignment? center;
  final double? radius;
  final double? startAngle;
  final double? endAngle;
  /// Puntos de parada para los colores (opcional)
  final List<double>? stops;
  /// Propiedades de texto adicionales
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const GradientText({
    super.key,
    required this.text,
    this.gradientPart,
    required this.colors,
    this.style,
    this.gradientType = GradientType.linear,
    this.begin,
    this.end,
    this.center,
    this.radius,
    this.startAngle,
    this.endAngle,
    this.stops,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
  })  : assert(colors.length >= 2, 'Se necesitan al menos 2 colores'),
        assert(
        stops == null || stops.length == colors.length,
        'Los stops deben tener la misma cantidad que los colores',
        );

  @override
  Widget build(BuildContext context) {
    // Si no hay parte específica para gradiente, aplicar a todo el texto
    if (gradientPart == null || gradientPart!.isEmpty) {
      return _buildFullGradientText();
    }

    // Aplicar gradiente solo a una parte del texto
    return _buildPartialGradientText();
  }

  /// Construye el gradiente según el tipo seleccionado
  Gradient _createGradient(Rect rect) {
    switch (gradientType) {
      case GradientType.linear:
        return LinearGradient(
          colors: colors,
          stops: stops,
          begin: begin ?? Alignment.centerLeft,
          end: end ?? Alignment.centerRight,
        );

      case GradientType.radial:
        return RadialGradient(
          colors: colors,
          stops: stops,
          center: center ?? Alignment.center,
          radius: radius ?? 0.5,
        );

      case GradientType.sweep:
        return SweepGradient(
          colors: colors,
          stops: stops,
          center: center ?? Alignment.center,
          startAngle: startAngle ?? 0.0,
          endAngle: endAngle ?? 3.14 * 2, // 360 grados en radianes
        );
    }
  }

  Widget _buildFullGradientText() {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return _createGradient(bounds).createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap ?? true,
        strutStyle: strutStyle,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
      ),
    );
  }

  Widget _buildPartialGradientText() {
    // Dividir el texto en partes
    final parts = text.split(gradientPart!);

    // Si no encontramos la parte exacta, aplicar a todo el texto
    if (parts.length <= 1) {
      return _buildFullGradientText();
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          // Primera parte sin gradiente
          TextSpan(text: parts[0]),

          // Parte con gradiente
          WidgetSpan(
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                return _createGradient(bounds).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                );
              },
              child: Text(
                gradientPart!,
                style: style,
              ),
            ),
          ),

          // Última parte sin gradiente
          TextSpan(text: parts.length > 1 ? parts[1] : ''),
        ],
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap ?? true,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

/// Tipos de gradiente disponibles
enum GradientType {
  linear,
  radial,
  sweep,
}
