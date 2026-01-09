import '../../../../core/result.dart';
import '../entities/recipe.dart';
import '../entities/shopping_list.dart';

/// UseCase pour générer une liste de courses depuis une recette.
/// 
/// Extrait les ingrédients de la recette et les transforme en liste de courses
/// avec regroupement des ingrédients similaires si nécessaire.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = GenerateShoppingListUseCase();
/// 
/// final result = await useCase.call(recipe);
/// 
/// result.when(
///   success: (shoppingList) => print('Liste générée: ${shoppingList.items.length} items'),
///   failure: (message, code, error) => print('Erreur: $message'),
/// );
/// ```
class GenerateShoppingListUseCase {
  /// Crée une nouvelle instance du usecase.
  GenerateShoppingListUseCase();
  
  /// Exécute le usecase et génère la liste de courses.
  /// 
  /// [recipe] : La recette pour laquelle générer la liste de courses
  /// 
  /// Retourne un [Result<ShoppingList>] :
  /// - [Success] avec la liste de courses générée
  /// - [Failure] si la génération échoue
  Future<Result<ShoppingList>> call(Recipe recipe) async {
    try {
      if (recipe.ingredients.isEmpty) {
        return const Failure(
          'La recette ne contient aucun ingrédient',
          errorCode: 'no-ingredients',
        );
      }
      
      // Convertir les ingrédients en items de liste de courses
      final items = recipe.ingredients.map((ingredient) {
        return ShoppingListItem(
          name: ingredient.name,
          quantity: ingredient.quantity,
          unit: ingredient.unit,
          note: ingredient.note,
          isChecked: false,
        );
      }).toList();
      
      // Créer la liste de courses
      final shoppingList = ShoppingList(
        recipeId: recipe.id,
        recipeTitle: recipe.title,
        items: items,
      );
      
      return Success(shoppingList);
    } catch (e) {
      return Failure(
        'Erreur lors de la génération de la liste de courses',
        errorCode: 'generation-error',
        error: e,
      );
    }
  }
}

