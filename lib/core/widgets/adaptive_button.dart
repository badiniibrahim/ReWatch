import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_themes.dart';
import '../services/platform_service.dart';

/// Bouton adaptatif qui utilise CupertinoButton sur iOS et ElevatedButton sur Android.
///
/// Ce widget détecte automatiquement la plateforme et utilise le design system
/// approprié pour une expérience native sur chaque plateforme.
class AdaptiveButton extends StatelessWidget {
  /// Texte du bouton.
  final String text;

  /// Callback appelé lorsque le bouton est pressé.
  final VoidCallback? onPressed;

  /// Couleur de fond du bouton.
  final Color? backgroundColor;

  /// Couleur du texte du bouton.
  final Color? textColor;

  /// Indique si le bouton est désactivé.
  final bool isDisabled;

  /// Largeur du bouton (optionnel).
  final double? width;

  /// Hauteur du bouton (optionnel).
  final double? height;

  /// Indicateur de chargement (affiche un spinner pendant le chargement).
  final bool isLoading;

  /// Widget personnalisé à afficher à la place du texte (optionnel).
  final Widget? child;

  const AdaptiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isDisabled = false,
    this.width,
    this.height,
    this.isLoading = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.kPrimarySolid;
    final effectiveTextColor = textColor ?? Colors.white;

    if (PlatformService.isIOS) {
      return SizedBox(
        width: width,
        height: height ?? 50,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: effectiveBackgroundColor,
          disabledColor: effectiveBackgroundColor.withValues(alpha: 0.5),
          onPressed: effectiveOnPressed,
          child: isLoading
              ? CupertinoActivityIndicator(color: effectiveTextColor)
              : child ??
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: AppThemes.kFontFamily,
                      color: effectiveTextColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
      );
    }

    // Material Design pour Android
    return SizedBox(
      width: width,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor:
              effectiveBackgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: effectiveTextColor.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : child ??
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: AppThemes.kFontFamily,
                    color: effectiveTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}

