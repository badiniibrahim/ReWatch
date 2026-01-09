import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/di/initial_binding.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/repositories/iauth_repository.dart';
import '../../domain/usecase/sign_in_usecase.dart';
import '../../domain/usecase/sign_up_usecase.dart';
import '../../domain/usecase/reset_password_usecase.dart';
import '../../domain/usecase/sign_in_with_google_usecase.dart';
import '../../domain/usecase/sign_in_with_apple_usecase.dart';
import '../controllers/sign_in_controller.dart';
import '../controllers/sign_up_controller.dart';
import '../controllers/reset_password_controller.dart';

/// Binding pour l'authentification.
/// 
/// Initialise toutes les dépendances nécessaires pour l'authentification :
/// - Repository
/// - UseCases
/// - Controllers
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Initialiser les dépendances de base
    InitialBinding().dependencies();

    // Repository
    Get.lazyPut<IAuthRepository>(
      () => AuthRepository(
        firebaseAuth: Get.find<FirebaseAuth>(),
        firestore: Get.find<FirebaseFirestore>(),
      ),
      fenix: true,
    );

    // UseCases
    Get.lazyPut<SignInUseCase>(
      () => SignInUseCase(Get.find<IAuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<SignUpUseCase>(
      () => SignUpUseCase(Get.find<IAuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(Get.find<IAuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<SignInWithGoogleUseCase>(
      () => SignInWithGoogleUseCase(Get.find<IAuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<SignInWithAppleUseCase>(
      () => SignInWithAppleUseCase(Get.find<IAuthRepository>()),
      fenix: true,
    );

    // Controllers
    // S'assurer que les use cases sont créés avant de créer le controller
    // Get.find() déclenche la création lazy si nécessaire
    final signInUseCase = Get.find<SignInUseCase>();
    final signInWithGoogleUseCase = Get.find<SignInWithGoogleUseCase>();
    final signInWithAppleUseCase = Get.find<SignInWithAppleUseCase>();
    
    // Utiliser Get.put pour créer le controller immédiatement
    // Cela garantit qu'il est disponible quand GetView essaie d'y accéder
    if (!Get.isRegistered<SignInController>()) {
      Get.put<SignInController>(
        SignInController(
          signInUseCase: signInUseCase,
          signInWithGoogleUseCase: signInWithGoogleUseCase,
          signInWithAppleUseCase: signInWithAppleUseCase,
        ),
        permanent: false,
      );
    }

    Get.lazyPut<SignUpController>(
      () => SignUpController(
        signUpUseCase: Get.find<SignUpUseCase>(),
        signInWithGoogleUseCase: Get.find<SignInWithGoogleUseCase>(),
        signInWithAppleUseCase: Get.find<SignInWithAppleUseCase>(),
      ),
    );

    Get.lazyPut<ResetPasswordController>(
      () => ResetPasswordController(
        resetPasswordUseCase: Get.find<ResetPasswordUseCase>(),
      ),
    );
  }
}

