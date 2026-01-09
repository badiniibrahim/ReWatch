import '../../../../core/result.dart';
import '../entities/user.dart';

/// Interface du repository d'authentification.
/// 
/// Définit les opérations d'authentification (connexion, inscription,
/// réinitialisation de mot de passe, connexion sociale).
abstract class IAuthRepository {
  /// Connecte un utilisateur avec email et mot de passe.
  /// 
  /// [email] : Adresse email de l'utilisateur
  /// [password] : Mot de passe
  /// 
  /// Retourne un [Result<User>] :
  /// - [Success] avec l'utilisateur si la connexion réussit
  /// - [Failure] avec un message d'erreur si la connexion échoue
  Future<Result<User>> signIn({
    required String email,
    required String password,
  });

  /// Crée un nouveau compte utilisateur.
  /// 
  /// [username] : Nom d'utilisateur
  /// [email] : Adresse email
  /// [password] : Mot de passe
  /// 
  /// Retourne un [Result<User?>] :
  /// - [Success] avec null si l'inscription réussit (email de vérification envoyé)
  /// - [Failure] avec un message d'erreur si l'inscription échoue
  Future<Result<User?>> signUp({
    required String username,
    required String email,
    required String password,
  });

  /// Envoie un email de réinitialisation de mot de passe.
  /// 
  /// [email] : Adresse email de l'utilisateur
  /// 
  /// Retourne un [Result<void>] :
  /// - [Success] si l'email est envoyé
  /// - [Failure] avec un message d'erreur si l'envoi échoue
  Future<Result<void>> resetPassword({required String email});

  /// Connecte un utilisateur avec Google.
  /// 
  /// Retourne un [Result<User>] :
  /// - [Success] avec l'utilisateur si la connexion réussit
  /// - [Failure] avec un message d'erreur si la connexion échoue
  Future<Result<User>> signInWithGoogle();

  /// Connecte un utilisateur avec Apple.
  /// 
  /// Retourne un [Result<User>] :
  /// - [Success] avec l'utilisateur si la connexion réussit
  /// - [Failure] avec un message d'erreur si la connexion échoue
  Future<Result<User>> signInWithApple();

  /// Déconnecte l'utilisateur actuel.
  /// 
  /// Retourne un [Result<void>] :
  /// - [Success] si la déconnexion réussit
  /// - [Failure] avec un message d'erreur si la déconnexion échoue
  Future<Result<void>> signOut();

  /// Récupère l'utilisateur actuellement connecté.
  /// 
  /// Retourne un [Result<User?>] :
  /// - [Success] avec l'utilisateur si connecté, null sinon
  /// - [Failure] en cas d'erreur
  Future<Result<User?>> getCurrentUser();

  /// Stream des changements d'état d'authentification.
  /// 
  /// Émet un [User?] :
  /// - L'utilisateur si connecté
  /// - null si déconnecté
  Stream<User?> get authStateChanges;

  /// Stream des changements du document utilisateur dans Firestore.
  /// 
  /// Émet un [User?] à chaque modification du document utilisateur dans Firestore,
  /// y compris les changements de crédits.
  /// 
  /// Retourne null si l'utilisateur n'est pas connecté.
  Stream<User?> get userDocumentChanges;

  /// Décrémente les crédits de l'utilisateur actuel.
  /// 
  /// [amount] : Nombre de crédits à décrémenter (par défaut 1)
  /// 
  /// Retourne un [Result<User>] :
  /// - [Success] avec l'utilisateur mis à jour si la décrémentation réussit
  /// - [Failure] avec un message d'erreur si :
  ///   - L'utilisateur n'est pas connecté
  ///   - L'utilisateur n'a pas assez de crédits
  ///   - Une erreur survient lors de la mise à jour
  Future<Result<User>> decrementCredits({int amount = 1});

  /// Incrémente les crédits de l'utilisateur actuel.
  /// 
  /// [amount] : Nombre de crédits à ajouter
  /// 
  /// Retourne un [Result<User>] :
  /// - [Success] avec l'utilisateur mis à jour si l'incrémentation réussit
  /// - [Failure] avec un message d'erreur si :
  ///   - L'utilisateur n'est pas connecté
  ///   - Une erreur survient lors de la mise à jour
  Future<Result<User>> addCredits({required int amount});

  /// Supprime définitivement le compte de l'utilisateur actuel.
  /// 
  /// Supprime :
  /// - Le document utilisateur dans Firestore
  /// - Le compte Firebase Authentication
  /// 
  /// Retourne un [Result<void>] :
  /// - [Success] si la suppression réussit
  /// - [Failure] avec un message d'erreur si :
  ///   - L'utilisateur n'est pas connecté
  ///   - Une erreur survient lors de la suppression
  Future<Result<void>> deleteAccount();
}

