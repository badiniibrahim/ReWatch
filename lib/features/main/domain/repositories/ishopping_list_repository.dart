import '../../../../core/result.dart';
import '../entities/shopping_list.dart';

/// Interface pour le repository des listes de courses.
///
/// Définit les opérations CRUD pour les listes de courses.
abstract class IShoppingListRepository {
  /// Enregistre une nouvelle liste de courses.
  Future<Result<String>> saveShoppingList(ShoppingList shoppingList, String userId);

  /// Récupère une liste de courses par son ID.
  Future<Result<ShoppingList>> getShoppingListById(String listId, String userId);

  /// Récupère toutes les listes de courses d'un utilisateur.
  Future<Result<List<ShoppingList>>> getUserShoppingLists(String userId);

  /// Récupère la liste de courses associée à une recette.
  Future<Result<ShoppingList?>> getShoppingListByRecipeId(String recipeId, String userId);

  /// Met à jour une liste de courses existante.
  Future<Result<void>> updateShoppingList(ShoppingList shoppingList, String userId);

  /// Supprime une liste de courses.
  Future<Result<void>> deleteShoppingList(String listId, String userId);
}

