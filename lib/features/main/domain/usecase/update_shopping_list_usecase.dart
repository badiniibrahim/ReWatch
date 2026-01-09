import '../../../../core/result.dart';
import '../entities/shopping_list.dart';
import '../repositories/ishopping_list_repository.dart';

/// UseCase pour mettre à jour une liste de courses.
///
/// Valide la liste et délègue la mise à jour au repository.
class UpdateShoppingListUseCase {
  final IShoppingListRepository _repository;

  UpdateShoppingListUseCase(this._repository);

  Future<Result<void>> call(ShoppingList shoppingList, String userId) async {
    if (shoppingList.items.isEmpty) {
      return const Failure(
        'La liste de courses ne peut pas être vide',
        errorCode: 'empty-list',
      );
    }

    if (shoppingList.id.isEmpty) {
      return const Failure(
        'L\'ID de la liste est requis',
        errorCode: 'missing-list-id',
      );
    }

    return await _repository.updateShoppingList(shoppingList, userId);
  }
}

