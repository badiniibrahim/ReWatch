import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';

/// Helper pour afficher des snackbars de manière sûre
/// Utilise ScaffoldMessenger au lieu de Get.snackbar pour éviter les erreurs d'Overlay
class SnackbarHelper {
  /// Affiche un snackbar de succès
  static void showSuccess(String message, {String? title}) {
    _showSnackbar(
      title: title ?? 'success'.tr,
      message: message,
      backgroundColor: AppColors.kSuccess,
      icon: Icons.check_circle,
    );
  }

  /// Affiche un snackbar d'erreur
  static void showError(String message, {String? title}) {
    _showSnackbar(
      title: title ?? 'errorTitle'.tr,
      message: message,
      backgroundColor: AppColors.kError,
      icon: Icons.error,
    );
  }

  /// Affiche un snackbar d'information
  static void showInfo(String message, {String? title}) {
    _showSnackbar(
      title: title ?? 'info'.tr,
      message: message,
      backgroundColor: AppColors.kInfo,
      icon: Icons.info,
    );
  }

  /// Affiche un snackbar d'avertissement
  static void showWarning(String message, {String? title}) {
    _showSnackbar(
      title: title ?? 'common_warning'.tr,
      message: message,
      backgroundColor: AppColors.kWarning,
      icon: Icons.warning,
    );
  }

  /// Méthode privée pour afficher un snackbar
  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    // Vérifier si un contexte est disponible
    final context = Get.context;

    // Protection double : context doit être non nul et monté
    if (context == null) {
      // Fallback : utiliser Get.snackbar si pas de contexte mais overlay dispo
      if (Get.overlayContext != null) {
        try {
          Get.snackbar(
            title,
            message,
            backgroundColor: backgroundColor,
            colorText: Colors.white,
            icon: Icon(icon, color: Colors.white),
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 3),
          );
        } catch (_) {}
      }
      return;
    }

    try {
      // Utiliser ScaffoldMessenger pour un affichage sûr
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'common_ok'.tr,
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } catch (e) {
      // Si ScaffoldMessenger échoue (ex: pas de Scaffold), fallback sur Get.snackbar si possible
      if (Get.overlayContext != null) {
        try {
          Get.snackbar(
            title,
            message,
            backgroundColor: backgroundColor,
            colorText: Colors.white,
            icon: Icon(icon, color: Colors.white),
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 3),
          );
        } catch (_) {}
      }
    }
  }

  // Alias pour compatibilité avec le code existant
  /// Alias pour showSuccess
  static void success(String message, {String? title}) =>
      showSuccess(message, title: title);

  /// Alias pour showError
  static void error(String message, {String? title}) =>
      showError(message, title: title);

  /// Alias pour showInfo
  static void info(String message, {String? title}) =>
      showInfo(message, title: title);

  /// Alias pour showWarning
  static void warning(String message, {String? title}) =>
      showWarning(message, title: title);

  /// Affiche un snackbar personnalisé (bridge pour ancien code)
  static void show(
    String title,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    SnackPosition position = SnackPosition.TOP,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: backgroundColor ?? AppColors.kPrimary,
      icon: Icons.info,
    );
  }
}

