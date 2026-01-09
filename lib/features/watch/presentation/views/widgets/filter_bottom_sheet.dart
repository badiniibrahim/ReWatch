import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rewatch/core/config/app_colors.dart';
import 'package:rewatch/core/widgets/adaptive_button.dart';
import 'package:rewatch/features/watch/domain/entities/watch_item.dart';
import 'package:rewatch/features/watch/presentation/controllers/watch_home_controller.dart';

/// Bottom sheet pour les filtres
class FilterBottomSheet extends StatelessWidget {
  final WatchHomeController controller;

  const FilterBottomSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // En-tête
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'watch_filters'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kTextPrimary,
                ),
              ),
              TextButton(
                onPressed: controller.resetFilters,
                child: Text('watch_resetFilters'.tr),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Filtre par type
          _buildSectionTitle('watch_filterType'.tr),
          const SizedBox(height: 12),
          Obx(() => Row(
                children: [
                  _buildFilterChip(
                    label: 'watch_filterAll'.tr,
                    selected: controller.selectedType.value == null,
                    onTap: () => controller.updateTypeFilter(null),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'watch_filterSeries'.tr,
                    selected: controller.selectedType.value == WatchItemType.series,
                    onTap: () => controller.updateTypeFilter(WatchItemType.series),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'watch_filterMovies'.tr,
                    selected: controller.selectedType.value == WatchItemType.movie,
                    onTap: () => controller.updateTypeFilter(WatchItemType.movie),
                  ),
                ],
              )),
          const SizedBox(height: 24),
          // Filtre par statut
          _buildSectionTitle('watch_filterStatus'.tr),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    label: 'watch_filterAll'.tr,
                    selected: controller.selectedStatus.value == null,
                    onTap: () => controller.updateStatusFilter(null),
                  ),
                  _buildFilterChip(
                    label: 'watch_statusWatching'.tr,
                    selected: controller.selectedStatus.value == WatchItemStatus.watching,
                    onTap: () => controller.updateStatusFilter(WatchItemStatus.watching),
                  ),
                  _buildFilterChip(
                    label: 'watch_statusCompleted'.tr,
                    selected: controller.selectedStatus.value == WatchItemStatus.completed,
                    onTap: () => controller.updateStatusFilter(WatchItemStatus.completed),
                  ),
                  _buildFilterChip(
                    label: 'watch_statusPlanned'.tr,
                    selected: controller.selectedStatus.value == WatchItemStatus.planned,
                    onTap: () => controller.updateStatusFilter(WatchItemStatus.planned),
                  ),
                ],
              )),
          const SizedBox(height: 24),
          // Filtre par plateforme
          _buildSectionTitle('watch_filterPlatform'.tr),
          const SizedBox(height: 12),
          Obx(() {
            final platforms = controller.platforms;
            if (platforms.isEmpty) {
              return Text(
                'watch_noPlatformAvailable'.tr,
                style: const TextStyle(color: AppColors.kTextSecondary),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  label: 'watch_filterAllPlatforms'.tr,
                  selected: controller.selectedPlatform.value.isEmpty,
                  onTap: () => controller.updatePlatformFilter(''),
                ),
                ...platforms.map((platform) => _buildFilterChip(
                      label: platform,
                      selected: controller.selectedPlatform.value == platform,
                      onTap: () => controller.updatePlatformFilter(platform),
                    )),
              ],
            );
          }),
          const SizedBox(height: 24),
          // Tri
          _buildSectionTitle('watch_sortBy'.tr),
          const SizedBox(height: 12),
          Obx(() => Row(
                children: [
                  _buildFilterChip(
                    label: 'watch_sortRecentlyUpdated'.tr,
                    selected: controller.sortBy.value == 'updatedAt',
                    onTap: () => controller.changeSort('updatedAt'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'watch_sortTitle'.tr,
                    selected: controller.sortBy.value == 'title',
                    onTap: () => controller.changeSort('title'),
                  ),
                ],
              )),
          const SizedBox(height: 32),
          // Bouton fermer
          SizedBox(
            width: double.infinity,
            child: AdaptiveButton(
              text: 'common_close'.tr,
              onPressed: () => Navigator.pop(context),
              backgroundColor: AppColors.kPrimary,
            ),
          ),
          const SizedBox(height: 16),
        ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.kTextPrimary,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.kPrimary
              : AppColors.kSurfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.kPrimary : AppColors.kBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected
                ? Colors.white
                : AppColors.kTextPrimary,
          ),
        ),
      ),
    );
  }
}
