import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../domain/entities/watch_item.dart';
import 'dart:math';
import '../../domain/repositories/iwatch_items_repository.dart';
import 'package:rewatch/features/watch/presentation/views/shuffle_selection_view.dart';
import 'package:rewatch/routes/app_pages.dart';

/// Controller pour l'écran Home de ReWatch
class WatchHomeController extends GetxController {
  final IWatchItemsRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WatchHomeController({required IWatchItemsRepository repository})
    : _repository = repository;

  // Liste filtrée et triée des items
  final RxList<WatchItem> _allItems = <WatchItem>[].obs;
  final RxList<WatchItem> filteredItems = <WatchItem>[].obs;

  // Getter public pour accéder à tous les items (observable)
  RxList<WatchItem> get allItems => _allItems;

  // États de recherche et filtres
  final RxString searchQuery = ''.obs;
  final Rx<WatchItemType?> selectedType = Rx<WatchItemType?>(null);
  final Rx<WatchItemStatus?> selectedStatus = Rx<WatchItemStatus?>(null);
  final RxString selectedPlatform = ''.obs;
  final RxString sortBy = 'updatedAt'.obs; // 'updatedAt' ou 'title'

  // Controller pour le champ de recherche
  final TextEditingController searchController = TextEditingController();

  // États de chargement et erreur
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Sync searchController with searchQuery
    searchController.text = searchQuery.value;
    searchController.addListener(() {
      if (searchQuery.value != searchController.text) {
        searchQuery.value = searchController.text;
        _applyFilters();
      }
    });

    loadItems();
  }

  /// Charge les items depuis Firestore
  void loadItems() {
    final user = _auth.currentUser;
    if (user == null) {
      error.value = 'watch_userNotConnected'.tr;
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      _repository
          .streamItems(user.uid)
          .listen(
            (items) {
              _allItems.value = items;
              _applyFilters();
              isLoading.value = false;
            },
            onError: (e) {
              error.value = 'watch_errorLoading'.tr.replaceAll(
                '{error}',
                e.toString(),
              );
              isLoading.value = false;
            },
          );
    } catch (e) {
      error.value = 'watch_errorLoading'.tr.replaceAll('{error}', e.toString());
      isLoading.value = false;
    }
  }

  /// Applique les filtres et le tri
  void _applyFilters() {
    var items = List<WatchItem>.from(_allItems);

    // Filtre par recherche
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      items = items
          .where((item) => item.title.toLowerCase().contains(query))
          .toList();
    }

    // Filtre par type
    if (selectedType.value != null) {
      items = items.where((item) => item.type == selectedType.value).toList();
    }

    // Filtre par statut
    if (selectedStatus.value != null) {
      items = items
          .where((item) => item.status == selectedStatus.value)
          .toList();
    }

    // Filtre par plateforme
    if (selectedPlatform.value.isNotEmpty) {
      items = items
          .where((item) => item.platform == selectedPlatform.value)
          .toList();
    }

    // Tri
    if (sortBy.value == 'title') {
      items.sort((a, b) => a.title.compareTo(b.title));
    } else {
      // Par défaut, tri par updatedAt (déjà fait dans la requête)
    }

    filteredItems.value = items;
  }

  /// Met à jour la recherche (legacy/direct call)
  void updateSearch(String query) {
    if (searchController.text != query) {
      searchController.text = query;
    }
    searchQuery.value = query;
    _applyFilters();
  }

  /// Met à jour le filtre de type
  void updateTypeFilter(WatchItemType? type) {
    selectedType.value = type;
    _applyFilters();
  }

  /// Met à jour le filtre de statut
  void updateStatusFilter(WatchItemStatus? status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  /// Met à jour le filtre de plateforme
  void updatePlatformFilter(String platform) {
    selectedPlatform.value = platform;
    _applyFilters();
  }

  /// Change le tri
  void changeSort(String sort) {
    sortBy.value = sort;
    _applyFilters();
  }

  /// Réinitialise tous les filtres
  void resetFilters() {
    searchController.clear(); // Will trigger listener
    selectedType.value = null;
    selectedStatus.value = null;
    selectedPlatform.value = '';
    sortBy.value = 'updatedAt';
    _applyFilters();
  }

  /// Obtient la liste unique des plateformes
  List<String> get platforms {
    return _allItems.map((item) => item.platform).toSet().toList()..sort();
  }

  /// Navigue vers l'écran d'ajout
  void navigateToAdd() {
    Get.toNamed(Routes.watchAdd);
  }

  /// Navigue vers l'écran de détail
  void navigateToDetail(String itemId) {
    final item = _allItems.firstWhereOrNull((element) => element.id == itemId);
    if (item != null) {
      Get.toNamed(Routes.watchDetail, arguments: item);
    } else {
      Get.toNamed(Routes.watchDetail, arguments: itemId);
    }
  }

  /// Lance le mode aléatoire
  void shuffleItems() {
    if (filteredItems.isEmpty) {
      Get.snackbar(
        'watch_error'.tr,
        'watch_noItems'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.kError,
        colorText: Colors.white,
      );
      return;
    }

    final random = Random();
    final randomItem = filteredItems[random.nextInt(filteredItems.length)];

    Get.to(
      () => ShuffleSelectionView(
        item: randomItem,
        onSpinAgain: () {
          Get.back();
          // Small delay for effect before reopening
          Future.delayed(const Duration(milliseconds: 200), () {
            shuffleItems();
          });
        },
        onStartWatching: () {
          Get.back();
          Get.toNamed(Routes.watchDetail, arguments: randomItem);
        },
      ),
      transition: Transition.zoom,
      fullscreenDialog: true,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
