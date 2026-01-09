import 'package:get/get.dart';
import '../../../../core/di/initial_binding.dart';
import '../../../../core/services/locale_storage_service.dart';
import '../controllers/onboarding_controller.dart';

/// Binding pour l'onboarding.
/// 
/// Initialise toutes les dépendances nécessaires pour l'onboarding.
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    // Initialiser les dépendances de base
    InitialBinding().dependencies();

    // Controller
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(
        storageService: Get.find<LocaleStorageService>(),
      ),
    );
  }
}
