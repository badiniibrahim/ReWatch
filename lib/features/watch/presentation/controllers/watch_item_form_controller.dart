import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../domain/entities/watch_item.dart';
import '../../domain/repositories/iwatch_items_repository.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/widgets/adaptive_dialog.dart';
import '../../../../core/widgets/adaptive_text_field.dart';
import '../../../../core/config/app_colors.dart';

/// Controller pour le formulaire d'ajout/édition d'un WatchItem
class WatchItemFormController extends GetxController {
  final IWatchItemsRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageService _imageService = ImageService(); // Service d'image
  final WatchItem? _editingItem;

  WatchItemFormController({
    required IWatchItemsRepository repository,
    WatchItem? editingItem,
  }) : _repository = repository,
       _editingItem = editingItem;

  // Controllers pour les champs
  final titleController = TextEditingController();
  final platformController = TextEditingController();
  final descriptionController = TextEditingController();
  final personalNoteController = TextEditingController();
  // imageController reste utile pour stocker l'URL finale ou existante
  final imageController = TextEditingController();
  final seasonsCountController = TextEditingController();
  final currentSeasonController = TextEditingController();
  final currentEpisodeController = TextEditingController();

  // États
  final Rx<WatchItemType> selectedType = WatchItemType.movie.obs;
  final Rx<WatchItemStatus> selectedStatus = WatchItemStatus.planned.obs;
  final Rx<File?> selectedImage = Rx<File?>(null); // Image locale sélectionnée
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  bool get isEditing => _editingItem != null;

  @override
  void onInit() {
    super.onInit();
    if (_editingItem != null) {
      _populateForm(_editingItem!);
    }
  }

  void _populateForm(WatchItem item) {
    titleController.text = item.title;
    platformController.text = item.platform;
    descriptionController.text = item.description ?? '';
    personalNoteController.text = item.personalNote ?? '';
    imageController.text = item.image ?? '';
    selectedType.value = item.type;
    selectedStatus.value = item.status;
    selectedImage.value = null; // Reset image locale
    if (item.seasonsCount != null) {
      seasonsCountController.text = item.seasonsCount.toString();
    }
    if (item.currentSeason != null) {
      currentSeasonController.text = item.currentSeason.toString();
    }
    if (item.currentEpisode != null) {
      currentEpisodeController.text = item.currentEpisode.toString();
    }
  }

  static const List<String> platforms = [
    'Netflix',
    'Disney+',
    'Amazon Prime Video',
    'Apple TV+',
    'HBO Max',
    'Hulu',
    'Canal+',
    'Paramount+',
    'YouTube',
    'Crunchyroll',
    'Autre...',
  ];

  void showPlatformSelection() {
    AdaptiveDialog.show(
      context: Get.context!,
      title: 'Choisir une plateforme',
      contentWidget: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: platforms.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final platform = platforms[index];
            return ListTile(
              title: Text(
                platform,
                style: const TextStyle(color: AppColors.kTextPrimary),
              ),
              onTap: () {
                Get.back(); // Close dialog
                if (platform == 'Autre...') {
                  _showCustomPlatformDialog();
                } else {
                  platformController.text = platform;
                }
              },
            );
          },
        ),
      ),
      actions: [AdaptiveDialogAction(text: 'Annuler')],
    );
  }

  void _showCustomPlatformDialog() {
    final customController = TextEditingController();
    AdaptiveDialog.show(
      context: Get.context!,
      title: 'Autre plateforme',
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdaptiveTextField(
            controller: customController,
            placeholder: 'Nom de la plateforme',
            hintText: 'Nom de la plateforme',
          ),
        ],
      ),
      actions: [
        AdaptiveDialogAction(text: 'Annuler'),
        AdaptiveDialogAction(
          text: 'Valider',
          onPressed: () {
            if (customController.text.isNotEmpty) {
              platformController.text = customController.text;
            }
          },
          isDefault: true,
        ),
      ],
    );
  }

  /// Sélectionne une image depuis la galerie
  Future<void> pickImage() async {
    final file = await _imageService.pickImage();
    if (file != null) {
      selectedImage.value = file;
    }
  }

  /// Supprime l'image sélectionnée ou l'URL existante
  void removeImage() {
    selectedImage.value = null;
    imageController.clear();
  }

  /// Valide le formulaire
  bool validateForm() {
    if (titleController.text.trim().isEmpty) {
      error.value = 'Le titre est obligatoire';
      return false;
    }
    if (platformController.text.trim().isEmpty) {
      error.value = 'La plateforme est obligatoire';
      return false;
    }
    error.value = '';
    return true;
  }

  /// Sauvegarde l'item
  Future<void> saveItem() async {
    if (!validateForm()) {
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      error.value = 'Utilisateur non connecté';
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      // 1. Upload de l'image si une nouvelle est sélectionnée
      String imageUrl = imageController.text; // Non-nullable
      if (selectedImage.value != null) {
        final uploadedUrl = await _imageService.uploadImage(
          selectedImage.value!,
        ); // use local var
        if (uploadedUrl == null) {
          throw Exception('Échec de l\'upload de l\'image');
        }
        imageUrl = uploadedUrl;
      }

      final now = DateTime.now();
      final item = WatchItem(
        id: _editingItem?.id ?? '',
        type: selectedType.value,
        platform: platformController.text.trim(),
        title: titleController.text.trim(),
        image: imageUrl.trim().isEmpty ? null : imageUrl.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        personalNote: personalNoteController.text.trim().isEmpty
            ? null
            : personalNoteController.text.trim(),
        status: selectedStatus.value,
        seasonsCount:
            selectedType.value == WatchItemType.series &&
                seasonsCountController.text.trim().isNotEmpty
            ? int.tryParse(seasonsCountController.text.trim())
            : null,
        currentSeason:
            selectedType.value == WatchItemType.series &&
                currentSeasonController.text.trim().isNotEmpty
            ? int.tryParse(currentSeasonController.text.trim())
            : null,
        currentEpisode:
            selectedType.value == WatchItemType.series &&
                currentEpisodeController.text.trim().isNotEmpty
            ? int.tryParse(currentEpisodeController.text.trim())
            : null,
        createdAt: _editingItem?.createdAt ?? now,
        updatedAt: now,
      );

      if (isEditing) {
        await _repository.updateItem(user.uid, item);
      } else {
        await _repository.createItem(user.uid, item);
      }

      Get.back(result: true);
    } catch (e) {
      error.value = 'Erreur lors de la sauvegarde: $e';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    platformController.dispose();
    descriptionController.dispose();
    personalNoteController.dispose();
    imageController.dispose();
    seasonsCountController.dispose();
    currentSeasonController.dispose();
    currentEpisodeController.dispose();
    super.onClose();
  }
}
