import '../../../../core/result.dart';
import '../entities/collection.dart';

/// Interface du repository pour les collections de recettes.
/// 
/// Définit les opérations CRUD sur les collections de recettes.
/// 
/// L'implémentation doit être dans `data/repositories/collection_repository.dart`.
abstract class ICollectionRepository {
  /// Crée une nouvelle collection.
  /// 
  /// [collection] : La collection à créer
  /// 
  /// Retourne un [Result<String>] avec l'ID de la collection créée.
  Future<Result<String>> createCollection(Collection collection);
  
  /// Récupère toutes les collections d'un utilisateur.
  /// 
  /// [userId] : ID de l'utilisateur
  /// 
  /// Retourne un [Result<List<Collection>>] avec la liste des collections.
  Future<Result<List<Collection>>> getUserCollections(String userId);
  
  /// Récupère une collection par son ID.
  /// 
  /// [collectionId] : ID de la collection
  /// [userId] : ID de l'utilisateur (pour vérifier les permissions)
  /// 
  /// Retourne un [Result<Collection>] avec la collection ou null si non trouvée.
  Future<Result<Collection?>> getCollectionById(String collectionId, String userId);
  
  /// Met à jour une collection.
  /// 
  /// [collection] : La collection à mettre à jour
  /// 
  /// Retourne un [Result<void>].
  Future<Result<void>> updateCollection(Collection collection);
  
  /// Supprime une collection.
  /// 
  /// [collectionId] : ID de la collection à supprimer
  /// [userId] : ID de l'utilisateur (pour vérifier les permissions)
  /// 
  /// Retourne un [Result<void>].
  Future<Result<void>> deleteCollection(String collectionId, String userId);
  
  /// Ajoute une recette à une collection.
  /// 
  /// [collectionId] : ID de la collection
  /// [recipeId] : ID de la recette à ajouter
  /// [userId] : ID de l'utilisateur (pour vérifier les permissions)
  /// 
  /// Retourne un [Result<void>].
  Future<Result<void>> addRecipeToCollection(
    String collectionId,
    String recipeId,
    String userId,
  );
  
  /// Retire une recette d'une collection.
  /// 
  /// [collectionId] : ID de la collection
  /// [recipeId] : ID de la recette à retirer
  /// [userId] : ID de l'utilisateur (pour vérifier les permissions)
  /// 
  /// Retourne un [Result<void>].
  Future<Result<void>> removeRecipeFromCollection(
    String collectionId,
    String recipeId,
    String userId,
  );
  
  /// Ajoute une recette à plusieurs collections.
  /// 
  /// [collectionIds] : Liste des IDs des collections
  /// [recipeId] : ID de la recette à ajouter
  /// [userId] : ID de l'utilisateur (pour vérifier les permissions)
  /// 
  /// Retourne un [Result<void>].
  Future<Result<void>> addRecipeToCollections(
    List<String> collectionIds,
    String recipeId,
    String userId,
  );
}

