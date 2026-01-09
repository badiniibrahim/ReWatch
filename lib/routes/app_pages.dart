import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/main/presentation/views/main_view.dart';
import '../core/di/initial_binding.dart';
import '../features/auth/presentation/bindings/auth_binding.dart';
import '../features/auth/presentation/views/sign_in_view.dart';
import '../features/auth/presentation/views/sign_up_view.dart';
import '../features/auth/presentation/views/reset_password_view.dart';
import '../features/onboarding/bindings/onboarding_binding.dart';
import '../features/onboarding/views/onboarding_view.dart';
import '../core/services/locale_storage_service.dart';
import '../core/services/storage_key.dart';
import '../features/profile/bindings/profile_binding.dart' show ProfileBinding;
import '../features/profile/views/profile_view.dart' show ProfileView;
import '../features/watch/presentation/bindings/watch_binding.dart';
import '../features/watch/presentation/views/watch_home_view.dart';
import '../features/watch/presentation/views/watch_item_form_view.dart';
import '../features/watch/presentation/views/watch_item_detail_view.dart';
import '../features/main/presentation/bindings/main_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> routes = [
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),

    GetPage(
      name: Routes.signIn,
      page: () => const SignInView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.signUp,
      page: () => const SignUpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: Routes.main,
      page: () => const MainView(),
      binding: MainBinding(),
    ),

    // Routes Watch
    GetPage(
      name: Routes.watchHome,
      page: () => const WatchHomeView(),
      binding: WatchBinding(),
    ),
    GetPage(
      name: Routes.watchAdd,
      page: () => const WatchItemFormView(),
      binding: WatchItemFormBinding(),
    ),
    GetPage(
      name: Routes.watchEdit,
      page: () => const WatchItemFormView(),
      binding: WatchItemFormBinding(),
    ),
    GetPage(
      name: Routes.watchDetail,
      page: () => const WatchItemDetailView(),
      binding: WatchItemDetailBinding(),
    ),
  ];
}
