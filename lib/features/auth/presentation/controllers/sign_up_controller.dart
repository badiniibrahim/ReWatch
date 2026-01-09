import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/result.dart';
import '../../../../core/utilities/snackbar_helper.dart';
import '../../../../core/widgets/adaptive_widgets.dart';
import '../../../../routes/app_pages.dart';
import '../../domain/usecase/sign_up_usecase.dart';
import '../../domain/usecase/sign_in_with_google_usecase.dart';
import '../../domain/usecase/sign_in_with_apple_usecase.dart';

/// Controller pour la vue d'inscription.
/// 
/// Gère l'état et les actions d'inscription (email/password, Google, Apple).
class SignUpController extends GetxController {
  final SignUpUseCase _signUpUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;

  SignUpController({
    required SignUpUseCase signUpUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
  })  : _signUpUseCase = signUpUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signInWithAppleUseCase = signInWithAppleUseCase;

  /// Contrôleur pour le champ nom d'utilisateur.
  final TextEditingController usernameController = TextEditingController();

  /// Contrôleur pour le champ email.
  final TextEditingController emailController = TextEditingController();

  /// Contrôleur pour le champ mot de passe.
  final TextEditingController passwordController = TextEditingController();

  /// Contrôleur pour le champ confirmation de mot de passe.
  final TextEditingController confirmPasswordController = TextEditingController();

  /// Indique si le mot de passe est visible.
  final RxBool isPasswordVisible = false.obs;

  /// Indique si la confirmation de mot de passe est visible.
  final RxBool isConfirmPasswordVisible = false.obs;

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
    usernameController.addListener(_updateFormValidity);
    emailController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
    confirmPasswordController.addListener(_updateFormValidity);
  }

  @override
  void onClose() {
    usernameController.removeListener(_updateFormValidity);
    emailController.removeListener(_updateFormValidity);
    passwordController.removeListener(_updateFormValidity);
    confirmPasswordController.removeListener(_updateFormValidity);
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Met à jour l'état de validité du formulaire.
  void _updateFormValidity() {
    isFormValid.value = usernameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        confirmPasswordController.text.trim().isNotEmpty;
  }

  /// Bascule la visibilité du mot de passe.
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Bascule la visibilité de la confirmation de mot de passe.
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }


  /// Inscrit un nouvel utilisateur.
  Future<void> signUp() async {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      errorMessage.value = 'auth_fillAllFields'.tr;
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      errorMessage.value = 'auth_passwordsDoNotMatch'.tr;
      return;
    }

    if (passwordController.text.length < 6) {
      errorMessage.value = 'auth_passwordMinLength'.tr;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _signUpUseCase.call(
      username: usernameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    result.when(
      success: (user) {
        // Afficher un dialog avec message détaillé
        AdaptiveDialog.show(
          context: Get.context!,
          title: 'auth_accountCreatedTitle'.tr,
          content: 'auth_accountCreatedMessage'.tr,
          actions: [
            AdaptiveDialogAction(
              text: 'common_ok'.tr,
              onPressed: () {
                // Naviguer vers l'écran de connexion
                Get.offNamed(Routes.signIn);
              },
              isDefault: true,
            ),
          ],
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

  /// Navigue vers la page de connexion.
  void navigateToSignIn() {
    Get.back();
  }
}

