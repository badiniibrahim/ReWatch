import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'locale_storage_service.dart';
import 'storage_key.dart';

/// Service pour gérer le changement de langue de l'application.
/// 
/// Permet de changer la langue entre français et anglais,
/// et de sauvegarder la préférence de l'utilisateur.
class LanguageService {
  final LocaleStorageService _storageService;
  
  /// Langues supportées.
  static const Locale french = Locale('fr', 'FR');
  static const Locale english = Locale('en', 'US');
  static const List<Locale> supportedLocales = [french, english];
  
  LanguageService({
    required LocaleStorageService storageService,
  }) : _storageService = storageService;
  
  /// Récupère la langue actuelle de l'application.
  /// 
  /// Retourne la langue sauvegardée si elle existe,
  /// sinon la langue du téléphone, sinon français par défaut.
  Future<Locale> getCurrentLocale() async {
    final savedLanguage = await _storageService.read<String>(
      StorageKey.selectedLanguage,
    );
    
    if (savedLanguage != null) {
      return Locale(savedLanguage);
    }
    
    // Utiliser la langue du téléphone si disponible
    final deviceLocale = Get.deviceLocale;
    if (deviceLocale != null) {
      // Vérifier si la langue du téléphone est supportée
      final languageCode = deviceLocale.languageCode;
      if (languageCode == 'fr' || languageCode == 'en') {
        return Locale(languageCode);
      }
    }
    
    // Par défaut, retourner français
    return french;
  }
  
  /// Change la langue de l'application.
  /// 
  /// [locale] : La nouvelle locale à utiliser ('fr' ou 'en')
  /// 
  /// Sauvegarde la préférence et met à jour GetX.
  Future<void> changeLanguage(Locale locale) async {
    // Sauvegarder la préférence
    await _storageService.write(
      StorageKey.selectedLanguage,
      locale.languageCode,
    );
    
    // Mettre à jour GetX
    Get.updateLocale(locale);
  }
  
  /// Réinitialise la langue à la langue du téléphone.
  /// 
  /// Supprime la préférence sauvegardée et utilise la langue du téléphone.
  Future<void> resetToDeviceLanguage() async {
    await _storageService.remove(StorageKey.selectedLanguage);
    
    final deviceLocale = Get.deviceLocale ?? french;
    Get.updateLocale(deviceLocale);
  }
  
  /// Vérifie si la langue actuelle est le français.
  bool get isFrench {
    final currentLocale = Get.locale ?? Get.deviceLocale ?? french;
    return currentLocale.languageCode == 'fr';
  }
  
  /// Vérifie si la langue actuelle est l'anglais.
  bool get isEnglish {
    final currentLocale = Get.locale ?? Get.deviceLocale ?? french;
    return currentLocale.languageCode == 'en';
  }
  
  /// Bascule entre français et anglais.
  /// 
  /// Si actuellement en français, passe à l'anglais et vice versa.
  Future<void> toggleLanguage() async {
    if (isFrench) {
      await changeLanguage(english);
    } else {
      await changeLanguage(french);
    }
  }
}

