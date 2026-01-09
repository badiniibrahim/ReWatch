import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_widgets.dart';
import '../controllers/watch_item_detail_controller.dart';
import '../../domain/entities/watch_item.dart';

/// Écran de détail d'un WatchItem
class WatchItemDetailView extends GetView<WatchItemDetailController> {
  const WatchItemDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: AppColors.kSurface,
      appBar: AppBar(
        title: Text(
          'watch_details'.tr,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.kTextPrimary,
          ),
        ),
        backgroundColor: AppColors.kSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.kTextPrimary),
            onPressed: controller.navigateToEdit,
          ),
          IconButton(
            icon: Obx(() => controller.isDeleting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete, color: AppColors.kError)),
            onPressed: controller.isDeleting.value ? null : controller.deleteItem,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.kPrimary),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.error.value,
                  style: const TextStyle(color: AppColors.kError),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('common_back'.tr),
                ),
              ],
            ),
          );
        }

        final item = controller.item.value;
        if (item == null) {
          return Center(
            child: Text('watch_itemNotFound'.tr),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (item.image != null && item.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.image!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImagePlaceholder(item),
                  ),
                )
              else
                _buildImagePlaceholder(item),
              const SizedBox(height: 24),
              // Titre
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Plateforme et type
              Row(
                children: [
                  _buildChip(
                    item.platform,
                    Icons.play_circle_outline,
                    AppColors.kPrimary,
                  ),
                  const SizedBox(width: 8),
                  _buildChip(
                    item.type == WatchItemType.series ? 'watch_typeSeries'.tr : 'watch_typeMovie'.tr,
                    item.type == WatchItemType.series ? Icons.tv : Icons.movie,
                    item.type == WatchItemType.series
                        ? AppColors.kTypeSeries
                        : AppColors.kTypeMovie,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(item.status),
                ],
              ),
              const SizedBox(height: 24),
              // Progression (si série)
              if (item.type == WatchItemType.series) ...[
                _buildProgressSection(item),
                const SizedBox(height: 24),
              ],
              // Description
              if (item.description != null && item.description!.isNotEmpty) ...[
                _buildSectionTitle('watch_description'.tr),
                const SizedBox(height: 8),
                Text(
                  item.description!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.kTextSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Note personnelle
              if (item.personalNote != null && item.personalNote!.isNotEmpty) ...[
                _buildSectionTitle('watch_personalNote'.tr),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.kCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.kBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kShadow.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item.personalNote!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.kTextPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Actions (si en cours de visionnage)
              if (item.status == WatchItemStatus.watching &&
                  item.type == WatchItemType.series) ...[
                _buildSectionTitle('watch_actions'.tr),
                const SizedBox(height: 16),
                _buildActionButtons(item),
                const SizedBox(height: 24),
              ],
              // Marquer comme terminé (si pas déjà terminé)
              if (item.status != WatchItemStatus.completed)
                SizedBox(
                  width: double.infinity,
                  child: AdaptiveButton(
                    text: 'watch_markAsCompleted'.tr,
                    onPressed: controller.markAsCompleted,
                    backgroundColor: AppColors.kSuccess,
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildImagePlaceholder(WatchItem item) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.kSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        item.type == WatchItemType.series ? Icons.tv : Icons.movie,
        size: 80,
        color: AppColors.kTextSecondary,
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(WatchItemStatus status) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case WatchItemStatus.watching:
        statusColor = AppColors.kStatusWatching;
        statusLabel = 'watch_statusWatching'.tr;
        statusIcon = Icons.play_circle;
        break;
      case WatchItemStatus.completed:
        statusColor = AppColors.kStatusCompleted;
        statusLabel = 'watch_statusCompleted'.tr;
        statusIcon = Icons.check_circle;
        break;
      case WatchItemStatus.planned:
        statusColor = AppColors.kStatusPlanned;
        statusLabel = 'watch_statusPlanned'.tr;
        statusIcon = Icons.schedule;
        break;
    }

    return _buildChip(statusLabel, statusIcon, statusColor);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.kTextPrimary,
      ),
    );
  }

  Widget _buildProgressSection(WatchItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.kCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.kBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kShadow.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('watch_progress'.tr),
          const SizedBox(height: 16),
          if (item.currentSeason != null)
            _buildProgressRow(
              'watch_currentSeason'.tr,
              item.currentSeason.toString(),
            ),
          if (item.currentEpisode != null)
            _buildProgressRow(
              'watch_currentEpisode'.tr,
              item.currentEpisode.toString(),
            ),
          if (item.seasonsCount != null)
            _buildProgressRow(
              'watch_seasonsCount'.tr,
              item.seasonsCount.toString(),
            ),
          if (item.lastWatchedAt != null)
            _buildProgressRow(
              'watch_lastWatched'.tr,
              _formatDate(item.lastWatchedAt!),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.kTextSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(WatchItem item) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AdaptiveButton(
            text: 'watch_incrementEpisode'.tr,
            onPressed: controller.incrementEpisode,
            backgroundColor: AppColors.kPrimary,
          ),
        ),
        if (item.currentSeason != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AdaptiveButton(
              text: 'watch_nextSeason'.tr,
              onPressed: controller.nextSeason,
              backgroundColor: AppColors.kInfo,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
