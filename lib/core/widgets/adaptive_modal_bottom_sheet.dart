import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';
import '../services/platform_service.dart';
import 'adaptive_button.dart';

/// Modal bottom sheet adaptatif qui utilise CupertinoActionSheet sur iOS et showModalBottomSheet sur Android.
///
/// Ce widget détecte automatiquement la plateforme et utilise le design system
/// approprié pour une expérience native sur chaque plateforme.
class AdaptiveModalBottomSheet {
  AdaptiveModalBottomSheet._();

  /// Affiche un modal bottom sheet adaptatif.
  ///
  /// [title] : Titre du modal (optionnel)
  /// [content] : Contenu du modal (widget)
  /// [actions] : Liste des actions (boutons)
  /// [isDismissible] : Indique si le modal peut être fermé en tapant à l'extérieur
  /// [enableDrag] : Indique si le modal peut être glissé pour fermer (Android uniquement)
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<AdaptiveModalAction>? actions,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
  }) {
    if (PlatformService.isIOS) {
      // Sur iOS, utiliser CupertinoActionSheet si on a des actions
      if (actions != null && actions.isNotEmpty) {
        return showCupertinoModalPopup<T>(
          context: context,
          barrierDismissible: isDismissible,
          useRootNavigator: useRootNavigator,
          builder: (context) => CupertinoActionSheet(
            title: title != null
                ? Text(
                    title!,
                    style: TextStyle(
                      color: AppColors.kTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : null,
            message: content,
            actions: actions.map((action) {
              return CupertinoActionSheetAction(
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
                    fontSize: 20,
                    fontWeight: action.isDefault ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              isDefaultAction: true,
              child: Text(
                'common_cancel'.tr,
                style: TextStyle(
                  color: AppColors.kPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }

      // Si pas d'actions, utiliser un bottom sheet personnalisé
      return showCupertinoModalPopup<T>(
        context: context,
        barrierDismissible: isDismissible,
        useRootNavigator: useRootNavigator,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: AppColors.kCard,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      title!,
                      style: TextStyle(
                        color: AppColors.kTextPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Flexible(child: content),
              ],
            ),
          ),
        ),
      );
    }

    // Sur Android, utiliser showModalBottomSheet (Material Design)
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.kCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar (indicateur de drag sur Android)
              if (enableDrag)
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.kTextSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title!,
                    style: TextStyle(
                      color: AppColors.kTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Flexible(child: content),
              if (actions != null && actions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: actions.map((action) {
                      return SizedBox(
                        width: double.infinity,
                        child: AdaptiveButton(
                          text: action.text,
                          onPressed: () {
                            Navigator.of(context).pop();
                            action.onPressed?.call();
                          },
                          backgroundColor: action.isDestructive
                              ? AppColors.kError
                              : AppColors.kPrimary,
                          isDisabled: action.isDisabled,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action pour un AdaptiveModalBottomSheet.
class AdaptiveModalAction {
  /// Texte de l'action.
  final String text;

  /// Callback appelé lorsque l'action est pressée.
  final VoidCallback? onPressed;

  /// Indique si c'est l'action par défaut.
  final bool isDefault;

  /// Indique si c'est une action destructive (rouge).
  final bool isDestructive;

  /// Indique si l'action est désactivée.
  final bool isDisabled;

  const AdaptiveModalAction({
    required this.text,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
    this.isDisabled = false,
  });
}

