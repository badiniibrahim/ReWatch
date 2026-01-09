import 'package:flutter/material.dart';
import 'package:rewatch/features/watch/presentation/views/watch_filters_view.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_widgets.dart';
import '../controllers/watch_home_controller.dart';
import 'widgets/watch_item_card.dart';

/// Écran Home de ReWatch - Liste des items avec recherche et filtres
class WatchHomeView extends GetView<WatchHomeController> {
  const WatchHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: AppColors.kBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildSearchBarSliver(),
          _buildContentSliver(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.shuffleItems,
        backgroundColor: AppColors.kPrimary,
        icon: const Icon(FluentIcons.sparkle_24_filled, color: Colors.white),
        label: Text(
          "Aléatoire",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.kBackground,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          'ReWatch',
          style: TextStyle(
            color: AppColors.kTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(
              FluentIcons.filter_24_regular,
              color: AppColors.kTextPrimary,
            ),
            onPressed: () => _showFilterModal(context),
            tooltip: 'watch_filters'.tr,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(
              FluentIcons.add_circle_24_filled,
              color: AppColors.kPrimary,
              size: 28,
            ),
            onPressed: controller.navigateToAdd,
            tooltip: 'common_add'.tr,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBarSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.kSurfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.kBorder.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AdaptiveTextField(
            controller: controller.searchController,
            placeholder: 'watch_searchPlaceholder'.tr,
            hintText: 'watch_searchPlaceholder'.tr,
            prefix: const Icon(
              FluentIcons.search_24_regular,
              color: AppColors.kTextSecondary,
            ),
            onChanged: (_) {}, // Géré par le listener du controller
          ),
        ),
      ),
    );
  }

  Widget _buildContentSliver() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.kPrimary),
          ),
        );
      }

      if (controller.error.value.isNotEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.error_circle_24_regular,
                  size: 48,
                  color: AppColors.kError,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.error.value,
                  style: const TextStyle(color: AppColors.kError),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AdaptiveButton(
                  text: 'common_retry'.tr,
                  onPressed: () => controller.loadItems(),
                  backgroundColor: AppColors.kSurfaceElevated,
                ),
              ],
            ),
          ),
        );
      }

      if (controller.filteredItems.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image d'état vide
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.kSurfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FluentIcons.movies_and_tv_24_regular,
                      size: 64,
                      color: AppColors.kTextSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    controller.searchQuery.value.isNotEmpty ||
                            controller.selectedType.value != null ||
                            controller.selectedStatus.value != null ||
                            controller.selectedPlatform.value.isNotEmpty
                        ? 'watch_noResults'.tr
                        : 'watch_noContent'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.searchQuery.value.isNotEmpty ||
                            controller.selectedType.value != null ||
                            controller.selectedStatus.value != null ||
                            controller.selectedPlatform.value.isNotEmpty
                        ? 'watch_tmdbNoResultsHint'.tr
                        : "Commencez par ajouter une série ou un film à votre liste.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.kTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (controller.searchQuery.value.isEmpty &&
                      controller.selectedType.value == null &&
                      controller.selectedStatus.value == null &&
                      controller.selectedPlatform.value.isEmpty)
                    AdaptiveButton(
                      text: "Ajouter un contenu",
                      onPressed: controller.navigateToAdd,
                      backgroundColor: AppColors.kPrimary,
                      width: 200,
                    ),

                  if (controller.searchQuery.value.isNotEmpty ||
                      controller.selectedType.value != null ||
                      controller.selectedStatus.value != null ||
                      controller.selectedPlatform.value.isNotEmpty)
                    TextButton.icon(
                      onPressed: controller.resetFilters,
                      icon: const Icon(
                        FluentIcons.dismiss_circle_24_regular,
                        color: AppColors.kPrimary,
                      ),
                      label: Text(
                        'watch_resetFiltersButton'.tr,
                        style: const TextStyle(color: AppColors.kPrimary),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio:
                0.65, // Aspect ratio standard for poster cards + text
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = controller.filteredItems[index];
            return WatchItemCard(
              item: item,
              onTap: () => controller.navigateToDetail(item.id),
            );
          }, childCount: controller.filteredItems.length),
        ),
      );
    });
  }

  void _showFilterModal(BuildContext context) {
    Get.to(
      () => const WatchFiltersView(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
      binding: BindingsBuilder(() {
        // Le contrôleur est déjà en mémoire via WatchHomeView,
        // GetView le trouvera automatiquement.
      }),
    );
  }
}
