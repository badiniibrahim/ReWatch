import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_widgets.dart';
import '../controllers/reset_password_controller.dart';

/// Vue de réinitialisation de mot de passe.
/// 
/// Permet à l'utilisateur de demander un email de réinitialisation.
class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

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
              'auth_resetPasswordTitle'.tr,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'auth_resetPasswordSubtitle'.tr,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.kTextSecondary,
              ),
            ),
            const SizedBox(height: 40),
            // Champ Email
            _buildEmailField(),
            const SizedBox(height: 32),
            // Bouton Reset password
            _buildResetButton(),
            const SizedBox(height: 32),
            // Message de succès
            Obx(() => controller.isEmailSent.value
                ? _buildSuccessMessage()
                : const SizedBox.shrink()),
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

  Widget _buildResetButton() {
    return Obx(() {
      final isEnabled = controller.isFormValid.value && !controller.isLoading.value;
      return AdaptiveButton(
        text: 'auth_resetPasswordButton'.tr,
        onPressed: isEnabled ? controller.resetPassword : null,
        backgroundColor: isEnabled
            ? AppColors.kPrimary
            : AppColors.kSurfaceVariant,
        isDisabled: !isEnabled,
        isLoading: controller.isLoading.value,
        height: 56,
      );
    });
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kSuccess.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kSuccess.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.kSuccess),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'auth_passwordResetEmailSent'.tr,
              style: TextStyle(
                color: AppColors.kSuccess,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

