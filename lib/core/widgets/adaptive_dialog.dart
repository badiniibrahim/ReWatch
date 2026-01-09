import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/platform_service.dart';

/// Dialog adaptatif qui utilise CupertinoAlertDialog sur iOS et AlertDialog sur Android.
///
/// Ce widget détecte automatiquement la plateforme et utilise le design system
/// approprié pour une expérience native sur chaque plateforme.
class AdaptiveDialog extends StatelessWidget {
  /// Titre du dialog.
  final String? title;

  /// Contenu du dialog.
  final String? content;

  /// Widget personnalisé pour le contenu (remplace content si fourni).
  final Widget? contentWidget;

  /// Liste des actions (boutons).
  final List<AdaptiveDialogAction> actions;

  const AdaptiveDialog({
    super.key,
    this.title,
    this.content,
    this.contentWidget,
    this.actions = const [],
  });

  /// Affiche le dialog de manière adaptative.
  static Future<void> show({
    required BuildContext context,
    String? title,
    String? content,
    Widget? contentWidget,
    List<AdaptiveDialogAction> actions = const [],
  }) {
    if (PlatformService.isIOS) {
      return showCupertinoDialog<void>(
        context: context,
        builder: (context) => AdaptiveDialog(
          title: title,
          content: content,
          contentWidget: contentWidget,
          actions: actions,
        ),
      );
    }

    // Material Design pour Android
    return showDialog<void>(
      context: context,
      builder: (context) => AdaptiveDialog(
        title: title,
        content: content,
        contentWidget: contentWidget,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformService.isIOS) {
      return CupertinoAlertDialog(
        title: title != null
            ? Text(
                title!,
                style: TextStyle(
                  color: AppColors.kTextPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
        content: contentWidget ??
            (content != null
                ? Text(
                    content!,
                    style: TextStyle(
                      color: AppColors.kTextPrimary,
                      fontSize: 13,
                    ),
                  )
                : null),
        actions: actions.map((action) {
          return CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              action.onPressed?.call();
            },
            isDefaultAction: action.isDefault,
            isDestructiveAction: action.isDestructive,
            child: Text(
              action.text,
              style: TextStyle(
                color: action.isDestructive
                    ? AppColors.kError
                    : AppColors.kPrimary,
                fontSize: 17,
                fontWeight: action.isDefault ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      );
    }

    // Material Design pour Android
    return AlertDialog(
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: AppColors.kTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      content: contentWidget ??
          (content != null
              ? Text(
                  content!,
                  style: TextStyle(
                    color: AppColors.kTextPrimary,
                    fontSize: 16,
                  ),
                )
              : null),
      actions: actions.map((action) {
        return TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            action.onPressed?.call();
          },
          child: Text(
            action.text,
            style: TextStyle(
              color: action.isDestructive
                  ? AppColors.kError
                  : AppColors.kPrimary,
              fontSize: 16,
              fontWeight: action.isDefault ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        );
      }).toList(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: AppColors.kCard,
    );
  }
}

/// Action pour un AdaptiveDialog.
class AdaptiveDialogAction {
  /// Texte de l'action.
  final String text;

  /// Callback appelé lorsque l'action est pressée.
  final VoidCallback? onPressed;

  /// Indique si c'est l'action par défaut.
  final bool isDefault;

  /// Indique si c'est une action destructive (rouge).
  final bool isDestructive;

  const AdaptiveDialogAction({
    required this.text,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
  });
}

