import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:rewatch/core/widgets/platform_logo_helper.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_widgets.dart';
import '../controllers/watch_item_form_controller.dart';
import '../../domain/entities/watch_item.dart';

/// Écran de formulaire pour ajouter/éditer un WatchItem (Refonte Pro)
class WatchItemFormView extends GetView<WatchItemFormController> {
  const WatchItemFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: AppColors.kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.kBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                FluentIcons.arrow_left_24_regular,
                color: AppColors.kTextPrimary,
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              title: Text(
                controller.isEditing ? 'watch_formEdit'.tr : 'watch_formAdd'.tr,
                style: const TextStyle(
                  color: AppColors.kTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: false,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error Banner
                  Obx(() {
                    if (controller.error.value.isNotEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.kError.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.kError.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FluentIcons.error_circle_24_filled,
                              color: AppColors.kError,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controller.error.value,
                                style: const TextStyle(
                                  color: AppColors.kError,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // --- SECTION: TYPE ---
                  _buildFormCard(
                    title: 'watch_formType'.tr,
                    icon: FluentIcons.movies_and_tv_24_regular,
                    child: Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _buildSelectionCard(
                              label: 'watch_typeMovie'.tr,
                              icon: FluentIcons.video_24_regular,
                              isSelected:
                                  controller.selectedType.value ==
                                  WatchItemType.movie,
                              onTap: () => controller.selectedType.value =
                                  WatchItemType.movie,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSelectionCard(
                              label: 'watch_typeSeries'.tr,
                              icon: FluentIcons.movies_and_tv_24_regular,
                              isSelected:
                                  controller.selectedType.value ==
                                  WatchItemType.series,
                              onTap: () => controller.selectedType.value =
                                  WatchItemType.series,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION: DETAILS PRINCIPAUX ---
                  _buildFormCard(
                    title: "Détails",
                    icon: FluentIcons.info_24_regular,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field with TMDB Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'watch_formTitle'.tr,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.kTextSecondary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: controller.showTmdbSearch,
                              icon: const Icon(
                                FluentIcons.sparkle_20_filled,
                                size: 16,
                                color: AppColors.kPrimary,
                              ),
                              label: Text(
                                'watch_fillWithTmdb'.tr,
                                style: const TextStyle(
                                  color: AppColors.kPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AdaptiveTextField(
                          controller: controller.titleController,
                          placeholder: 'Ex: Breaking Bad',
                        ),

                        const SizedBox(height: 20),

                        // Platform Field
                        Text(
                          'watch_formPlatform'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.kTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: controller.showPlatformSelection,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.kBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.kBorder),
                            ),
                            child: Row(
                              children: [
                                if (controller
                                    .platformController
                                    .text
                                    .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: PlatformLogoHelper.getLogo(
                                      controller.platformController.text,
                                      size: 24,
                                    ),
                                  )
                                else
                                  const Icon(
                                    FluentIcons.tv_24_regular,
                                    color: AppColors.kTextSecondary,
                                    size: 20,
                                  ),

                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller
                                            .platformController
                                            .text
                                            .isNotEmpty
                                        ? controller.platformController.text
                                        : 'watch_formPlatformPlaceholder'.tr,
                                    style: TextStyle(
                                      color:
                                          controller
                                              .platformController
                                              .text
                                              .isNotEmpty
                                          ? AppColors.kTextPrimary
                                          : AppColors.kTextSecondary.withValues(
                                              alpha: 0.5,
                                            ),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  FluentIcons.chevron_down_24_regular,
                                  color: AppColors.kTextSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION: STATUS ---
                  _buildFormCard(
                    title: 'watch_formStatus'.tr,
                    icon: FluentIcons.tasks_app_24_regular,
                    child: Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.start,
                          children: [
                            _buildStatusChip(
                              label: 'watch_statusPlanned'.tr,
                              status: WatchItemStatus.planned,
                              icon: FluentIcons.clock_24_regular,
                              isSelected:
                                  controller.selectedStatus.value ==
                                  WatchItemStatus.planned,
                            ),
                            _buildStatusChip(
                              label: 'watch_statusWatching'.tr,
                              status: WatchItemStatus.watching,
                              icon: FluentIcons.play_circle_24_regular,
                              isSelected:
                                  controller.selectedStatus.value ==
                                  WatchItemStatus.watching,
                            ),
                            _buildStatusChip(
                              label: 'watch_statusCompleted'.tr,
                              status: WatchItemStatus.completed,
                              icon: FluentIcons.checkmark_circle_24_regular,
                              isSelected:
                                  controller.selectedStatus.value ==
                                  WatchItemStatus.completed,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION: PROGRESSION (Séries seulement) ---
                  Obx(() {
                    if (controller.selectedType.value == WatchItemType.series) {
                      return Column(
                        children: [
                          _buildFormCard(
                            title: "Progression",
                            icon: FluentIcons.data_bar_horizontal_24_regular,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNumberInput(
                                        label: 'Saisons',
                                        controller:
                                            controller.seasonsCountController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberInput(
                                        label: 'Saison actuelle',
                                        controller:
                                            controller.currentSeasonController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildNumberInput(
                                        label: 'Épisode',
                                        controller:
                                            controller.currentEpisodeController,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // --- SECTION: NOTES & IMAGE ---
                  _buildFormCard(
                    title: "Personnel",
                    icon: FluentIcons.note_24_regular,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdaptiveTextField(
                          controller: controller.personalNoteController,
                          placeholder: 'watch_formPersonalNotePlaceholder'.tr,
                          hintText: 'Une petite note pour vous-même...',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        AdaptiveTextField(
                          controller: controller.descriptionController,
                          placeholder: 'watch_formDescriptionPlaceholder'.tr,
                          hintText: 'Synopsis ou résumé...',
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Image Picker Area
                  _buildImagePicker(),

                  const SizedBox(height: 40),

                  // Save Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppColors.kPrimary.withValues(
                            alpha: 0.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                controller.isEditing
                                    ? 'watch_formEdit'.tr
                                    : 'watch_formAdd'.tr,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kSurfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.kBorder.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.kPrimary, size: 20),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.kTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kPrimary : AppColors.kBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.kPrimary : AppColors.kBorder,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.kPrimary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : AppColors.kTextSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.kTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required WatchItemStatus status,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => controller.selectedStatus.value = status,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.kPrimary.withValues(alpha: 0.1)
              : AppColors.kBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.kPrimary : AppColors.kBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.kPrimary : AppColors.kTextSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.kPrimary
                    : AppColors.kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.kTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        AdaptiveTextField(
          controller: controller,
          placeholder: '0',
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "IMAGE DE COUVERTURE",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.kTextSecondary,
              ),
            ),
            Obx(() {
              if (controller.selectedImage.value != null ||
                  controller.imageController.text.isNotEmpty) {
                return TextButton(
                  onPressed: controller.removeImage,
                  child: Text(
                    "Supprimer",
                    style: TextStyle(color: AppColors.kError, fontSize: 12),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        const SizedBox(height: 12),

        Obx(() {
          // Cas: Image Fichier local sélectionnée
          if (controller.selectedImage.value != null) {
            return _buildImageContainer(
              imageProvider: FileImage(controller.selectedImage.value!),
            );
          }
          // Cas: Image URL TMDB
          else if (controller.imageController.text.isNotEmpty) {
            return _buildImageContainer(
              imageProvider: NetworkImage(controller.imageController.text),
            );
          }
          // Cas: Aucune image
          else {
            return InkWell(
              onTap: controller.pickImage,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.kSurfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.kBorder,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.kBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        FluentIcons.image_add_24_regular,
                        size: 32,
                        color: AppColors.kPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'watch_selectImage'.tr,
                      style: const TextStyle(
                        color: AppColors.kTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildImageContainer({required ImageProvider imageProvider}) {
    return GestureDetector(
      onTap: controller.pickImage, // Allow changing image by tapping on it
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
            ),
          ),
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: const Icon(
              FluentIcons.edit_24_regular,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
