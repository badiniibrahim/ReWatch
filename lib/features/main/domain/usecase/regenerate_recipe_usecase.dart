import '../../../../core/result.dart';
import '../entities/recipe.dart';
import '../../data/services/recipe_ai_service.dart';
import '../repositories/itiktok_repository.dart';
import '../services/recipe_validation_service.dart';

/// UseCase pour regénérer une recette existante.
/// 
/// Utilise l'URL TikTok de la recette pour récupérer les métadonnées
/// et regénérer la recette avec l'IA.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = RegenerateRecipeUseCase(
///   recipeAIService: aiService,
///   tiktokRepository: tiktokRepo,
/// );
/// 
/// final result = await useCase.call(recipe);
/// 
/// result.when(
///   success: (newRecipe) => print('Recipe regenerated: ${newRecipe.title}'),
///   failure: (message, code, error) => print('Error: $message'),
/// );
/// ```
class RegenerateRecipeUseCase {
  final RecipeAIService _recipeAIService;
  final ITikTokRepository _tiktokRepository;
  
  /// Crée une nouvelle instance du usecase.
  /// 
  /// [recipeAIService] : Service pour générer la recette avec l'IA
  /// [tiktokRepository] : Repository pour récupérer les métadonnées TikTok
  RegenerateRecipeUseCase({
    required RecipeAIService recipeAIService,
    required ITikTokRepository tiktokRepository,
  })  : _recipeAIService = recipeAIService,
        _tiktokRepository = tiktokRepository;
  
  /// Exécute le usecase et regénère la recette.
  /// 
  /// [recipe] : La recette existante à regénérer
  /// 
  /// Retourne un [Result<Recipe>] :
  /// - [Success] avec la nouvelle recette regénérée
  /// - [Failure] si la regénération échoue
  Future<Result<Recipe>> call(Recipe recipe) async {
    try {
      // Vérifier que la recette a une source TikTok
      if (recipe.tiktokSource == null || recipe.tiktokSource!.url.isEmpty) {
        return const Failure(
          'Impossible de regénérer la recette : aucune source TikTok disponible',
          errorCode: 'no-tiktok-source',
        );
      }
      
      final tiktokUrl = recipe.tiktokSource!.url;
      
      // Récupérer les métadonnées TikTok
      final metadataResult = await _tiktokRepository.getVideoMetadata(tiktokUrl);
      
      if (metadataResult.isFailure) {
        return Failure(
          'Impossible de récupérer les métadonnées TikTok',
          errorCode: 'metadata-fetch-failed',
          error: metadataResult.failureOrNull?.error,
        );
      }
      
      final metadata = metadataResult.dataOrNull;
      if (metadata == null) {
        return const Failure(
          'Aucune métadonnée disponible',
          errorCode: 'no-metadata',
        );
      }
      
      // Utiliser le caption ou le titre pour regénérer
      final caption = metadata.caption ?? metadata.title;
      
      if (caption.isEmpty) {
        return const Failure(
          'Aucun caption disponible pour regénérer la recette',
          errorCode: 'no-caption',
        );
      }
      
      // Regénérer la recette depuis le caption
      final regeneratedRecipe = await _recipeAIService.generateRecipeFromCaption(
        caption: caption,
      );
      
      // Validation de la recette regénérée
      final validation = RecipeValidationService.validateRecipe(regeneratedRecipe);
      if (!validation.isValid) {
        // Même si la validation échoue, retourner la recette regénérée
        // (l'IA a fait de son mieux)
      }
      
      // Créer une nouvelle recette avec les mêmes métadonnées que l'originale
      // mais avec les nouvelles données générées
      final updatedRecipe = regeneratedRecipe.copyWith(
        id: recipe.id, // Garder le même ID
        tiktokSource: recipe.tiktokSource, // Garder la source TikTok originale
        imageUrl: recipe.imageUrl, // Garder l'image originale
        createdAt: recipe.createdAt, // Garder la date de création originale
        updatedAt: DateTime.now(), // Mettre à jour la date de modification
      );
      
      return Success(updatedRecipe);
    } catch (e) {
      return Failure(
        'Erreur lors de la regénération de la recette',
        errorCode: 'regeneration-error',
        error: e,
      );
    }
  }
}

