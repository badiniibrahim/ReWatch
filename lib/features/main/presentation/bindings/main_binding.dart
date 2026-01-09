import 'package:get/get.dart';
import 'package:rewatch/features/main/presentation/controllers/main_controller.dart';
import 'package:rewatch/features/watch/presentation/controllers/watch_home_controller.dart';
import 'package:rewatch/features/watch/data/repositories/watch_items_repository.dart';
import 'package:rewatch/features/watch/domain/repositories/iwatch_items_repository.dart';
import 'package:rewatch/features/profile/bindings/profile_binding.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Main Controller
    Get.put<MainController>(MainController());

    // 2. Watch Logic (Onglet Accueil)
    // Repository
    if (!Get.isRegistered<IWatchItemsRepository>()) {
      Get.lazyPut<IWatchItemsRepository>(
        () => WatchItemsRepository(),
        fenix: true,
      );
    }
    // Controller (Put immediat pour qu'il soit dispo pour l'UI)
    if (!Get.isRegistered<WatchHomeController>()) {
      Get.put<WatchHomeController>(
        WatchHomeController(repository: Get.find<IWatchItemsRepository>()),
      );
    }

    // 3. Profile Logic (Onglet Profil)
    ProfileBinding().dependencies();
  }
}
