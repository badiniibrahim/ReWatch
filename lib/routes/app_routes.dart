part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static Future<String> get initial async {
    InitialBinding().dependencies();

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      Get.find<LocaleStorageService>().debugStorage();
    } catch (e) {}

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
      return Routes.main;
    } else if (onboardingIsCompleted && !hasValidSession) {
      return Routes.signIn;
    } else {
      return Routes.onboarding;
    }
  }

  static Future<bool> _hasValidSession() async {
    try {
      final firebaseAuth = FirebaseAuth.instance;
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return false;
      }

      await user.reload();
      return user.emailVerified;
    } catch (e) {
      return false;
    }
  }

  static const String main = _Paths.main;
  static const String signIn = _Paths.signIn;
  static const String signUp = _Paths.signUp;
  static const String resetPassword = _Paths.resetPassword;
  static const String profile = _Paths.profile;
  static const String onboarding = _Paths.onboarding;
  static const String watchHome = _Paths.watchHome;
  static const String watchAdd = _Paths.watchAdd;
  static const String watchEdit = _Paths.watchEdit;
  static const String watchDetail = _Paths.watchDetail;
  static const String splash = _Paths.splash;
}

///
abstract class _Paths {
  _Paths._();

  static const String splash = '/splash';
  static const String main = '/main';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String resetPassword = '/reset-password';
  static const String onboarding = '/onboarding';
  static const String profile = '/profile';
  static const String watchHome = '/watch';
  static const String watchAdd = '/watch/add';
  static const String watchEdit = '/watch/edit';
  static const String watchDetail = '/watch/detail';
}
