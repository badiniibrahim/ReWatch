import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../routes/app_pages.dart';
import '../../../../core/result.dart';
import '../../../../core/utilities/snackbar_helper.dart';
import '../../../../core/widgets/adaptive_widgets.dart';
import '../../../../core/services/language_service.dart';
import '../../auth/domain/entities/user.dart';
import '../../auth/domain/repositories/iauth_repository.dart';
import '../../auth/domain/usecase/delete_account_usecase.dart';

class ProfileController extends GetxController {
  final IAuthRepository _authRepository;
  final LanguageService _languageService;
  final DeleteAccountUseCase _deleteAccountUseCase;
  
  final Rx<User?> currentUser = Rx<User?>(null);
  
  final RxBool isLoading = false.obs;
  
  final RxBool isFrench = true.obs;
  
  final RxString appVersion = ''.obs;
  
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<User?>? _userDocumentSubscription;
  
  ProfileController({
    required IAuthRepository authRepository,
    required LanguageService languageService,
    required DeleteAccountUseCase deleteAccountUseCase,
  }) : _authRepository = authRepository,
       _languageService = languageService,
       _deleteAccountUseCase = deleteAccountUseCase;
  
  @override
  void onInit() {
    super.onInit();
    _loadUser();
    _loadLanguage();
    _loadAppVersion();
    
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      currentUser.value = user;
    });
    
    _userDocumentSubscription = _authRepository.userDocumentChanges.listen((user) {
      if (user != null) {
        if (kDebugMode) {
          debugPrint('🔄 User document updated. New credits: ${user.credits}');
        }
        currentUser.value = user;
      }
    });
  }
  
  @override
  void onReady() {
    super.onReady();
    refreshUser();
  }
  
  @override
  void onClose() {
    _authStateSubscription?.cancel();
    _userDocumentSubscription?.cancel();
    super.onClose();
  }
  
  Future<void> _loadLanguage() async {
    isFrench.value = _languageService.isFrench;
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = '${packageInfo.version} (${packageInfo.buildNumber})';
      if (kDebugMode) {
        debugPrint('📱 App version: ${appVersion.value}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading app version: $e');
      }
      appVersion.value = '1.0.0 (1)';
    }
  }
  
  Future<void> changeLanguage(bool isFrenchSelected) async {
    isFrench.value = isFrenchSelected;
    
    final locale = isFrenchSelected
        ? LanguageService.french
        : LanguageService.english;
    
    await _languageService.changeLanguage(locale);
  }
  
  Future<void> _loadUser() async {
    isLoading.value = true;
    final result = await _authRepository.getCurrentUser();
    result.when(
      success: (user) {
        currentUser.value = user;
      },
      failure: (message, errorCode, error) {
        if (Get.isLogEnable) {
          Get.log('Erreur lors du chargement de l\'utilisateur: $message');
        }
        currentUser.value = null;
      },
    );
    isLoading.value = false;
  }
  
  Future<void> refreshUser() async {
    if (kDebugMode) {
      debugPrint('🔄 ProfileController: Refreshing user data...');
    }
    await _loadUser();
  }
  
  Future<void> signOut() async {
    bool? confirmed;
    await AdaptiveDialog.show(
      context: Get.context!,
      title: 'profile_logout'.tr,
      content: 'profile_logout_confirm'.tr,
      actions: [
        AdaptiveDialogAction(
          text: 'common_cancel'.tr,
          onPressed: () {
            confirmed = false;
          },
        ),
        AdaptiveDialogAction(
          text: 'profile_logout'.tr,
          onPressed: () {
            confirmed = true;
          },
          isDefault: true,
        ),
      ],
    );

    if (confirmed == true) {
      isLoading.value = true;
      final result = await _authRepository.signOut();
      result.when(
        success: (_) {
          currentUser.value = null;
          SnackbarHelper.showSuccess(
            'auth_signOutSuccess'.tr,
            title: 'success'.tr,
          );
          Get.offAllNamed(Routes.signIn);
        },
        failure: (message, errorCode, error) {
          SnackbarHelper.showError(
            message,
            title: 'errorTitle'.tr,
          );
        },
      );
      isLoading.value = false;
    }
  }
  
  void openSettings() {
    SnackbarHelper.showInfo(
      'profile_settingsComingSoon'.tr,
      title: 'info'.tr,
    );
  }
  
  void openHelp() {
    SnackbarHelper.showInfo(
      'profile_helpComingSoon'.tr,
      title: 'info'.tr,
    );
  }

  

  Future<void> leaveReview() async {
    const email = 'sawadogo.badiniibrahim@gmail.com';
    const subject = 'Avis sur Tok Cook';
    final mailtoUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}',
    );
    
    if (kDebugMode) {
      debugPrint('📧 Opening email client: $mailtoUri');
    }
    
    try {
      try {
        if (kDebugMode) {
          debugPrint('✅ Attempting to open email with platformDefault');
        }
        final launched = await launchUrl(
          mailtoUri,
          mode: LaunchMode.platformDefault,
        );
        if (launched) {
          if (kDebugMode) {
            debugPrint('✅ Successfully opened email with platformDefault');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Platform default failed: $e');
        }
      }
      
      try {
        if (kDebugMode) {
          debugPrint('✅ Attempting to open email with externalApplication');
        }
        final launched = await launchUrl(
          mailtoUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          if (kDebugMode) {
            debugPrint('✅ Successfully opened email with externalApplication');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ External application failed: $e');
        }
      }
      
      try {
        if (kDebugMode) {
          debugPrint('✅ Attempting to open email without specific mode');
        }
        final launched = await launchUrl(mailtoUri);
        if (launched) {
          if (kDebugMode) {
            debugPrint('✅ Successfully opened email');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Default launch failed: $e');
        }
      }

      if (kDebugMode) {
        debugPrint('❌ Cannot open email client');
      }
      SnackbarHelper.showError(
        'profile_cannotOpenEmail'.tr,
        title: 'errorTitle'.tr,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error opening email: $e');
      }
      SnackbarHelper.showError(
        'profile_cannotOpenEmail'.tr,
        title: 'errorTitle'.tr,
      );
    }
  }

  Future<void> openTermsAndConditions() async {
    const url = 'https://sites.google.com/view/tok-cook/terms-conditions?authuser=2';
    
    if (kDebugMode) {
      debugPrint('🔗 Opening Terms and Conditions URL: $url');
    }
    
    try {
      final uri = Uri.parse(url);
      
      try {
        if (kDebugMode) {
          debugPrint('✅ Attempting to open URL with platformDefault');
        }
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        if (launched) {
          if (kDebugMode) {
            debugPrint('✅ Successfully opened URL with platformDefault');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Platform default failed: $e');
        }
      }
      
      try {
        if (kDebugMode) {
          debugPrint('✅ Attempting to open URL with externalApplication');
        }
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          if (kDebugMode) {
            debugPrint('✅ Successfully opened URL with externalApplication');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ External application failed: $e');
        }
      }
      
      try {
        if (kDebugMode) {
          debugPrint('✅ Attempting to open URL without specific mode');
        }
        final launched = await launchUrl(uri);
        if (launched) {
          if (kDebugMode) {
            debugPrint('✅ Successfully opened URL');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Default launch failed: $e');
        }
      }
      
      if (kDebugMode) {
        debugPrint('❌ Cannot launch URL: $url');
      }
      SnackbarHelper.showError(
        'profile_cannotOpenUrl'.tr,
        title: 'errorTitle'.tr,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error opening terms and conditions: $e');
      }
      SnackbarHelper.showError(
        'profile_cannotOpenUrl'.tr,
        title: 'errorTitle'.tr,
      );
    }
  }

  Future<void> openPrivacyPolicy() async {
    const url = 'https://sites.google.com/view/tok-cook/privacy-policy?authuser=2';
    
    if (kDebugMode) {
      debugPrint('🔗 Opening Privacy Policy URL: $url');
    }
    
    try {
      final uri = Uri.parse(url);
      
      try {
        if (kDebugMode) {
          debugPrint('✅ Attempting to open URL with platformDefault');
        }
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        if (launched) {
          if (kDebugMode) {
            debugPrint('✅ Successfully opened URL with platformDefault');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Platform default failed: $e');
        }
      }
      
      try {
        if (kDebugMode) {
          debugPrint('✅ Attempting to open URL with externalApplication');
        }
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          if (kDebugMode) {
            debugPrint('✅ Successfully opened URL with externalApplication');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ External application failed: $e');
        }
      }
      
      try {
        if (kDebugMode) {
          debugPrint('✅ Attempting to open URL without specific mode');
        }
        final launched = await launchUrl(uri);
        if (launched) {
          if (kDebugMode) {
            debugPrint('✅ Successfully opened URL');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Default launch failed: $e');
        }
      }
      
      if (kDebugMode) {
        debugPrint('❌ Cannot launch URL: $url');
      }
      SnackbarHelper.showError(
        'profile_cannotOpenUrl'.tr,
        title: 'errorTitle'.tr,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error opening privacy policy: $e');
      }
      SnackbarHelper.showError(
        'profile_cannotOpenUrl'.tr,
        title: 'errorTitle'.tr,
      );
    }
  }

  Future<void> deleteAccount() async {
    bool? confirmed;
    await AdaptiveDialog.show(
      context: Get.context!,
      title: 'auth_deleteAccountTitle'.tr,
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('auth_deleteAccountWarning'.tr),
          const SizedBox(height: 16),
          Text(
            'auth_deleteAccountConfirm'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        AdaptiveDialogAction(
          text: 'common_cancel'.tr,
          onPressed: () {
            confirmed = false;
          },
        ),
        AdaptiveDialogAction(
          text: 'auth_deleteAccount'.tr,
          onPressed: () {
            confirmed = true;
          },
          isDestructive: true,
          isDefault: true,
        ),
      ],
    );

    if (confirmed == true) {
      isLoading.value = true;

      final result = await _deleteAccountUseCase.call();

      result.when(
        success: (_) {
          currentUser.value = null;
          SnackbarHelper.showSuccess(
            'auth_accountDeletedSuccess'.tr,
            title: 'success'.tr,
          );
          Get.offAllNamed(Routes.signIn);
        },
        failure: (message, errorCode, error) {
          SnackbarHelper.showError(
            message,
            title: 'errorTitle'.tr,
          );
        },
      );

      isLoading.value = false;
    }
  }
}

