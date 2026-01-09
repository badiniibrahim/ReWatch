import '../../../../core/result.dart';
import '../repositories/icollection_repository.dart';

/// UseCase pour ajouter une recette à plusieurs collections.
/// 
/// Ce usecase orchestre l'ajout d'une recette à plusieurs collections
/// et gère les cas d'erreur.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = AddRecipeToCollectionsUseCase(repository);
/// final result = await useCase.call(
///   collectionIds: ['collection-1', 'collection-2'],
///   recipeId: 'recipe-id',
///   userId: 'user-id',
/// );
/// 
/// result.when(
///   success: (_) => print('Recette ajoutée aux collections'),
///   failure: (message, code, error) => print('Erreur: $message'),
/// );
/// ```
class AddRecipeToCollectionsUseCase {
  final ICollectionRepository _repository;
  
  /// Crée une nouvelle instance du usecase.
  /// 
  /// [repository] : Repository pour accéder aux données des collections
  AddRecipeToCollectionsUseCase(this._repository);
  
  /// Exécute le usecase et ajoute la recette aux collections.
  /// 
  /// [collectionIds] : Liste des IDs des collections (peut être vide)
  /// [recipeId] : ID de la recette à ajouter
  /// [userId] : ID de l'utilisateur (pour vérifier les permissions)
  /// 
  /// Retourne un [Result<void>] :
  /// - [Success] si l'opération réussit
  /// - [Failure] si la recette ou l'utilisateur est invalide
  /// 
  /// Note: Si la liste est vide, l'opération réussit sans rien faire.
  Future<Result<void>> call({
    required List<String> collectionIds,
    required String recipeId,
    required String userId,
  }) async {
    // Validation
    if (recipeId.isEmpty) {
      return const Failure('L\'ID de la recette est requis');
    }
    
    if (userId.isEmpty) {
      return const Failure('L\'ID utilisateur est requis');
    }
    
    // Si aucune collection sélectionnée, succès (pas d'erreur)
    if (collectionIds.isEmpty) {
      return const Success(null);
    }
    
    try {
      return await _repository.addRecipeToCollections(
        collectionIds,
        recipeId,
        userId,
      );
    } catch (e) {
      return Failure('Erreur lors de l\'ajout de la recette aux collections', error: e);
    }
  }
}

