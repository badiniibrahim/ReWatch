import '../../../../core/result.dart';
import '../entities/user.dart';
import '../repositories/iauth_repository.dart';

/// UseCase pour incrémenter les crédits de l'utilisateur.
/// 
/// Orchestre l'incrémentation des crédits après un achat ou une attribution.
class AddCreditsUseCase {
  final IAuthRepository _repository;

  AddCreditsUseCase(this._repository);

  /// Exécute l'incrémentation des crédits.
  /// 
  /// [amount] : Nombre de crédits à ajouter
  /// 
  /// Retourne un [Result<User>] :
  /// - [Success] avec l'utilisateur mis à jour si l'incrémentation réussit
  /// - [Failure] avec un message d'erreur si :
  ///   - L'utilisateur n'est pas connecté
  ///   - Une erreur survient lors de la mise à jour
  Future<Result<User>> call({required int amount}) async {
    return await _repository.addCredits(amount: amount);
  }
}

