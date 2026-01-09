import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_scaffold.dart';
import '../../../../core/widgets/platform_logo_helper.dart';
import '../controllers/watch_item_form_controller.dart';

/// Vue pour sélectionner une plateforme
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
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final platform = WatchItemFormController.platforms[index];
          return _buildPlatformTile(platform, controller);
        },
      ),
    );
  }

  Widget _buildPlatformTile(
    String platform,
    WatchItemFormController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
                PlatformLogoHelper.getLogo(platform, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    platform,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                ),
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
