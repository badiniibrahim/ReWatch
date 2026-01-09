import '../../../../core/result.dart';
import '../entities/user.dart';
import '../repositories/iauth_repository.dart';

/// UseCase pour connecter un utilisateur avec email et mot de passe.
/// 
/// Orchestre la logique de connexion et délègue au repository.
class SignInUseCase {
  final IAuthRepository _repository;

  SignInUseCase(this._repository);

  /// Exécute la connexion.
  /// 
  /// [email] : Adresse email de l'utilisateur
  /// [password] : Mot de passe
  /// 
  /// Retourne un [Result<User>] :
  /// - [Success] avec l'utilisateur si la connexion réussit
  /// - [Failure] avec un message d'erreur traduit si la connexion échoue
  Future<Result<User>> call({
    required String email,
    required String password,
  }) async {
    return await _repository.signIn(
      email: email.trim(),
      password: password,
    );
  }
}

