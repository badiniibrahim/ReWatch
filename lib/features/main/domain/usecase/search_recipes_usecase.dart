import '../../../../core/result.dart';
import '../entities/recipe.dart';
import '../repositories/irecipe_repository.dart';

/// UseCase pour rechercher des recettes par titre.
/// 
/// Ce usecase orchestre la recherche de recettes depuis le repository.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = SearchRecipesUseCase(repository);
/// final result = await useCase.call('gâteau', userId);
/// 
/// result.when(
///   success: (recipes) => print('${recipes.length} résultats'),
///   failure: (message, code, error) => print('Erreur: $message'),
/// );
/// ```
class SearchRecipesUseCase {
  final IRecipeRepository _repository;
  
  /// Crée une nouvelle instance du usecase.
  /// 
  /// [repository] : Repository pour rechercher les recettes
  SearchRecipesUseCase(this._repository);
  
  /// Exécute le usecase et retourne le résultat.
  /// 
  /// [query] : Terme de recherche
  /// [userId] : ID de l'utilisateur
  /// 
  /// Retourne un [Result<List<Recipe>>] :
  /// - [Success] avec la liste des recettes correspondantes (peut être vide)
  /// - [Failure] si une erreur survient lors de la recherche
  Future<Result<List<Recipe>>> call(String query, String userId) async {
    if (query.isEmpty) {
      return const Failure(
        'Terme de recherche vide',
        errorCode: 'empty-query',
      );
    }
    
    if (userId.isEmpty) {
      return const Failure(
        'ID utilisateur invalide',
        errorCode: 'invalid-user-id',
      );
    }
    
    try {
      return await _repository.searchRecipes(query, userId);
    } catch (e) {
      return Failure(
        'Erreur lors de la recherche',
        errorCode: 'search-error',
        error: e,
      );
    }
  }
}

