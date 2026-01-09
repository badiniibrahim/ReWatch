import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../domain/entities/watch_item.dart';
import '../../domain/repositories/iwatch_items_repository.dart';

/// Controller pour l'écran de détail d'un WatchItem
class WatchItemDetailController extends GetxController {
  final IWatchItemsRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String itemId;

  WatchItemDetailController({
    required IWatchItemsRepository repository,
    required this.itemId,
  }) : _repository = repository;

  final Rx<WatchItem?> item = Rx<WatchItem?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadItem();
  }

  /// Charge l'item depuis Firestore
  void _loadItem() {
    final user = _auth.currentUser;
    if (user == null) {
      error.value = 'watch_userNotConnected'.tr;
      return;
    }

    isLoading.value = true;
    error.value = '';

    _repository.streamItems(user.uid).listen(
      (items) {
        try {
          final foundItem = items.firstWhere((i) => i.id == itemId);
          item.value = foundItem;
          isLoading.value = false;
        } catch (e) {
          error.value = 'watch_itemNotFound'.tr;
          isLoading.value = false;
        }
      },
      onError: (e) {
        error.value = 'watch_errorLoading'.tr.replaceAll('{error}', e.toString());
        isLoading.value = false;
      },
    );
  }

  /// Incrémente l'épisode actuel de +1
  Future<void> incrementEpisode() async {
    final currentItem = item.value;
    if (currentItem == null ||
        currentItem.type != WatchItemType.series ||
        currentItem.currentEpisode == null) {
      return;
    }

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final updatedItem = currentItem.copyWith(
        currentEpisode: currentItem.currentEpisode! + 1,
        lastWatchedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.updateItem(user.uid, updatedItem);
    } catch (e) {
      error.value = 'watch_errorUpdating'.tr.replaceAll('{error}', e.toString());
    }
  }

  /// Passe à la saison suivante
  Future<void> nextSeason() async {
    final currentItem = item.value;
    if (currentItem == null ||
        currentItem.type != WatchItemType.series ||
        currentItem.currentSeason == null) {
      return;
    }

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final updatedItem = currentItem.copyWith(
        currentSeason: currentItem.currentSeason! + 1,
        currentEpisode: 1,
        lastWatchedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.updateItem(user.uid, updatedItem);
    } catch (e) {
      error.value = 'watch_errorUpdating'.tr.replaceAll('{error}', e.toString());
    }
  }

  /// Marque l'item comme terminé
  Future<void> markAsCompleted() async {
    final currentItem = item.value;
    if (currentItem == null) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final updatedItem = currentItem.copyWith(
        status: WatchItemStatus.completed,
        updatedAt: DateTime.now(),
      );
      await _repository.updateItem(user.uid, updatedItem);
      Get.back();
    } catch (e) {
      error.value = 'watch_errorUpdating'.tr.replaceAll('{error}', e.toString());
    }
  }

  /// Supprime l'item avec confirmation
  Future<void> deleteItem() async {
    final currentItem = item.value;
    if (currentItem == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('watch_deleteConfirmTitle'.tr),
        content: Text(
          'watch_deleteConfirmMessage'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE54D2E),
            ),
            child: Text('common_delete'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = _auth.currentUser;
    if (user == null) return;

    isDeleting.value = true;
    try {
      await _repository.deleteItem(user.uid, itemId);
      Get.back();
      Get.back(); // Retour à la liste
    } catch (e) {
      error.value = 'watch_errorDeleting'.tr.replaceAll('{error}', e.toString());
      isDeleting.value = false;
    }
  }

  /// Navigue vers l'écran d'édition
  void navigateToEdit() {
    final currentItem = item.value;
    if (currentItem == null) return;
    Get.toNamed('/watch/edit', arguments: currentItem);
  }
}
