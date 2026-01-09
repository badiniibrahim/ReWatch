import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/services/tmdb_service.dart';
import '../controllers/explore_controller.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ExploreController>()) {
      Get.put(ExploreController());
    }

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Explorer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              FluentIcons.search_24_regular,
              color: Colors.white,
            ),
            onPressed: () {
              // Open search delegate or navigate to search
              Get.toNamed('/watch/add'); // Use existing add/search view for now
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.kPrimary),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadData,
          backgroundColor: AppColors.kSurface,
          color: AppColors.kPrimary,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // --- TRENDING SECTION ---
                _buildSectionHeader('Tendance cette semaine'),
                const SizedBox(height: 16),
                _buildHorizontalCarousel(controller.trendingItems),

                const SizedBox(height: 32),

                // --- NOW PLAYING SECTION ---
                _buildSectionHeader('Au cinéma'),
                const SizedBox(height: 16),
                _buildHorizontalCarousel(controller.nowPlayingItems),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHorizontalCarousel(List<TmdbResult> items) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Aucun contenu disponible',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => controller.openDetails(item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.kSurface,
                        image: item.posterUrl != null
                            ? DecorationImage(
                                image: NetworkImage(item.posterUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: item.posterUrl == null
                          ? const Center(
                              child: Icon(Icons.movie, color: Colors.grey),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Rating/Type
                  Row(
                    children: [
                      Icon(
                        item.type == 'movie'
                            ? FluentIcons.movies_and_tv_16_regular
                            : FluentIcons.video_16_regular,
                        size: 14,
                        color: AppColors.kTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.type == 'movie' ? 'Film' : 'Série',
                        style: const TextStyle(
                          color: AppColors.kTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (item.rating != null) ...[
                        const Icon(
                          FluentIcons.star_16_filled,
                          size: 12,
                          color: AppColors.kRating,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.kRating,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
