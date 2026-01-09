import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/profile_controller.dart';
import '../../../core/di/initial_binding.dart';
import '../../../core/services/language_service.dart';
import '../../../core/services/locale_storage_service.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../auth/domain/repositories/iauth_repository.dart';
import '../../auth/domain/usecase/delete_account_usecase.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    InitialBinding().dependencies();

    if (!Get.isRegistered<LanguageService>()) {
      Get.lazyPut<LanguageService>(
        () => LanguageService(storageService: Get.find<LocaleStorageService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<IAuthRepository>()) {
      Get.lazyPut<IAuthRepository>(
        () => AuthRepository(
          firebaseAuth: Get.find<FirebaseAuth>(),
          firestore: Get.find<FirebaseFirestore>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<DeleteAccountUseCase>()) {
      Get.lazyPut<DeleteAccountUseCase>(
        () => DeleteAccountUseCase(Get.find<IAuthRepository>()),
        fenix: true,
      );
    }

    Get.lazyPut<ProfileController>(
      () => ProfileController(
        authRepository: Get.find<IAuthRepository>(),
        languageService: Get.find<LanguageService>(),
        deleteAccountUseCase: Get.find<DeleteAccountUseCase>(),
      ),
      fenix: true,
    );
  }
}
