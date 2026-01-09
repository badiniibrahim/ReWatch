import '../../../../core/result.dart';
import '../repositories/iauth_repository.dart';

/// UseCase pour réinitialiser le mot de passe.
/// 
/// Orchestre la logique de réinitialisation et délègue au repository.
class ResetPasswordUseCase {
  final IAuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  /// Exécute la réinitialisation du mot de passe.
  /// 
  /// [email] : Adresse email de l'utilisateur
  /// 
  /// Retourne un [Result<void>] :
  /// - [Success] si l'email de réinitialisation est envoyé
  /// - [Failure] avec un message d'erreur traduit si l'envoi échoue
  Future<Result<void>> call({required String email}) async {
    return await _repository.resetPassword(email: email.trim());
  }
}

