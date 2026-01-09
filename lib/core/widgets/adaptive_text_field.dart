import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_themes.dart';
import '../services/platform_service.dart';

/// Champ de texte adaptatif qui utilise CupertinoTextField sur iOS et TextField sur Android.
///
/// Ce widget détecte automatiquement la plateforme et utilise le design system
/// approprié pour une expérience native sur chaque plateforme.
class AdaptiveTextField extends StatelessWidget {
  /// Contrôleur du champ de texte.
  final TextEditingController? controller;

  /// Texte d'aide (placeholder).
  final String? placeholder;

  /// Texte d'aide (hint) pour Material.
  final String? hintText;

  /// Type de clavier.
  final TextInputType? keyboardType;

  /// Indique si le texte doit être masqué (pour les mots de passe).
  final bool obscureText;

  /// Callback appelé lorsque le texte change.
  final ValueChanged<String>? onChanged;

  /// Callback appelé lorsque le champ est soumis.
  final ValueChanged<String>? onSubmitted;

  /// Callback appelé lorsque le champ est tapé.
  final VoidCallback? onTap;

  /// Préfixe (icône ou widget à gauche).
  final Widget? prefix;

  /// Suffixe (icône ou widget à droite).
  final Widget? suffix;

  /// Indique si le champ est en lecture seule.
  final bool readOnly;

  /// Indique si le champ est désactivé.
  final bool enabled;

  /// Style du texte.
  final TextStyle? style;

  /// Style du placeholder.
  final TextStyle? placeholderStyle;

  /// Couleur de fond.
  final Color? fillColor;

  /// Indique si le champ doit être rempli.
  final bool filled;

  /// Décoration personnalisée pour Material (optionnel).
  final InputDecoration? decoration;

  const AdaptiveTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.enabled = true,
    this.style,
    this.placeholderStyle,
    this.fillColor,
    this.filled = true,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformService.isIOS) {
      return CupertinoTextField(
        controller: controller,
        placeholder: placeholder ?? hintText,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        prefix: prefix,
        suffix: suffix,
        readOnly: readOnly,
        enabled: enabled,
        style:
            style ??
            TextStyle(
              fontFamily: AppThemes.kFontFamily,
              color: (fillColor ?? Colors.white) == Colors.white
                  ? AppColors.kLightTextPrimary
                  : AppColors.kTextPrimary,
              fontSize: 17,
            ),
        placeholderStyle:
            placeholderStyle ??
            TextStyle(
              fontFamily: AppThemes.kFontFamily,
              color: AppColors.kTextSecondary,
              fontSize: 17,
            ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: fillColor ?? Colors.white,
          border: Border.all(color: AppColors.kInput, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    // Material Design pour Android
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      readOnly: readOnly,
      enabled: enabled,
      style:
          style ??
          TextStyle(
            fontFamily: AppThemes.kFontFamily,
            color: (fillColor ?? Colors.white) == Colors.white
                ? AppColors.kLightTextPrimary
                : AppColors.kTextPrimary,
            fontSize: 16,
          ),
      decoration:
          decoration ??
          InputDecoration(
            hintText: hintText ?? placeholder,
            hintStyle: TextStyle(
              fontFamily: AppThemes.kFontFamily,
              color: AppColors.kTextSecondary,
              fontSize: 16,
            ),
            filled: filled,
            fillColor: fillColor ?? Colors.white,
            prefixIcon: prefix,
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.kInput),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.kInput),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.kRing, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.kInput.withValues(alpha: 0.5),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
    );
  }
}
