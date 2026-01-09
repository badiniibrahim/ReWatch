import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:rewatch/core/config/app_colors.dart';
import 'package:rewatch/core/widgets/adaptive_button.dart';
import 'package:rewatch/core/widgets/adaptive_scaffold.dart';
import 'package:rewatch/core/widgets/platform_logo_helper.dart';
import 'package:rewatch/features/watch/domain/entities/watch_item.dart';
import 'package:rewatch/features/watch/presentation/controllers/watch_home_controller.dart';

/// Vue dédiée aux filtres (au lieu d'une modal)
class WatchFiltersView extends GetView<WatchHomeController> {
  const WatchFiltersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Text(
          'watch_filters'.tr,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.kTextPrimary,
          ),
        ),
        backgroundColor: AppColors.kSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            FluentIcons.dismiss_24_regular,
            color: AppColors.kTextPrimary,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: controller.resetFilters,
            child: Text(
              'watch_resetFilters'.tr,
              style: const TextStyle(
                color: AppColors.kPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type Filter
            _buildSectionTitle(
              'watch_filterType'.tr,
              FluentIcons.movies_and_tv_24_regular,
            ),
            const SizedBox(height: 16),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildSelectableCard(
                      label: 'Tout',
                      icon: FluentIcons.grid_24_regular,
                      isSelected: controller.selectedType.value == null,
                      onTap: () => controller.updateTypeFilter(null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSelectableCard(
                      label: 'watch_filterMovies'.tr,
                      icon: FluentIcons.video_24_regular,
                      isSelected:
                          controller.selectedType.value == WatchItemType.movie,
                      onTap: () =>
                          controller.updateTypeFilter(WatchItemType.movie),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSelectableCard(
                      label: 'watch_filterSeries'.tr,
                      icon: FluentIcons.movies_and_tv_24_regular,
                      isSelected:
                          controller.selectedType.value == WatchItemType.series,
                      onTap: () =>
                          controller.updateTypeFilter(WatchItemType.series),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Status Filter
            _buildSectionTitle(
              'watch_filterStatus'.tr,
              FluentIcons.tasks_app_24_regular,
            ),
            const SizedBox(height: 16),
            Obx(
              () => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFilterChip(
                    label: 'Tous',
                    isSelected: controller.selectedStatus.value == null,
                    onTap: () => controller.updateStatusFilter(null),
                  ),
                  _buildFilterChip(
                    label: 'watch_statusWatching'.tr,
                    isSelected:
                        controller.selectedStatus.value ==
                        WatchItemStatus.watching,
                    onTap: () =>
                        controller.updateStatusFilter(WatchItemStatus.watching),
                    icon: FluentIcons.play_circle_24_regular,
                  ),
                  _buildFilterChip(
                    label: 'watch_statusCompleted'.tr,
                    isSelected:
                        controller.selectedStatus.value ==
                        WatchItemStatus.completed,
                    onTap: () => controller.updateStatusFilter(
                      WatchItemStatus.completed,
                    ),
                    icon: FluentIcons.checkmark_circle_24_regular,
                  ),
                  _buildFilterChip(
                    label: 'watch_statusPlanned'.tr,
                    isSelected:
                        controller.selectedStatus.value ==
                        WatchItemStatus.planned,
                    onTap: () =>
                        controller.updateStatusFilter(WatchItemStatus.planned),
                    icon: FluentIcons.clock_24_regular,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Platform Filter
            _buildSectionTitle(
              'watch_filterPlatform'.tr,
              FluentIcons.tv_24_regular,
            ),
            const SizedBox(height: 16),
            Obx(() {
              final platforms = controller.platforms;
              if (platforms.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.kSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'watch_noPlatformAvailable'.tr,
                    style: const TextStyle(
                      color: AppColors.kTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFilterChip(
                    label: 'watch_filterAllPlatforms'.tr,
                    isSelected: controller.selectedPlatform.value.isEmpty,
                    onTap: () => controller.updatePlatformFilter(''),
                  ),
                  ...platforms.map(
                    (platform) => _buildPlatformChip(
                      platform: platform,
                      isSelected: controller.selectedPlatform.value == platform,
                      onTap: () => controller.updatePlatformFilter(platform),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 32),

            // Sort Filter
            _buildSectionTitle(
              'watch_sortBy'.tr,
              FluentIcons.arrow_sort_24_regular,
            ),
            const SizedBox(height: 16),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.kSurfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSortSegment(
                        label: 'watch_sortRecentlyUpdated'.tr,
                        isSelected: controller.sortBy.value == 'updatedAt',
                        onTap: () => controller.changeSort('updatedAt'),
                      ),
                    ),
                    Expanded(
                      child: _buildSortSegment(
                        label: 'watch_sortTitle'.tr,
                        isSelected: controller.sortBy.value == 'title',
                        onTap: () => controller.changeSort('title'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Apply Button
            AdaptiveButton(
              text:
                  'Voir les résultats', // Could be translated 'watch_showResults'
              onPressed: () => Get.back(),
              backgroundColor: AppColors.kPrimary,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.kPrimary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.kTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.kPrimary
              : AppColors.kSurfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.kPrimary : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : AppColors.kTextPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.kTextPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.kPrimary
              : AppColors.kSurfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.kPrimary
                : AppColors.kBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.kTextSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.kTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformChip({
    required String platform,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.kPrimary.withValues(alpha: 0.1)
              : AppColors.kSurfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.kPrimary
                : AppColors.kBorder.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                PlatformLogoHelper.getLogo(platform, size: 28),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.kPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              platform,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.kPrimary : AppColors.kTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortSegment({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.kTextPrimary
                  : AppColors.kTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
