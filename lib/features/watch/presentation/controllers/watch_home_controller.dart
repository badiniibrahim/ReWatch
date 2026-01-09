import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../domain/entities/watch_item.dart';
import '../../domain/repositories/iwatch_items_repository.dart';

/// Controller pour l'écran Home de ReWatch
class WatchHomeController extends GetxController {
  final IWatchItemsRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WatchHomeController({required IWatchItemsRepository repository})
      : _repository = repository;

  // Liste filtrée et triée des items
  final RxList<WatchItem> _allItems = <WatchItem>[].obs;
  final RxList<WatchItem> filteredItems = <WatchItem>[].obs;

  // États de recherche et filtres
  final RxString searchQuery = ''.obs;
  final Rx<WatchItemType?> selectedType = Rx<WatchItemType?>(null);
  final Rx<WatchItemStatus?> selectedStatus = Rx<WatchItemStatus?>(null);
  final RxString selectedPlatform = ''.obs;
  final RxString sortBy = 'updatedAt'.obs; // 'updatedAt' ou 'title'

  // États de chargement et erreur
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  /// Charge les items depuis Firestore
  void loadItems() {
    final user = _auth.currentUser;
    if (user == null) {
      error.value = 'Utilisateur non connecté';
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      _repository.streamItems(user.uid).listen(
        (items) {
          _allItems.value = items;
          _applyFilters();
          isLoading.value = false;
        },
        onError: (e) {
          error.value = 'Erreur lors du chargement: $e';
          isLoading.value = false;
        },
      );
    } catch (e) {
      error.value = 'Erreur lors du chargement: $e';
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
      items = items
          .where((item) => item.type == selectedType.value)
          .toList();
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

  /// Met à jour la recherche
  void updateSearch(String query) {
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
    searchQuery.value = '';
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
    Get.toNamed('/watch/add');
  }

  /// Navigue vers l'écran de détail
  void navigateToDetail(String itemId) {
    Get.toNamed('/watch/detail', arguments: itemId);
  }
}
