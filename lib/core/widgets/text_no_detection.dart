import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/platform_service.dart';

/// Widget Text qui désactive complètement la détection automatique de données sur iOS
/// pour éviter les soulignements jaunes.
/// 
/// Utilise SelectableText avec enableInteractiveSelection: false sur iOS
/// pour désactiver la détection automatique.
/// 
/// Utilisez ce widget au lieu de Text() partout dans l'application pour iOS.
class TextNoDetection extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const TextNoDetection(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textScaleFactor,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) {
    // Sur iOS, utiliser SelectableText.rich avec enableInteractiveSelection: false
    // pour désactiver complètement la détection automatique de données
    if (PlatformService.isIOS) {
      return SelectableText.rich(
        TextSpan(
          text: data,
          style: style,
        ),
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
        enableInteractiveSelection: false,
        textScaleFactor: textScaleFactor ?? 1.0,
        strutStyle: strutStyle,
        textWidthBasis: textWidthBasis ?? TextWidthBasis.parent,
        textHeightBehavior: textHeightBehavior,
        showCursor: false,
      );
    }

    // Sur Android, utiliser Text normal
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}
