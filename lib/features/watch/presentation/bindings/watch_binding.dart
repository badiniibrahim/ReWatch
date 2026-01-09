import 'package:get/get.dart';
import 'package:rewatch/core/services/tmdb_service.dart';
import '../../data/repositories/watch_items_repository.dart';
import '../../domain/repositories/iwatch_items_repository.dart';
import '../controllers/watch_home_controller.dart';
import '../controllers/watch_item_form_controller.dart';
import '../controllers/watch_item_detail_controller.dart';
import '../../domain/entities/watch_item.dart';

/// Binding pour la feature Watch
class WatchBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<IWatchItemsRepository>(
      () => WatchItemsRepository(),
      fenix: true,
    );

    // Home Controller
    Get.lazyPut<WatchHomeController>(
      () => WatchHomeController(repository: Get.find<IWatchItemsRepository>()),
      fenix: true,
    );
  }
}

/// Binding pour le formulaire d'ajout/édition
class WatchItemFormBinding extends Bindings {
  final WatchItem? editingItem;

  WatchItemFormBinding({this.editingItem});

  @override
  void dependencies() {
    final args = editingItem ?? Get.arguments;
    WatchItem? itemToEdit;
    TmdbResult? tmdbData;

    if (args is WatchItem) {
      itemToEdit = args;
    } else if (args is TmdbResult) {
      tmdbData = args;
    }

    Get.put<WatchItemFormController>(
      WatchItemFormController(
        repository: Get.find<IWatchItemsRepository>(),
        editingItem: itemToEdit,
        initialData: tmdbData,
      ),
    );
  }
}

/// Binding pour le détail
class WatchItemDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    String itemId = '';

    if (args is WatchItem) {
      itemId = args.id;
    } else if (args is String) {
      itemId = args;
    }

    Get.put<WatchItemDetailController>(
      WatchItemDetailController(
        repository: Get.find<IWatchItemsRepository>(),
        itemId: itemId,
        initialItem: args is WatchItem ? args : null,
      ),
    );
  }
}
