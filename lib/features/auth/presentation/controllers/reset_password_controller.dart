import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/result.dart';
import '../../../../core/utilities/snackbar_helper.dart';
import '../../domain/usecase/reset_password_usecase.dart';

/// Controller pour la vue de réinitialisation de mot de passe.
/// 
/// Gère l'état et les actions de réinitialisation de mot de passe.
class ResetPasswordController extends GetxController {
  final ResetPasswordUseCase _resetPasswordUseCase;

  ResetPasswordController({
    required ResetPasswordUseCase resetPasswordUseCase,
  }) : _resetPasswordUseCase = resetPasswordUseCase;

  /// Contrôleur pour le champ email.
  final TextEditingController emailController = TextEditingController();

  /// Indique si une opération est en cours.
  final RxBool isLoading = false.obs;

  /// Message d'erreur à afficher.
  final RxString errorMessage = ''.obs;

  /// Indique si l'email a été envoyé avec succès.
  final RxBool isEmailSent = false.obs;

  /// Indique si le formulaire est valide (champ email rempli).
  final RxBool isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Écouter les changements dans le champ email pour mettre à jour isFormValid
    emailController.addListener(_updateFormValidity);
  }

  @override
  void onClose() {
    emailController.removeListener(_updateFormValidity);
    emailController.dispose();
    super.onClose();
  }

  /// Met à jour l'état de validité du formulaire.
  void _updateFormValidity() {
    isFormValid.value = emailController.text.trim().isNotEmpty;
  }

  /// Envoie l'email de réinitialisation de mot de passe.
  Future<void> resetPassword() async {
    if (emailController.text.isEmpty) {
      errorMessage.value = 'auth_emailRequired'.tr;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    isEmailSent.value = false;

    final result = await _resetPasswordUseCase.call(
      email: emailController.text,
    );

    result.when(
      success: (_) {
        isEmailSent.value = true;
        SnackbarHelper.showSuccess(
          'auth_resetPasswordSuccess'.tr,
          title: 'success'.tr,
        );
      },
      failure: (message, errorCode, error) {
        errorMessage.value = message;
        SnackbarHelper.showError(
          message,
          title: 'errorTitle'.tr,
        );
      },
    );

    isLoading.value = false;
  }

  /// Navigue vers la page de connexion.
  void navigateToSignIn() {
    Get.back();
  }
}

