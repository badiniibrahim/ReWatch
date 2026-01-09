import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/services/locale_storage_service.dart';
import '../../../../core/services/storage_key.dart';
import '../../../../routes/app_pages.dart';

/// Controller pour la vue d'onboarding.
///
/// Gère l'état de l'onboarding et la navigation entre les pages.
class OnboardingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final LocaleStorageService _storageService;
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  OnboardingController({required LocaleStorageService storageService})
    : _storageService = storageService;

  /// Liste des pages d'onboarding avec leurs contenus.
  ///
  /// Adapté au contexte ReWatch (suivi de séries et films).
  List<Map<String, dynamic>> get pages => [
    {
      'title': 'onboarding_title_1'.tr,
      'subtitle': 'onboarding_subtitle_1'.tr,
      'description': 'onboarding_description_1'.tr,
      'image': 'assets/images/onboarding_1.png',
      'icon': Icons.movie,
      'iconColor': AppColors.kTypeMovie,
    },
    {
      'title': 'onboarding_title_2'.tr,
      'subtitle': 'onboarding_subtitle_2'.tr,
      'description': 'onboarding_description_2'.tr,
      'image': 'assets/images/onboarding_2.png',
      'icon': Icons.play_circle_outline,
      'iconColor': AppColors.kPrimary,
    },
    {
      'title': 'onboarding_title_3'.tr,
      'subtitle': 'onboarding_subtitle_3'.tr,
      'description': 'onboarding_description_3'.tr,
      'image': 'assets/images/onboarding_3.png',
      'icon': Icons.bookmark,
      'iconColor': AppColors.kTypeSeries,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    animationController.forward();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    animationController.reset();
    animationController.forward();
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  /// Ignore l'onboarding et navigue vers la page de connexion.
  Future<void> skipOnboarding() async {
    await _completeOnboarding();
  }

  /// Complète l'onboarding et navigue vers la page de connexion.
  Future<void> _completeOnboarding() async {
    // Marquer l'onboarding comme complété
    await _storageService.write(StorageKey.onboardingCompleted, true);

    // Naviguer vers la page de connexion en utilisant la route nommée
    // Cela garantit que le binding AuthBinding() est appelé
    Get.offAllNamed(Routes.signIn);
  }

  @override
  void onClose() {
    pageController.dispose();
    animationController.dispose();
    super.onClose();
  }
}
