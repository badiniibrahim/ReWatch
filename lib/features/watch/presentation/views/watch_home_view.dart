import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_widgets.dart';
import '../controllers/watch_home_controller.dart';
import 'widgets/watch_item_card.dart';
import 'widgets/filter_bottom_sheet.dart';

/// Écran Home de ReWatch - Liste des items avec recherche et filtres
class WatchHomeView extends GetView<WatchHomeController> {
  const WatchHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: AppColors.kSurface,
      appBar: AppBar(
        title: const Text(
          'ReWatch',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.kTextPrimary,
          ),
        ),
        backgroundColor: AppColors.kSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.kTextPrimary),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.kTextPrimary),
            onPressed: controller.navigateToAdd,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          _buildSearchBar(),
          // Liste des items
          Expanded(
            child: Obx(() {
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
                        onPressed: () => controller.loadItems(),
                        child: Text('common_retry'.tr),
                      ),
                    ],
                  ),
                );
              }

              if (controller.filteredItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image d'état vide générée par IA
                      if (controller.searchQuery.value.isEmpty &&
                          controller.selectedType.value == null &&
                          controller.selectedStatus.value == null &&
                          controller.selectedPlatform.value.isEmpty)
                        Image.asset(
                          'assets/images/empty_library.png',
                          width: 250,
                          height: 250,
                        )
                      else
                        Icon(
                          Icons.movie_outlined,
                          size: 64,
                          color: AppColors.kTextSecondary,
                        ),
                      const SizedBox(height: 16),
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
                          color: AppColors.kTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Bouton d'ajout visible si liste vide (pas de filtres)
                      if (controller.searchQuery.value.isEmpty &&
                          controller.selectedType.value == null &&
                          controller.selectedStatus.value == null &&
                          controller.selectedPlatform.value.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ElevatedButton(
                            onPressed: controller.navigateToAdd,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Ajouter mon premier contenu"),
                          ),
                        ),

                      if (controller.searchQuery.value.isNotEmpty ||
                          controller.selectedType.value != null ||
                          controller.selectedStatus.value != null ||
                          controller.selectedPlatform.value.isNotEmpty)
                        TextButton(
                          onPressed: controller.resetFilters,
                          child: Text('watch_resetFiltersButton'.tr),
                        ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredItems.length,
                itemBuilder: (context, index) {
                  final item = controller.filteredItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: WatchItemCard(
                      item: item,
                      onTap: () => controller.navigateToDetail(item.id),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.kSurface,
      child: AdaptiveTextField(
        controller: TextEditingController(text: controller.searchQuery.value)
          ..selection = TextSelection.collapsed(
            offset: controller.searchQuery.value.length,
          ),
        placeholder: 'watch_searchPlaceholder'.tr,
        hintText: 'watch_searchPlaceholder'.tr,
        prefix: const Icon(Icons.search, color: AppColors.kTextSecondary),
        onChanged: controller.updateSearch,
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(controller: controller),
    );
  }
}
