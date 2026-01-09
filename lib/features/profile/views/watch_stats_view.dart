import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:rewatch/core/config/app_colors.dart';
import 'package:rewatch/core/widgets/adaptive_widgets.dart';
import 'package:rewatch/core/widgets/platform_logo_helper.dart';
import 'package:rewatch/features/watch/domain/entities/watch_item.dart';
import 'package:rewatch/features/watch/presentation/controllers/watch_home_controller.dart';

class WatchStatsView extends StatelessWidget {
  const WatchStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final watchController = Get.find<WatchHomeController>();

    return AdaptiveScaffold(
      title: 'profile_stats_title'.tr,
      backgroundColor: AppColors.kBackground,
      body: Obx(() {
        final items = watchController.allItems.toList();
        final stats = _calculateStats(items);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Total
              _buildHeroTotal(stats['total'] as int),

              const SizedBox(height: 24),

              // 2. Status Grid
              Text(
                'profile_stats_breakdown'.tr.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.kTextSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: FluentIcons.play_circle_24_filled,
                      label: 'profile_stats_watching'.tr,
                      value: stats['watching'].toString(),
                      color: AppColors.kStatusWatching,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: FluentIcons.checkmark_circle_24_filled,
                      label: 'profile_stats_completed'.tr,
                      value: stats['completed'].toString(),
                      color: AppColors.kStatusCompleted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: FluentIcons.clock_24_filled,
                      label: 'profile_stats_planned'.tr,
                      value: stats['planned'].toString(),
                      color: AppColors.kStatusPlanned,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Spacer or potentially another metric like "Movies vs Series"
                  Expanded(
                    child: _buildStatCard(
                      icon: FluentIcons.movies_and_tv_24_filled,
                      label: 'watch_filterSeries'.tr,
                      value: stats['seriesCount'].toString(),
                      color: AppColors.kTypeSeries,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. Top Platforms
              Text(
                'profile_stats_top_platforms'.tr.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.kTextSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildPlatformList(stats['platformCounts'] as Map<String, int>),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroTotal(int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.kSurfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.kPrimary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.kPrimary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'profile_stats_total'.tr,
            style: const TextStyle(
              color: AppColors.kTextSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            total.toString(),
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: AppColors.kPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'profile_stats_items_tracked'.tr,
            style: const TextStyle(
              color: AppColors.kTextSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformList(Map<String, int> platformCounts) {
    // Sort by count descending
    final sortedPlatforms = platformCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedPlatforms.isEmpty) {
      return Text(
        'watch_noContent'.tr,
        style: const TextStyle(color: AppColors.kTextSecondary),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.kSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < sortedPlatforms.length && i < 5; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: AppColors.kBorder.withValues(alpha: 0.3),
                indent: 56,
              ),
            ListTile(
              leading: PlatformLogoHelper.getLogo(
                sortedPlatforms[i].key,
                size: 32,
              ),
              title: Text(
                sortedPlatforms[i].key,
                style: const TextStyle(
                  color: AppColors.kTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${sortedPlatforms[i].value}',
                  style: const TextStyle(
                    color: AppColors.kPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<WatchItem> items) {
    final total = items.length;
    final watching = items
        .where((i) => i.status == WatchItemStatus.watching)
        .length;
    final completed = items
        .where((i) => i.status == WatchItemStatus.completed)
        .length;
    final planned = items
        .where((i) => i.status == WatchItemStatus.planned)
        .length;
    final seriesCount = items
        .where((i) => i.type == WatchItemType.series)
        .length;

    // Platform counts
    final platformCounts = <String, int>{};
    for (var item in items) {
      platformCounts[item.platform] = (platformCounts[item.platform] ?? 0) + 1;
    }

    return {
      'total': total,
      'watching': watching,
      'completed': completed,
      'planned': planned,
      'seriesCount': seriesCount,
      'platformCounts': platformCounts,
    };
  }
}
