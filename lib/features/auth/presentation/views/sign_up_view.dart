import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_widgets.dart';
import '../controllers/sign_up_controller.dart';

/// Vue d'inscription.
/// 
/// Permet à l'utilisateur de créer un compte avec email/password,
/// Google ou Apple.
class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

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
              'auth_signUpTitle'.tr,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'auth_signUpSubtitle'.tr,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.kTextSecondary,
              ),
            ),
            const SizedBox(height: 40),
            // Champ Username
            _buildUsernameField(),
            const SizedBox(height: 24),
            // Champ Email
            _buildEmailField(),
            const SizedBox(height: 24),
            // Champ Password
            _buildPasswordField(),
            const SizedBox(height: 24),
            // Champ Confirm Password
            _buildConfirmPasswordField(),
            const SizedBox(height: 32),
            // Bouton Sign Up
            _buildSignUpButton(),
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
            // Lien Sign In
            _buildSignInLink(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth_username'.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.kTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        AdaptiveTextField(
          controller: controller.usernameController,
          placeholder: 'auth_enterYourUsername'.tr,
          hintText: 'auth_enterYourUsername'.tr,
        ),
      ],
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
        Obx(() => AdaptiveTextField(
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
            )),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth_confirmPassword'.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.kTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => AdaptiveTextField(
              controller: controller.confirmPasswordController,
              placeholder: 'auth_confirmYourPassword'.tr,
              hintText: 'auth_confirmYourPassword'.tr,
              obscureText: !controller.isConfirmPasswordVisible.value,
              suffix: IconButton(
                icon: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.kTextSecondary,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            )),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return Obx(() {
      final isEnabled = controller.isFormValid.value && !controller.isLoading.value;
      return AdaptiveButton(
        text: 'auth_signUpButton'.tr.toUpperCase(),
        onPressed: isEnabled ? controller.signUp : null,
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
            style: TextStyle(
              color: AppColors.kTextSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.kBorder)),
      ],
    );
  }

  Widget _buildAppleButton() {
    return Obx(() => AdaptiveOutlinedButton(
          text: 'auth_signUpWithApple'.tr,
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
                'auth_signUpWithApple'.tr,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.kLightTextPrimary,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildGoogleButton() {
    return Obx(
      () => AdaptiveOutlinedButton(
        text: 'auth_signUpWithGoogle'.tr,
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
              'auth_signUpWithGoogle'.tr,
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

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'auth_alreadyHaveAccount'.tr,
          style: TextStyle(
            color: AppColors.kTextSecondary,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: controller.navigateToSignIn,
          child: Text(
            'auth_signIn'.tr,
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

