import '../../../../core/result.dart';
import '../entities/user.dart';
import '../repositories/iauth_repository.dart';

/// UseCase pour connecter un utilisateur avec Apple.
/// 
/// Orchestre la logique de connexion Apple et délègue au repository.
class SignInWithAppleUseCase {
  final IAuthRepository _repository;

  SignInWithAppleUseCase(this._repository);

  /// Exécute la connexion avec Apple.
  /// 
  /// Retourne un [Result<User>] :
  /// - [Success] avec l'utilisateur si la connexion réussit
  /// - [Failure] avec un message d'erreur traduit si la connexion échoue
  Future<Result<User>> call() async {
    return await _repository.signInWithApple();
  }
}

