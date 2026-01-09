import '../../../../core/result.dart';
import '../entities/user.dart';
import '../repositories/iauth_repository.dart';

/// UseCase pour décrémenter les crédits de l'utilisateur.
/// 
/// Orchestre la décrémentation des crédits et vérifie que l'utilisateur
/// a suffisamment de crédits avant de procéder.
class DecrementCreditsUseCase {
  final IAuthRepository _repository;

  DecrementCreditsUseCase(this._repository);

  /// Exécute la décrémentation des crédits.
  /// 
  /// [amount] : Nombre de crédits à décrémenter (par défaut 1)
  /// 
  /// Retourne un [Result<User>] :
  /// - [Success] avec l'utilisateur mis à jour si la décrémentation réussit
  /// - [Failure] avec un message d'erreur si :
  ///   - L'utilisateur n'est pas connecté
  ///   - L'utilisateur n'a pas assez de crédits
  ///   - Une erreur survient lors de la mise à jour
  Future<Result<User>> call({int amount = 1}) async {
    return await _repository.decrementCredits(amount: amount);
  }
}

