import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';
import '../services/platform_service.dart';
import '../utilities/snackbar_helper.dart';

/// Service pour afficher des snackbars adaptatifs.
///
/// Utilise CupertinoAlertDialog sur iOS et SnackbarHelper sur Android
/// pour une expérience native sur chaque plateforme.
class AdaptiveSnackbar {
  AdaptiveSnackbar._();

  /// Affiche un snackbar adaptatif.
  ///
  /// [title] : Titre du message
  /// [message] : Contenu du message
  /// [duration] : Durée d'affichage (par défaut 3 secondes)
  /// [isError] : Indique si c'est un message d'erreur (rouge)
  /// [isSuccess] : Indique si c'est un message de succès (vert)
  static void show({
    required String title,
    required String message,
    Duration? duration,
    bool isError = false,
    bool isSuccess = false,
  }) {
    if (PlatformService.isIOS) {
      // Sur iOS, utiliser un dialog Cupertino
      Get.dialog(
        CupertinoAlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: AppColors.kTextPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: AppColors.kTextPrimary,
              fontSize: 13,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(),
              child: Text(
                'common_ok'.tr,
                style: TextStyle(
                  color: AppColors.kPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    } else {
      // Sur Android, utiliser SnackbarHelper
      if (isError) {
        SnackbarHelper.showError(message, title: title);
      } else if (isSuccess) {
        SnackbarHelper.showSuccess(message, title: title);
      } else {
        SnackbarHelper.showInfo(message, title: title);
      }
    }
  }

  /// Affiche un snackbar d'erreur.
  static void showError({
    required String title,
    required String message,
    Duration? duration,
  }) {
    show(
      title: title,
      message: message,
      duration: duration,
      isError: true,
    );
  }

  /// Affiche un snackbar de succès.
  static void showSuccess({
    required String title,
    required String message,
    Duration? duration,
  }) {
    show(
      title: title,
      message: message,
      duration: duration,
      isSuccess: true,
    );
  }
}

