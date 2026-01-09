import '../../../../core/result.dart';
import '../entities/recipe.dart';

/// Interface du repository pour les opérations sur les recettes.
/// 
/// Cette interface définit les opérations métier pour sauvegarder,
/// récupérer et rechercher des recettes dans Firestore.
abstract class IRecipeRepository {
  /// Sauvegarde une recette dans Firestore.
  /// 
  /// [recipe] : La recette à sauvegarder
  /// [userId] : ID de l'utilisateur propriétaire
  /// 
  /// Retourne un [Result<String>] avec l'ID de la recette sauvegardée.
  Future<Result<String>> saveRecipe(Recipe recipe, String userId);
  
  /// Récupère une recette par son ID.
  /// 
  /// [recipeId] : ID de la recette
  /// [userId] : ID de l'utilisateur propriétaire
  /// 
  /// Retourne un [Result<Recipe>] :
  /// - [Success] avec la recette si trouvée
  /// - [Failure] avec code 'not-found' si la recette n'existe pas
  Future<Result<Recipe>> getRecipeById(String recipeId, String userId);
  
  /// Récupère toutes les recettes d'un utilisateur.
  /// 
  /// [userId] : ID de l'utilisateur
  /// 
  /// Retourne un [Result<List<Recipe>>] avec la liste des recettes.
  Future<Result<List<Recipe>>> getUserRecipes(String userId);
  
  /// Recherche des recettes par titre.
  /// 
  /// [query] : Terme de recherche
  /// [userId] : ID de l'utilisateur
  /// 
  /// Retourne un [Result<List<Recipe>>] avec les recettes correspondantes.
  Future<Result<List<Recipe>>> searchRecipes(String query, String userId);
  
  /// Supprime une recette.
  /// 
  /// [recipeId] : ID de la recette à supprimer
  /// [userId] : ID de l'utilisateur propriétaire
  /// 
  /// Retourne un [Result<void>] :
  /// - [Success] si la suppression réussit
  /// - [Failure] si la recette n'existe pas ou n'appartient pas à l'utilisateur
  Future<Result<void>> deleteRecipe(String recipeId, String userId);
}

