import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/result.dart';
import '../../../../core/utilities/snackbar_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../domain/usecase/sign_in_usecase.dart';
import '../../domain/usecase/sign_in_with_google_usecase.dart';
import '../../domain/usecase/sign_in_with_apple_usecase.dart';

/// Controller pour la vue de connexion.
///
/// Gère l'état et les actions de connexion (email/password, Google, Apple).
class SignInController extends GetxController {
  final SignInUseCase _signInUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;

  SignInController({
    required SignInUseCase signInUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
  }) : _signInUseCase = signInUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInWithAppleUseCase = signInWithAppleUseCase;

  /// Contrôleur pour le champ email.
  final TextEditingController emailController = TextEditingController();

  /// Contrôleur pour le champ mot de passe.
  final TextEditingController passwordController = TextEditingController();

  /// Indique si le mot de passe est visible.
  final RxBool isPasswordVisible = false.obs;

  /// Indique si une opération est en cours.
  final RxBool isLoading = false.obs;

  /// Message d'erreur à afficher.
  final RxString errorMessage = ''.obs;

  /// Indique si le formulaire est valide (tous les champs remplis).
  final RxBool isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Écouter les changements dans les champs pour mettre à jour isFormValid
    emailController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
  }

  @override
  void onClose() {
    emailController.removeListener(_updateFormValidity);
    passwordController.removeListener(_updateFormValidity);
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Met à jour l'état de validité du formulaire.
  void _updateFormValidity() {
    isFormValid.value =
        emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;
  }

  /// Bascule la visibilité du mot de passe.
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Connecte l'utilisateur avec email et mot de passe.
  Future<void> signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'auth_fillAllFields'.tr;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _signInUseCase.call(
      email: emailController.text,
      password: passwordController.text,
    );

    result.when(
      success: (user) {
        SnackbarHelper.showSuccess(
          'auth_signInSuccess'.tr,
          title: 'success'.tr,
        );
        // Naviguer vers la page principale en utilisant la route nommée
        // Cela garantit que le binding est appelé
        Get.offAllNamed(Routes.main);
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

  /// Connecte l'utilisateur avec Google.
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _signInWithGoogleUseCase.call();

    result.when(
      success: (user) {
        SnackbarHelper.showSuccess(
          'auth_googleSignInSuccess'.tr,
          title: 'success'.tr,
        );
        // Naviguer vers la page principale en utilisant la route nommée
        // Cela garantit que le binding est appelé
        Get.offAllNamed(Routes.main);
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

  /// Connecte l'utilisateur avec Apple.
  Future<void> signInWithApple() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _signInWithAppleUseCase.call();

    result.when(
      success: (user) {
        SnackbarHelper.showSuccess(
          'auth_appleSignInSuccess'.tr,
          title: 'success'.tr,
        );
        // Naviguer vers la page principale en utilisant la route nommée
        // Cela garantit que le binding est appelé
        Get.offAllNamed(Routes.main);
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

  /// Navigue vers la page d'inscription.
  void navigateToSignUp() {
    Get.toNamed(Routes.signUp);
  }

  /// Navigue vers la page de réinitialisation de mot de passe.
  void navigateToResetPassword() {
    Get.toNamed(Routes.resetPassword);
  }

  /// Vérifie si l'utilisateur a une session valide.
  ///
  /// Retourne true si l'utilisateur est authentifié et que son email est vérifié.
  Future<bool> hasSessionValid() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return false;
      }

      // Vérifier que l'email est vérifié
      await user.reload();
      return user.emailVerified;
    } catch (e) {
      return false;
    }
  }
}
