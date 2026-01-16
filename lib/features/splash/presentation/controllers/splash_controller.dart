import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../core/services/locale_storage_service.dart';
import '../../../../core/services/storage_key.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Artificial delay to ensure splash is seen (optional, but requested implicitly by "splash screen")
    // and to allow smooth transition.
    await Future.delayed(const Duration(seconds: 2));

    bool onboardingIsCompleted = false;
    try {
      onboardingIsCompleted =
          await Get.find<LocaleStorageService>().read(
            StorageKey.onboardingCompleted,
          ) ??
          false;
    } catch (e) {
      onboardingIsCompleted = false;
    }

    final bool hasValidSession = await _hasValidSession();

    if (onboardingIsCompleted && hasValidSession) {
      Get.offAllNamed(Routes.main);
    } else if (onboardingIsCompleted && !hasValidSession) {
      Get.offAllNamed(Routes.signIn);
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }

  Future<bool> _hasValidSession() async {
    try {
      final firebaseAuth = FirebaseAuth.instance;
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return false;
      }
      await user.reload();
      return user
          .emailVerified; // Assuming we enforce email verification based on original logic
      // Note: Original logic checked emailVerified.
    } catch (e) {
      return false;
    }
  }
}
