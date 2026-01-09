import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:rewatch/core/config/app_colors.dart';
import 'package:rewatch/core/widgets/platform_logo_helper.dart';
import 'package:rewatch/features/watch/domain/entities/watch_item.dart';

/// Carte affichant un WatchItem dans la grille (Style Poster)
class WatchItemCard extends StatelessWidget {
  final WatchItem item;
  final VoidCallback onTap;

  const WatchItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.kSurfaceElevated,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Area (Poster)
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'item_${item.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: _buildImage(context),
                    ),
                  ),
                  // Overlay Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Status Badge (Top Right)
                  Positioned(top: 8, right: 8, child: _buildStatusBadge()),
                  // Type Badge (Top Left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        item.type == WatchItemType.series
                            ? FluentIcons.movies_and_tv_16_filled
                            : FluentIcons.video_16_filled,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kTextPrimary,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    // Metadata Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.type == WatchItemType.series &&
                            item.status == WatchItemStatus.watching &&
                            item.currentSeason != null &&
                            item.currentEpisode != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              'S${item.currentSeason} E${item.currentEpisode}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.kTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            PlatformLogoHelper.getLogo(item.platform, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.platform,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.kTextSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (item.image != null && item.image!.isNotEmpty) {
      return Image.network(
        item.image!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.kSurfaceElevated,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.kPrimary,
              ),
            ),
          );
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.kPrimary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          item.type == WatchItemType.series
              ? FluentIcons.movies_and_tv_24_regular
              : FluentIcons.video_24_regular,
          color: AppColors.kPrimary.withValues(alpha: 0.4),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    IconData icon;

    switch (item.status) {
      case WatchItemStatus.watching:
        color = AppColors.kStatusWatching;
        icon = FluentIcons.play_circle_24_filled;
        break;
      case WatchItemStatus.completed:
        color = AppColors.kStatusCompleted;
        icon = FluentIcons.checkmark_circle_24_filled;
        break;
      case WatchItemStatus.planned:
        color = AppColors.kStatusPlanned;
        icon = FluentIcons.clock_24_filled;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
        ],
      ),
      child: Icon(icon, size: 10, color: Colors.white),
    );
  }
}
