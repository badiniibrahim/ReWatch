import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_scaffold.dart';
import '../../../../core/widgets/platform_logo_helper.dart';
import '../controllers/watch_item_form_controller.dart';

class PlatformSelectionView extends StatelessWidget {
  const PlatformSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WatchItemFormController>();

    return AdaptiveScaffold(
      backgroundColor: AppColors.kSurface,
      appBar: AppBar(
        title: Text(
          'watch_platformSelectionTitle'.tr,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.kTextPrimary,
          ),
        ),
        backgroundColor: AppColors.kSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.kTextPrimary),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: WatchItemFormController.platforms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final platform = WatchItemFormController.platforms[index];
          return _buildPlatformCard(context, platform, controller);
        },
      ),
    );
  }

  Widget _buildPlatformCard(
    BuildContext context,
    String platform,
    WatchItemFormController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (platform == 'Autre...') {
              Get.back();
              controller.showCustomPlatformDialog();
            } else {
              controller.platformController.text = platform;
              Get.back();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Logo
                PlatformLogoHelper.getLogo(platform, size: 48),
                const SizedBox(width: 16),
                // Nom
                Expanded(
                  child: Text(
                    platform,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                ),
                // Icône de sélection
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.kTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
