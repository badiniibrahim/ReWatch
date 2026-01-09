import 'package:get/get.dart';
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
      () => WatchHomeController(
        repository: Get.find<IWatchItemsRepository>(),
      ),
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
    Get.put<WatchItemFormController>(
      WatchItemFormController(
        repository: Get.find<IWatchItemsRepository>(),
        editingItem: editingItem ?? Get.arguments,
      ),
    );
  }
}

/// Binding pour le détail
class WatchItemDetailBinding extends Bindings {
  @override
  void dependencies() {
    final itemId = Get.arguments as String? ?? '';
    Get.put<WatchItemDetailController>(
      WatchItemDetailController(
        repository: Get.find<IWatchItemsRepository>(),
        itemId: itemId,
      ),
    );
  }
}
