import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_colors.dart';
import '../../watch/domain/entities/watch_item.dart';

class WatchStatsWidget extends StatelessWidget {
  final List<WatchItem> items;

  const WatchStatsWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.kStatsGradientStart, AppColors.kStatsGradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.kPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.kPrimary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.kPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.kPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'profile_stats_title'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Grid de stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.movie_filter,
                  label: 'profile_stats_total'.tr,
                  value: stats['total'].toString(),
                  color: AppColors.kPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.play_circle,
                  label: 'profile_stats_watching'.tr,
                  value: stats['watching'].toString(),
                  color: AppColors.kStatusWatching,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'profile_stats_completed'.tr,
                  value: stats['completed'].toString(),
                  color: AppColors.kStatusCompleted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule,
                  label: 'profile_stats_planned'.tr,
                  value: stats['planned'].toString(),
                  color: AppColors.kStatusPlanned,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Plateforme favorite
          if (stats['favoritePlatform'] != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.kSurfaceElevated.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.kBorder.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppColors.kWarning, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile_stats_favorite_platform'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.kTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stats['favoritePlatform'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.kTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${stats['favoritePlatformCount']} ${stats['favoritePlatformCount'] == 1 ? 'titre' : 'titres'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
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

    // Plateforme favorite
    final platformCounts = <String, int>{};
    for (var item in items) {
      platformCounts[item.platform] = (platformCounts[item.platform] ?? 0) + 1;
    }

    String? favoritePlatform;
    int favoritePlatformCount = 0;
    if (platformCounts.isNotEmpty) {
      final sorted = platformCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      favoritePlatform = sorted.first.key;
      favoritePlatformCount = sorted.first.value;
    }

    return {
      'total': total,
      'watching': watching,
      'completed': completed,
      'planned': planned,
      'favoritePlatform': favoritePlatform,
      'favoritePlatformCount': favoritePlatformCount,
    };
  }
}
