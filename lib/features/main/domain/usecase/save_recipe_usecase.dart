import '../../../../core/result.dart';
import '../entities/recipe.dart';
import '../repositories/irecipe_repository.dart';
import '../services/recipe_validation_service.dart';

/// UseCase pour sauvegarder une recette.
/// 
/// Ce usecase orchestre la validation et la sauvegarde de la recette
/// dans Firestore via le repository.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = SaveRecipeUseCase(repository);
/// final result = await useCase.call(recipe, userId);
/// 
/// result.when(
///   success: (recipeId) => print('Recette sauvegardée: $recipeId'),
///   failure: (message, code, error) => print('Erreur: $message'),
/// );
/// ```
class SaveRecipeUseCase {
  final IRecipeRepository _repository;
  
  /// Crée une nouvelle instance du usecase.
  /// 
  /// [repository] : Repository pour sauvegarder les recettes
  SaveRecipeUseCase(this._repository);
  
  /// Exécute le usecase et retourne le résultat.
  /// 
  /// [recipe] : La recette à sauvegarder
  /// [userId] : ID de l'utilisateur propriétaire
  /// 
  /// Retourne un [Result<String>] avec l'ID de la recette :
  /// - [Success] si la recette est validée et sauvegardée
  /// - [Failure] avec code 'validation-error' si la validation échoue
  /// - [Failure] avec code 'save-error' si la sauvegarde échoue
  Future<Result<String>> call(Recipe recipe, String userId) async {
    // Validation avant sauvegarde
    final validation = RecipeValidationService.validateRecipe(recipe);
    if (!validation.isValid) {
      return Failure(
        validation.message,
        errorCode: 'validation-error',
      );
    }
    
    try {
      return await _repository.saveRecipe(recipe, userId);
    } catch (e) {
      return Failure(
        'Erreur lors de la sauvegarde',
        errorCode: 'save-error',
        error: e,
      );
    }
  }
}

