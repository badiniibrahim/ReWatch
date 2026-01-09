import '../../../../core/result.dart';
import '../entities/recipe.dart';
import '../repositories/irecipe_repository.dart';

/// UseCase pour récupérer toutes les recettes d'un utilisateur.
/// 
/// Ce usecase orchestre la récupération des recettes depuis le repository.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = GetUserRecipesUseCase(repository);
/// final result = await useCase.call(userId);
/// 
/// result.when(
///   success: (recipes) => print('${recipes.length} recettes trouvées'),
///   failure: (message, code, error) => print('Erreur: $message'),
/// );
/// ```
class GetUserRecipesUseCase {
  final IRecipeRepository _repository;
  
  /// Crée une nouvelle instance du usecase.
  /// 
  /// [repository] : Repository pour récupérer les recettes
  GetUserRecipesUseCase(this._repository);
  
  /// Exécute le usecase et retourne le résultat.
  /// 
  /// [userId] : ID de l'utilisateur
  /// 
  /// Retourne un [Result<List<Recipe>>] :
  /// - [Success] avec la liste des recettes (peut être vide)
  /// - [Failure] si une erreur survient lors de la récupération
  Future<Result<List<Recipe>>> call(String userId) async {
    if (userId.isEmpty) {
      return const Failure(
        'ID utilisateur invalide',
        errorCode: 'invalid-user-id',
      );
    }
    
    try {
      return await _repository.getUserRecipes(userId);
    } catch (e) {
      return Failure(
        'Erreur lors de la récupération des recettes',
        errorCode: 'fetch-error',
        error: e,
      );
    }
  }
}

