import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_widgets.dart';
import '../controllers/sign_in_controller.dart';

/// Vue de connexion.
///
/// Permet à l'utilisateur de se connecter avec email/password,
/// Google ou Apple.
class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: AppColors.kSurface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            // Titre
            Text(
              'auth_signInTitle'.tr,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'auth_signInSubtitle'.tr,
              style: TextStyle(fontSize: 16, color: AppColors.kTextSecondary),
            ),
            const SizedBox(height: 40),
            // Champ Email
            _buildEmailField(),
            const SizedBox(height: 24),
            // Champ Password
            _buildPasswordField(),
            const SizedBox(height: 16),
            // Lien Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.navigateToResetPassword,
                child: Text(
                  'auth_forgotPassword'.tr,
                  style: TextStyle(color: AppColors.kPrimary, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Bouton Continue
            _buildContinueButton(),
            const SizedBox(height: 32),
            // Séparateur Or
            _buildOrSeparator(),
            const SizedBox(height: 32),
            // Bouton Apple
            _buildAppleButton(),
            const SizedBox(height: 16),
            // Bouton Google
            _buildGoogleButton(),
            const SizedBox(height: 32),
            // Lien Sign Up
            _buildSignUpLink(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth_yourEmail'.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.kTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        AdaptiveTextField(
          controller: controller.emailController,
          placeholder: 'auth_enterYourEmail'.tr,
          hintText: 'auth_enterYourEmail'.tr,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth_password'.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.kTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => AdaptiveTextField(
            controller: controller.passwordController,
            placeholder: 'auth_enterYourPassword'.tr,
            hintText: 'auth_enterYourPassword'.tr,
            obscureText: !controller.isPasswordVisible.value,
            suffix: IconButton(
              icon: Icon(
                controller.isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: AppColors.kTextSecondary,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Obx(() {
      final isEnabled =
          controller.isFormValid.value && !controller.isLoading.value;
      return AdaptiveButton(
        text: 'auth_continue'.tr.toUpperCase(),
        onPressed: isEnabled ? controller.signIn : null,
        backgroundColor: isEnabled
            ? AppColors.kPrimary
            : AppColors.kSurfaceVariant,
        isDisabled: !isEnabled,
        isLoading: controller.isLoading.value,
        height: 56,
      );
    });
  }

  Widget _buildOrSeparator() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.kBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'auth_or'.tr,
            style: TextStyle(color: AppColors.kTextSecondary, fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: AppColors.kBorder)),
      ],
    );
  }

  Widget _buildAppleButton() {
    return Obx(
      () => AdaptiveOutlinedButton(
        text: 'auth_signInWithApple'.tr,
        onPressed: controller.isLoading.value
            ? null
            : controller.signInWithApple,
        isDisabled: controller.isLoading.value,
        height: 56,
        textColor: AppColors.kLightTextPrimary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apple, size: 24, color: AppColors.kLightTextPrimary),
            const SizedBox(width: 12),
            Text(
              'auth_signInWithApple'.tr,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.kLightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Obx(
      () => AdaptiveOutlinedButton(
        text: 'auth_signInWithGoogle'.tr,
        onPressed: controller.isLoading.value
            ? null
            : controller.signInWithGoogle,
        isDisabled: controller.isLoading.value,
        height: 56,
        textColor: AppColors.kLightTextPrimary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(
              'auth_signInWithGoogle'.tr,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.kLightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'auth_dontHaveAccount'.tr,
          style: TextStyle(color: AppColors.kTextSecondary, fontSize: 14),
        ),
        TextButton(
          onPressed: controller.navigateToSignUp,
          child: Text(
            'auth_signUp'.tr,
            style: TextStyle(
              color: AppColors.kPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
