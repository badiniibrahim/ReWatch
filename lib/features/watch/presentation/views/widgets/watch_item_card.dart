import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rewatch/core/config/app_colors.dart';
import 'package:rewatch/features/watch/domain/entities/watch_item.dart';

/// Carte affichant un WatchItem dans la liste
class WatchItemCard extends StatelessWidget {
  final WatchItem item;
  final VoidCallback onTap;

  const WatchItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image ou placeholder
            _buildImage(),
            const SizedBox(width: 16),
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        item.type == WatchItemType.series
                            ? Icons.tv
                            : Icons.movie,
                        item.type == WatchItemType.series
                            ? AppColors.kTypeSeries
                            : AppColors.kTypeMovie,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Statut
                  _buildStatusChip(),
                  // Progression (si série en cours)
                  if (item.type == WatchItemType.series &&
                      item.status == WatchItemStatus.watching &&
                      item.currentSeason != null &&
                      item.currentEpisode != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'watch_seasonEpisode'.tr.replaceAll('{season}', item.currentSeason.toString()).replaceAll('{episode}', item.currentEpisode.toString()),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.kTextSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (item.image != null && item.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.image!,
          width: 80,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.kSurfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        item.type == WatchItemType.series ? Icons.tv : Icons.movie,
        color: AppColors.kTextSecondary,
        size: 40,
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (item.status) {
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
}
