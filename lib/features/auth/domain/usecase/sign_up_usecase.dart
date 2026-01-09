import '../../../../core/result.dart';
import '../entities/user.dart';
import '../repositories/iauth_repository.dart';

/// UseCase pour créer un nouveau compte utilisateur.
/// 
/// Orchestre la logique d'inscription et délègue au repository.
class SignUpUseCase {
  final IAuthRepository _repository;

  SignUpUseCase(this._repository);

  /// Exécute l'inscription.
  /// 
  /// [username] : Nom d'utilisateur
  /// [email] : Adresse email
  /// [password] : Mot de passe
  /// 
  /// Retourne un [Result<User?>] :
  /// - [Success] avec null si l'inscription réussit (email de vérification envoyé)
  /// - [Failure] avec un message d'erreur traduit si l'inscription échoue
  Future<Result<User?>> call({
    required String username,
    required String email,
    required String password,
  }) async {
    return await _repository.signUp(
      username: username.trim(),
      email: email.trim(),
      password: password,
    );
  }
}

