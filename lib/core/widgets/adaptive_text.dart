import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/platform_service.dart';

/// Widget Text adaptatif qui désactive la détection automatique de données sur iOS
/// pour éviter les soulignements jaunes.
class AdaptiveText extends StatelessWidget {
  /// Le texte à afficher
  final String data;

  /// Le style du texte
  final TextStyle? style;

  /// L'alignement du texte
  final TextAlign? textAlign;

  /// Le nombre maximum de lignes
  final int? maxLines;

  /// Indique si le texte doit être tronqué avec des ellipses
  final TextOverflow? overflow;

  /// Le facteur d'échelle du texte
  final double? textScaleFactor;

  /// Indique si le texte doit être sélectionnable
  final bool selectable;

  const AdaptiveText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textScaleFactor,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    // Sur iOS, utiliser SelectableText avec enableInteractiveSelection: false
    // pour désactiver complètement la détection automatique de données et éviter les soulignements jaunes
    if (PlatformService.isIOS && !selectable) {
      return SelectableText.rich(
        TextSpan(
          text: data,
          style: style,
        ),
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
        enableInteractiveSelection: false,
        textScaleFactor: textScaleFactor ?? 1.0,
      );
    }

    // Sur Android ou si selectable est true, utiliser Text normal
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
    );
  }
}
