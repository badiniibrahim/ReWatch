import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/adaptive_widgets.dart';
import '../controllers/watch_item_form_controller.dart';
import '../../domain/entities/watch_item.dart';

/// Écran de formulaire pour ajouter/éditer un WatchItem
class WatchItemFormView extends GetView<WatchItemFormController> {
  const WatchItemFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      backgroundColor: AppColors.kSurface,
      appBar: AppBar(
        title: Text(
          controller.isEditing ? 'watch_formEdit'.tr : 'watch_formAdd'.tr,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.kTextPrimary,
          ),
        ),
        backgroundColor: AppColors.kSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Erreur
            Obx(
              () => controller.error.value.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.kErrorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.error.value,
                        style: const TextStyle(color: AppColors.kError),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // Type (Série/Film)
            _buildSectionTitle('watch_formType'.tr),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildTypeChip(
                      label: 'watch_typeMovie'.tr,
                      type: WatchItemType.movie,
                      selected:
                          controller.selectedType.value == WatchItemType.movie,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeChip(
                      label: 'watch_typeSeries'.tr,
                      type: WatchItemType.series,
                      selected:
                          controller.selectedType.value == WatchItemType.series,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Titre (obligatoire)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('watch_formTitle'.tr),
                TextButton.icon(
                  onPressed: controller.showTmdbSearch,
                  icon: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.kPrimary,
                  ),
                  label: Text(
                    'watch_fillWithTmdb'.tr,
                    style: const TextStyle(color: AppColors.kPrimary, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AdaptiveTextField(
              controller: controller.titleController,
              placeholder: 'watch_formTitlePlaceholder'.tr,
              hintText: 'watch_formTitlePlaceholder'.tr,
            ),
            const SizedBox(height: 24),
            // Plateforme (obligatoire)
            _buildSectionTitle('watch_formPlatform'.tr),
            const SizedBox(height: 8),
            AdaptiveTextField(
              controller: controller.platformController,
              placeholder: 'watch_formPlatformPlaceholder'.tr,
              hintText: 'watch_formPlatformPlaceholder'.tr,
              readOnly: true,
              onTap: controller.showPlatformSelection,
              suffix: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.kTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Statut
            _buildSectionTitle('watch_formStatus'.tr),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatusChip(
                    label: 'watch_statusPlanned'.tr,
                    status: WatchItemStatus.planned,
                    selected:
                        controller.selectedStatus.value ==
                        WatchItemStatus.planned,
                  ),
                  _buildStatusChip(
                    label: 'watch_statusWatching'.tr,
                    status: WatchItemStatus.watching,
                    selected:
                        controller.selectedStatus.value ==
                        WatchItemStatus.watching,
                  ),
                  _buildStatusChip(
                    label: 'watch_statusCompleted'.tr,
                    status: WatchItemStatus.completed,
                    selected:
                        controller.selectedStatus.value ==
                        WatchItemStatus.completed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Champs conditionnels pour les séries
            Obx(
              () => controller.selectedType.value == WatchItemType.series
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('watch_formSeasonsCount'.tr),
                        const SizedBox(height: 8),
                        AdaptiveTextField(
                          controller: controller.seasonsCountController,
                          placeholder: 'watch_formOptional'.tr,
                          hintText: 'watch_formOptional'.tr,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle('watch_formCurrentSeason'.tr),
                        const SizedBox(height: 8),
                        AdaptiveTextField(
                          controller: controller.currentSeasonController,
                          placeholder: 'watch_formOptional'.tr,
                          hintText: 'watch_formOptional'.tr,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle('watch_formCurrentEpisode'.tr),
                        const SizedBox(height: 8),
                        AdaptiveTextField(
                          controller: controller.currentEpisodeController,
                          placeholder: 'watch_formOptional'.tr,
                          hintText: 'watch_formOptional'.tr,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            // Description
            _buildSectionTitle('watch_formDescription'.tr),
            const SizedBox(height: 8),
            AdaptiveTextField(
              controller: controller.descriptionController,
              placeholder: 'watch_formDescriptionPlaceholder'.tr,
              hintText: 'watch_formDescriptionPlaceholder'.tr,
            ),
            const SizedBox(height: 24),
            // Note personnelle
            _buildSectionTitle('watch_formPersonalNote'.tr),
            const SizedBox(height: 8),
            AdaptiveTextField(
              controller: controller.personalNoteController,
              placeholder: 'watch_formPersonalNotePlaceholder'.tr,
              hintText: 'watch_formPersonalNotePlaceholder'.tr,
            ),
            const SizedBox(height: 24),
            // Image
            _buildSectionTitle('watch_formImage'.tr),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.selectedImage.value != null) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        controller.selectedImage.value!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: AppColors.kError),
                      label: Text(
                        'watch_deleteImage'.tr,
                        style: const TextStyle(color: AppColors.kError),
                      ),
                      onPressed: controller.removeImage,
                    ),
                  ],
                );
              } else if (controller.imageController.text.isNotEmpty) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        controller.imageController.text,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.error)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: AppColors.kError),
                      label: Text(
                        'watch_deleteImage'.tr,
                        style: const TextStyle(color: AppColors.kError),
                      ),
                      onPressed: controller.removeImage,
                    ),
                  ],
                );
              } else {
                return InkWell(
                  onTap: controller.pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.kSurfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.kBorder),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: AppColors.kTextSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'watch_selectImage'.tr,
                            style: const TextStyle(color: AppColors.kTextSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }),
            const SizedBox(height: 32),
            // Bouton sauvegarder
            Obx(
              () => AdaptiveButton(
                text: controller.isEditing
                    ? 'watch_formEdit'.tr
                    : 'watch_formAdd'.tr,
                onPressed: controller.isLoading.value
                    ? null
                    : controller.saveItem,
                backgroundColor: AppColors.kPrimary,
                isLoading: controller.isLoading.value,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.kTextPrimary,
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required WatchItemType type,
    required bool selected,
  }) {
    return InkWell(
      onTap: () => controller.selectedType.value = type,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.kPrimary : AppColors.kSurfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.kPrimary : AppColors.kBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.kTextPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required WatchItemStatus status,
    required bool selected,
  }) {
    return InkWell(
      onTap: () => controller.selectedStatus.value = status,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.kPrimary : AppColors.kSurfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.kPrimary : AppColors.kBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.kTextPrimary,
          ),
        ),
      ),
    );
  }
}
