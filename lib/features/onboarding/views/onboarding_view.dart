import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_widgets.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/page_indicator.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      useSafeArea: false,
      body: Stack(
        children: [
          // Background simple sans dégradé
          Container(decoration: const BoxDecoration(color: AppColors.kSurface)),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with skip button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // App logo
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox.shrink(),
                      ),
                      // Skip button
                      TextButton(
                        onPressed: controller.skipOnboarding,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.kSurface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.kBorder,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'onboarding_skip'.tr,
                          style: const TextStyle(
                            color: AppColors.kTextSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: controller.pages.length,
                    itemBuilder: (context, index) {
                      final page = controller.pages[index];
                      return _buildPage(
                        title: page['title'] as String,
                        subtitle: page['subtitle'] as String,
                        description: page['description'] as String,
                        image: page['image'] as String?,
                        icon: page['icon'] as IconData?,
                        iconColor: page['iconColor'] as Color?,
                      );
                    },
                  ),
                ),

                // Navigation and progress
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.kCard,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(color: AppColors.kBorder, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kShadow.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Page indicators
                      PageIndicator(
                        itemCount: controller.pages.length,
                        currentIndex: controller.currentPage,
                      ),
                      const SizedBox(height: 24),
                      // Action button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.kShadow.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AdaptiveButton(
                          text: '',
                          onPressed: controller.nextPage,
                          backgroundColor: AppColors.kPrimary,
                          height: 56,
                          child: Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  controller.currentPage.value <
                                          controller.pages.length - 1
                                      ? 'onboarding_next'.tr
                                      : 'onboarding_start'.tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required String description,
    String? image,
    required IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Carte propre et lisible
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors
                  .kSurfaceElevated, // Surface élevée pour détacher du fond
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.kBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.kShadow.withValues(
                    alpha: 0.2,
                  ), // Ombre plus marquée
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              children: [
                // Image ou Icône
                if (image != null)
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 40),
                    height: 200,
                    width: double.infinity,
                    child: Image.asset(image, fit: BoxFit.contain),
                  )
                else
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.kPrimary).withValues(
                        alpha: 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon ?? Icons.movie,
                      size: 64,
                      color: iconColor ?? AppColors.kPrimary,
                    ),
                  ),
                // Subtitle badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.kPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kTextPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.kTextSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
