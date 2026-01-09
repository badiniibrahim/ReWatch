import '../../../../core/result.dart';
import '../entities/user.dart';
import '../repositories/iauth_repository.dart';

/// UseCase pour connecter un utilisateur avec Google.
/// 
/// Orchestre la logique de connexion Google et délègue au repository.
class SignInWithGoogleUseCase {
  final IAuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  /// Exécute la connexion avec Google.
  /// 
  /// Retourne un [Result<User>] :
  /// - [Success] avec l'utilisateur si la connexion réussit
  /// - [Failure] avec un message d'erreur traduit si la connexion échoue
  Future<Result<User>> call() async {
    return await _repository.signInWithGoogle();
  }
}

