import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:rewatch/core/config/app_colors.dart';
import 'package:rewatch/core/widgets/adaptive_button.dart';
import 'package:rewatch/core/widgets/adaptive_scaffold.dart';
import 'package:rewatch/core/widgets/platform_logo_helper.dart';
import 'package:rewatch/features/watch/presentation/controllers/watch_item_detail_controller.dart';
import '../../domain/entities/watch_item.dart';

/// Écran de détail d'un WatchItem (Refonte Pro)
class WatchItemDetailView extends GetView<WatchItemDetailController> {
  const WatchItemDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: AppColors.kBackground,
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
                const Icon(
                  FluentIcons.error_circle_48_regular,
                  size: 48,
                  color: AppColors.kError,
                ),
                const SizedBox(height: 16),
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
          return Center(child: Text('watch_itemNotFound'.tr));
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- HUGE HEADER ---
            SliverAppBar(
              expandedHeight: 400.0,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.kBackground,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildAppBarButton(
                  icon: FluentIcons.arrow_left_24_filled,
                  onTap: () => Get.back(),
                ),
              ),
              actions: [
                _buildAppBarButton(
                  icon: FluentIcons.edit_24_filled,
                  onTap: controller.navigateToEdit,
                  tooltip: 'Modifier',
                ),
                const SizedBox(width: 8),
                Obx(
                  () => _buildAppBarButton(
                    icon: FluentIcons.delete_24_filled,
                    iconColor: AppColors.kError,
                    onTap: controller.deleteItem,
                    isLoading: controller.isDeleting.value,
                    tooltip: 'Supprimer',
                  ),
                ),
                const SizedBox(width: 16),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image Background
                    Hero(
                      tag: 'item_${item.id}',
                      child: _buildHeaderImage(item),
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.2),
                            AppColors.kBackground.withValues(alpha: 0.8),
                            AppColors.kBackground,
                          ],
                          stops: const [0.0, 0.5, 0.85, 1.0],
                        ),
                      ),
                    ),
                    // Bottom Info
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges Row
                          Row(
                            children: [
                              PlatformLogoHelper.getLogo(
                                item.platform,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              _buildMiniBadge(
                                item.type == WatchItemType.series
                                    ? 'watch_typeSeries'.tr
                                    : 'watch_typeMovie'.tr,
                                item.type == WatchItemType.series
                                    ? AppColors.kTypeSeries
                                    : AppColors.kTypeMovie,
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(item.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Title
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- CONTENT BODY ---
            SliverToBoxAdapter(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // ... rest of the children ...
                      // Since I cannot match the entire content reliably with replacement,
                      // I should try to target the start of the SliverToBoxAdapter to wrap it.
                      // Wait, I should not use 'child: Padding' inside replacement if I can't include the whole block.
                      // I will rewrite the surrounding block to include the animation wrapper.

                      // QUICK STATS / PROGRESS FOR SERIES
                      // Show for any series so user can track/see progress even if Planned
                      if (item.type == WatchItemType.series) ...[
                        _buildProgressCard(item),
                        const SizedBox(height: 24),
                      ],

                      // SYNOPSIS
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        Text(
                          'SYNOPSIS',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.kTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description!,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: AppColors.kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // NOTES
                      if (item.personalNote != null &&
                          item.personalNote!.isNotEmpty) ...[
                        _buildInfoCard(
                          title: 'watch_personalNote'.tr,
                          icon: FluentIcons.note_24_regular,
                          content: item.personalNote!,
                          color: AppColors.kPrimary.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // METADATA GRID
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildMetadataItem(
                            'Ajouté le',
                            _formatDate(item.createdAt),
                          ),
                          if (item.lastWatchedAt != null)
                            _buildMetadataItem(
                              'Vu le',
                              _formatDate(item.lastWatchedAt!),
                            ),
                          if (item.type == WatchItemType.series &&
                              item.seasonsCount != null)
                            _buildMetadataItem(
                              'Saisons',
                              '${item.seasonsCount}',
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ACTIONS
                      if (item.status != WatchItemStatus.completed)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: AdaptiveButton(
                              text: 'watch_markAsCompleted'.tr,
                              onPressed: controller.markAsCompleted,
                              backgroundColor: AppColors.kSuccess,
                              // icon: FluentIcons.checkmark_circle_24_filled,
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderImage(WatchItem item) {
    if (item.image != null && item.image!.isNotEmpty) {
      // Check if it's a URL or local path
      bool isUrl = item.image!.startsWith('http');
      return isUrl
          ? Image.network(item.image!, fit: BoxFit.cover)
          : Image.file(File(item.image!), fit: BoxFit.cover);
    }
    return Container(
      color: AppColors.kSurfaceVariant,
      child: Center(
        child: Icon(
          item.type == WatchItemType.series
              ? FluentIcons.movies_and_tv_24_regular
              : FluentIcons.video_24_regular,
          size: 80,
          color: AppColors.kTextSecondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppColors.kTextSecondary.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.kTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(WatchItemStatus status) {
    Color color;
    String text;
    switch (status) {
      case WatchItemStatus.watching:
        color = AppColors.kStatusWatching;
        text = 'Watching';
        break;
      case WatchItemStatus.completed:
        color = AppColors.kStatusCompleted;
        text = 'Terminé';
        break;
      case WatchItemStatus.planned:
        color = AppColors.kStatusPlanned;
        text = 'À voir';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProgressCard(WatchItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kSurfaceElevated,
            AppColors.kSurfaceElevated.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.kBorder.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SEASON COLUMN (Left) ---
          Expanded(
            child: Column(
              children: [
                const Text(
                  "SAISON",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.currentSeason ?? 1}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.kTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickActionButton(
                  label: '+ Saison',
                  onTap: controller.nextSeason,
                  color: AppColors.kSurfaceVariant,
                  textColor: AppColors.kTextPrimary,
                ),
              ],
            ),
          ),

          // DIVIDER
          Container(
            width: 1,
            height: 80,
            color: AppColors.kBorder.withValues(alpha: 0.5),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // --- EPISODE COLUMN (Right) ---
          Expanded(
            child: Column(
              children: [
                const Text(
                  "ÉPISODE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.currentEpisode ?? 1}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.kTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickActionButton(
                  label: '+ Épisode',
                  onTap: controller.incrementEpisode,
                  color: AppColors.kPrimary,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? AppColors.kSurfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.kTextSecondary),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: AppColors.kTextPrimary, // Ensuring Text is visible
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    String? tooltip,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, color: iconColor ?? Colors.white, size: 20),
      ),
    );
  }
}
