import '../../../../core/result.dart';
import '../entities/shopping_list.dart';
import '../repositories/ishopping_list_repository.dart';

/// UseCase pour sauvegarder une liste de courses.
///
/// Valide la liste et délègue l'enregistrement au repository.
class SaveShoppingListUseCase {
  final IShoppingListRepository _repository;

  SaveShoppingListUseCase(this._repository);

  Future<Result<String>> call(ShoppingList shoppingList, String userId) async {
    if (shoppingList.items.isEmpty) {
      return const Failure(
        'La liste de courses ne peut pas être vide',
        errorCode: 'empty-list',
      );
    }

    if (shoppingList.recipeId.isEmpty) {
      return const Failure(
        'L\'ID de la recette est requis',
        errorCode: 'missing-recipe-id',
      );
    }

    return await _repository.saveShoppingList(shoppingList, userId);
  }
}

