import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_themes.dart';
import '../services/platform_service.dart';

/// Bouton outlined adaptatif qui utilise CupertinoButton.filled sur iOS et OutlinedButton sur Android.
///
/// Ce widget détecte automatiquement la plateforme et utilise le design system
/// approprié pour une expérience native sur chaque plateforme.
class AdaptiveOutlinedButton extends StatelessWidget {
  /// Texte du bouton.
  final String text;

  /// Callback appelé lorsque le bouton est pressé.
  final VoidCallback? onPressed;

  /// Couleur de bordure du bouton.
  final Color? borderColor;

  /// Couleur du texte du bouton.
  final Color? textColor;

  /// Couleur de fond du bouton.
  final Color? backgroundColor;

  /// Indique si le bouton est désactivé.
  final bool isDisabled;

  /// Largeur du bouton (optionnel).
  final double? width;

  /// Hauteur du bouton (optionnel).
  final double? height;

  /// Widget personnalisé à afficher à la place du texte (optionnel).
  final Widget? child;

  const AdaptiveOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.isDisabled = false,
    this.width,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isDisabled) ? null : onPressed;
    final effectiveBorderColor = borderColor ?? AppColors.kBorder;
    final effectiveTextColor = textColor ?? AppColors.kTextPrimary;
    final effectiveBackgroundColor = backgroundColor ?? Colors.white;

    if (PlatformService.isIOS) {
      return SizedBox(
        width: width,
        height: height ?? 50,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          disabledColor: Colors.transparent,
          onPressed: effectiveOnPressed,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              border: Border.all(
                color: effectiveBorderColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: child ??
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: AppThemes.kFontFamily,
                      color: effectiveTextColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            ),
          ),
        ),
      );
    }

    // Material Design pour Android
    return SizedBox(
      width: width,
      height: height ?? 50,
      child: OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor:
              effectiveBackgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: effectiveTextColor.withValues(alpha: 0.5),
          side: BorderSide(color: effectiveBorderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: child ??
            Text(
              text,
              style: TextStyle(
                fontFamily: AppThemes.kFontFamily,
                color: effectiveTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
      ),
    );
  }
}

