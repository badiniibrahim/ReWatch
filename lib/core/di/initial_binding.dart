import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/locale_storage_service.dart';
import '../services/language_service.dart';

/// Binding initial pour l'injection de dépendances de base.
/// 
/// Ce binding est appelé au démarrage de l'application pour initialiser
/// les services globaux (Firebase, Storage, etc.).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialiser les services Firebase de base
    // Ces services sont déjà disponibles via Firebase.initializeApp()
    // mais on peut les mettre dans Get pour faciliter l'accès
    
    // Firestore (si besoin d'accès global)
    Get.lazyPut<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
      fenix: true,
    );
    
    // Firebase Auth (si besoin d'accès global)
    Get.lazyPut<FirebaseAuth>(
      () => FirebaseAuth.instance,
      fenix: true,
    );
    
    // Service de stockage local
    Get.lazyPut<LocaleStorageService>(
      () => LocaleStorageService(),
      fenix: true,
    );
    
    
    
    // Service de gestion de langue
    Get.lazyPut<LanguageService>(
      () => LanguageService(
        storageService: Get.find<LocaleStorageService>(),
      ),
      fenix: true,
    );
  }
}

