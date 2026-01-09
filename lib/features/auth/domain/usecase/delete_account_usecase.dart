import '../../../../core/result.dart';
import '../repositories/iauth_repository.dart';

/// UseCase pour supprimer définitivement le compte de l'utilisateur.
/// 
/// Orchestre la logique de suppression de compte et délègue au repository.
/// 
/// La suppression inclut :
/// - Le document utilisateur dans Firestore
/// - Le compte Firebase Authentication
class DeleteAccountUseCase {
  final IAuthRepository _repository;

  DeleteAccountUseCase(this._repository);

  /// Exécute la suppression du compte.
  /// 
  /// Retourne un [Result<void>] :
  /// - [Success] si la suppression réussit
  /// - [Failure] avec un message d'erreur traduit si la suppression échoue
  Future<Result<void>> call() async {
    return await _repository.deleteAccount();
  }
}

