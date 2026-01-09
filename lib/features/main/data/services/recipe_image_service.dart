import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

/// Service pour télécharger et sauvegarder les images de recettes dans Firebase Storage.
///
/// Télécharge l'image depuis une URL (ex: thumbnail TikTok) et la sauvegarde
/// dans Firebase Storage pour une utilisation persistante.
///
/// Exemple :
/// ```dart
/// final service = Get.find<RecipeImageService>();
/// final imageUrl = await service.downloadAndSaveImage(
///   imageUrl: 'https://example.com/image.jpg',
///   recipeId: 'recipe-id',
///   userId: 'user-id',
/// );
/// ```
class RecipeImageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    if (kDebugMode) {
      debugPrint('🚀 Initializing RecipeImageService...');
    }
  }
  
  /// Télécharge une image depuis une URL et la sauvegarde dans Firebase Storage.
  ///
  /// [imageUrl] : URL de l'image à télécharger
  /// [recipeId] : ID de la recette (pour nommer le fichier)
  /// [userId] : ID de l'utilisateur (pour le chemin de stockage)
  ///
  /// Retourne l'URL de l'image sauvegardée dans Firebase Storage, ou null en cas d'erreur.
  ///
  /// Le fichier est sauvegardé dans : `users/{userId}/recipes/{recipeId}/image.jpg`
  Future<String?> downloadAndSaveImage({
    required String imageUrl,
    required String recipeId,
    required String userId,
  }) async {
    if (imageUrl.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ RecipeImageService: Empty image URL provided');
      }
      return null;
    }
    
    final user = _auth.currentUser;
    if (user == null || user.uid != userId) {
      if (kDebugMode) {
        debugPrint('❌ RecipeImageService: User not authenticated');
      }
      return null;
    }
    
    try {
      if (kDebugMode) {
        debugPrint('📥 RecipeImageService: Downloading image from: $imageUrl');
      }
      
      // Télécharger l'image depuis l'URL
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint('❌ RecipeImageService: Failed to download image. Status: ${response.statusCode}');
        }
        return null;
      }
      
      final imageBytes = response.bodyBytes;
      
      if (kDebugMode) {
        debugPrint('✅ RecipeImageService: Downloaded ${imageBytes.length} bytes');
      }
      
      // Déterminer l'extension du fichier depuis l'URL ou utiliser .jpg par défaut
      String extension = 'jpg';
      try {
        final uri = Uri.parse(imageUrl);
        final path = uri.path;
        if (path.contains('.')) {
          final ext = path.split('.').last.toLowerCase();
          if (['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
            extension = ext;
          }
        }
      } catch (e) {
        // Utiliser .jpg par défaut si on ne peut pas déterminer l'extension
      }
      
      // Chemin dans Firebase Storage
      final storagePath = 'users/$userId/recipes/$recipeId/image.$extension';
      
      if (kDebugMode) {
        debugPrint('💾 RecipeImageService: Uploading to Firebase Storage: $storagePath');
      }
      
      // Uploader vers Firebase Storage
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/$extension',
          cacheControl: 'public, max-age=31536000', // Cache 1 an
        ),
      );
      
      // Attendre la fin de l'upload
      final snapshot = await uploadTask;
      
      // Obtenir l'URL de téléchargement
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        debugPrint('✅ RecipeImageService: Image saved successfully: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ RecipeImageService: Error downloading/saving image: $e');
        debugPrint('❌ Stack trace: $stackTrace');
      }
      return null;
    }
  }
  
  /// Supprime l'image d'une recette depuis Firebase Storage.
  ///
  /// [recipeId] : ID de la recette
  /// [userId] : ID de l'utilisateur
  Future<void> deleteRecipeImage({
    required String recipeId,
    required String userId,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != userId) {
      return;
    }
    
    try {
      // Essayer de supprimer avec différentes extensions possibles
      final extensions = ['jpg', 'jpeg', 'png', 'webp'];
      
      for (final ext in extensions) {
        try {
          final storagePath = 'users/$userId/recipes/$recipeId/image.$ext';
          final ref = _storage.ref().child(storagePath);
          await ref.delete();
          
          if (kDebugMode) {
            debugPrint('✅ RecipeImageService: Deleted image: $storagePath');
          }
          break; // Si la suppression réussit, arrêter
        } catch (e) {
          // Continuer avec la prochaine extension
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ RecipeImageService: Error deleting image: $e');
      }
    }
  }
}

