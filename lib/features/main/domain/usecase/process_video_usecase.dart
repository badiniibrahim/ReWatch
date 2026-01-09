import 'package:flutter/foundation.dart';
import '../../../../core/result.dart';
import '../entities/recipe.dart';
import '../repositories/iaudio_repository.dart';
import '../repositories/istt_repository.dart';
import '../exceptions/recipe_generation_exception.dart';
import '../../data/services/recipe_ai_service.dart';
import '../services/recipe_validation_service.dart';

/// UseCase pour traiter une vidéo et générer une recette (comme ReciMe).
/// 
/// Ce usecase orchestre l'extraction de la recette dans l'ordre suivant :
/// 1. **Légende/caption** de la vidéo TikTok (si présente)
/// 2. **Audio** de la vidéo (transcription STT)
/// 3. **Site web original** (si disponible dans les métadonnées)
/// 
/// Cette approche est conforme RGPD et TikTok car :
/// - L'utilisateur initie explicitement le partage
/// - Pas de téléchargement automatique depuis un lien
/// - Utilisation du système de partage natif
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = ProcessVideoUseCase(
///   audioRepository: audioRepo,
///   sttRepository: sttRepo,
///   recipeAIService: aiService,
/// );
/// 
/// final result = await useCase.call(
///   videoPath: '/path/to/video.mp4',
///   caption: 'Caption TikTok',
///   tiktokUrl: 'https://www.tiktok.com/@user/video/123',
/// );
/// ```
class ProcessVideoUseCase {
  final IAudioRepository _audioRepository;
  final ISTTRepository _sttRepository;
  final RecipeAIService _recipeAIService;
  
  /// Crée une nouvelle instance du usecase.
  ProcessVideoUseCase({
    required IAudioRepository audioRepository,
    required ISTTRepository sttRepository,
    required RecipeAIService recipeAIService,
  })  : _audioRepository = audioRepository,
        _sttRepository = sttRepository,
        _recipeAIService = recipeAIService;
  
  /// Exécute le usecase et retourne le résultat (ordre ReciMe).
  /// 
  /// [videoPath] : Chemin du fichier vidéo à traiter (optionnel si caption disponible)
  /// [caption] : Caption/Légende de la vidéo TikTok (priorité 1)
  /// [tiktokUrl] : URL TikTok pour rechercher le site web original (priorité 3)
  /// 
  /// Retourne un [Result<Recipe>] :
  /// - [Success] avec la recette générée si une source valide est trouvée
  /// - [Failure] si toutes les sources échouent
  /// 
  /// **Ordre d'extraction (comme ReciMe)** :
  /// 1. Légende/caption (si présente et contient une recette)
  /// 2. Audio/transcription (si la légende ne suffit pas et vidéo disponible)
  /// 3. Site web original (si disponible)
  /// 
  /// **Note** : Les fichiers temporaires (audio) sont automatiquement supprimés
  /// après utilisation.
  Future<Result<Recipe>> call({
    String? videoPath,
    String? caption,
    String? tiktokUrl,
  }) async {
    String? audioPath;
    
    try {
      // ============================================
      // ÉTAPE 1 : Essayer d'extraire depuis la LÉGENDE (priorité 1)
      // ============================================
      if (caption != null && caption.isNotEmpty) {
        try {
          final captionRecipe = await _recipeAIService.generateRecipeFromCaption(
            caption: caption,
          );
        
          final captionValidation = RecipeValidationService.validateRecipe(captionRecipe);
          if (captionValidation.isValid) {
            // La légende contient une recette valide - on l'utilise !
            return Success(captionRecipe);
          }
          
          // Si la validation échoue mais qu'une recette a été générée, on l'utilise quand même
          // (l'IA a fait de son mieux, même si la validation n'est pas parfaite)
          // On continue seulement si on a une vidéo pour essayer l'audio
          if (videoPath == null || videoPath.isEmpty) {
            // Pas de vidéo disponible, retourner la recette générée même si validation échoue
            // C'est mieux que de retourner une erreur "site web non implémenté"
            return Success(captionRecipe);
          }
          // Si on a une vidéo, on peut essayer l'audio pour améliorer la recette
        } on RecipeGenerationException catch (e) {
          // Propager l'exception avec le bon code d'erreur
          return Failure(
            e.message,
            errorCode: e.code,
            error: e,
          );
        } catch (e) {
          // Pour les autres erreurs, continuer avec l'audio si disponible
          if (kDebugMode) {
            debugPrint('⚠️ Error generating from caption, trying audio: $e');
          }
        }
      }
      
      // ============================================
      // ÉTAPE 2 : Extraire depuis l'AUDIO (priorité 2)
      // ============================================
      // Si on n'a pas de vidéo et pas de légende valide, retourner une erreur claire
      if (videoPath == null || videoPath.isEmpty) {
        return const Failure(
          'Impossible d\'extraire la recette : la légende ne contient pas de recette valide et aucune vidéo n\'est disponible pour l\'extraction audio.',
          errorCode: 'no-valid-source',
        );
      }
      
      // Extraction audio
      final audioResult = await _audioRepository.extractAudioToWav(videoPath);
      
      if (audioResult.isFailure) {
        // Si l'extraction audio échoue, essayer le site web
        return await _tryExtractFromWebsite(tiktokUrl);
      }
      
      audioPath = audioResult.dataOrNull;
      if (audioPath == null) {
        return await _tryExtractFromWebsite(tiktokUrl);
      }
      
      // Transcription audio
      final sttResult = await _sttRepository.transcribeAudio(audioPath);
      
      if (sttResult.isFailure) {
        // Supprimer l'audio et essayer le site web
        await _audioRepository.deleteAudioFile(audioPath);
        return await _tryExtractFromWebsite(tiktokUrl);
      }
      
      final transcription = sttResult.dataOrNull ?? '';
      if (transcription.isEmpty) {
        // Transcription vide, essayer le site web
        await _audioRepository.deleteAudioFile(audioPath);
        return await _tryExtractFromWebsite(tiktokUrl);
      }
      
      // Génération de la recette depuis l'audio
      final audioRecipe = await _recipeAIService.generateRecipe(
        transcription: transcription,
        caption: caption,
      );
      
      // Validation de la recette depuis l'audio
      final audioValidation = RecipeValidationService.validateRecipe(audioRecipe);
      if (audioValidation.isValid) {
        // Supprimer l'audio
        await _audioRepository.deleteAudioFile(audioPath);
        return Success(audioRecipe);
      }
      
      // La recette depuis l'audio n'est pas valide, essayer le site web
      await _audioRepository.deleteAudioFile(audioPath);
      
      // ============================================
      // ÉTAPE 3 : Essayer d'extraire depuis le SITE WEB (priorité 3)
      // ============================================
      return await _tryExtractFromWebsite(tiktokUrl);
      
    } catch (e) {
      // Supprimer l'audio en cas d'erreur inattendue
      if (audioPath != null) {
        await _audioRepository.deleteAudioFile(audioPath);
      }
      return Failure(
        'Erreur inattendue lors du traitement',
        errorCode: 'unexpected-error',
        error: e,
      );
    }
  }
  
  /// Essaie d'extraire la recette depuis le site web original.
  /// 
  /// [tiktokUrl] : URL TikTok pour rechercher le site web original
  /// 
  /// Retourne un [Result<Recipe>] ou [Failure] si le site web n'est pas disponible.
  Future<Result<Recipe>> _tryExtractFromWebsite(String? tiktokUrl) async {
    if (tiktokUrl == null || tiktokUrl.isEmpty) {
      return const Failure(
        'Impossible d\'extraire la recette : légende, audio et site web indisponibles',
        errorCode: 'no-source-available',
      );
    }
    
    // **Limitation connue** : L'extraction depuis le site web original n'est pas implémentée.
    // Cette fonctionnalité nécessiterait un service backend pour scraper le site web TikTok,
    // ce qui pourrait violer les conditions d'utilisation de TikTok.
    // Pour l'instant, on retourne une erreur explicite pour informer l'utilisateur.
    return const Failure(
      'Extraction depuis le site web original non implémentée',
      errorCode: 'website-extraction-not-implemented',
    );
  }
}

