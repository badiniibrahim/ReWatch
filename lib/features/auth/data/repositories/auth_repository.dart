import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/iauth_repository.dart';

/// Implémentation du repository d'authentification avec Firebase.
class AuthRepository implements IAuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  const AuthRepository({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  @override
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Vérifier si l'email est validé
        if (!credential.user!.emailVerified) {
          await _firebaseAuth.signOut();
          return Failure(
            'Veuillez valider votre compte en cliquant sur le lien envoyé à votre adresse email',
            errorCode: 'email-not-verified',
          );
        }

        // Générer un nom d'utilisateur
        final username = _generateUsername(
          displayName: credential.user!.displayName,
          givenName: null,
          familyName: null,
          email: credential.user!.email,
          uid: credential.user!.uid,
        );

        // S'assurer que l'utilisateur existe dans Firestore
        final user = await _ensureUserInFirestore(
          credential.user!,
          username: username,
        );

        return Success(user);
      }

      return Failure('Échec de la connexion');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Failure(_getAuthErrorMessage(e.code), errorCode: e.code);
    } catch (e) {
      return Failure('Une erreur inattendue s\'est produite');
    }
  }

  @override
  Future<Result<User?>> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 Starting sign up for email: $email');
      }

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        if (kDebugMode) {
          debugPrint('✅ Firebase user created: ${credential.user!.uid}');
        }

        // Envoyer l'email de validation
        try {
          await credential.user!.sendEmailVerification();
          if (kDebugMode) {
            debugPrint('📧 Verification email sent');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Failed to send verification email: $e');
          }
          // Continue même si l'email de vérification échoue
        }

        // Créer le profil utilisateur dans Firestore avec 2 crédits initiaux
        final user = User(
          id: credential.user!.uid,
          username: username,
          email: email,
          isEmailVerified: false,
          credits: User.initialCredits,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          await _firestore
              .collection('users')
              .doc(credential.user!.uid)
              .set(user.toMap());
          if (kDebugMode) {
            debugPrint('💾 User document created in Firestore');
          }
        } on FirebaseException catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Firestore error: ${e.code} - ${e.message}');
          }
          // Si la création Firestore échoue, on déconnecte quand même
          await _firebaseAuth.signOut();
          return Failure(
            'Erreur lors de la création du profil. Code: ${e.code}',
            errorCode: e.code,
            error: e,
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Unexpected Firestore error: $e');
          }
          await _firebaseAuth.signOut();
          return Failure(
            'Erreur lors de la création du profil',
            error: e,
          );
        }

        // Déconnecter l'utilisateur après création du compte
        await _firebaseAuth.signOut();
        if (kDebugMode) {
          debugPrint('👋 User signed out after account creation');
        }

        return Success(null);
      }

      return Failure('Échec de la création du compte');
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase Auth error: ${e.code} - ${e.message}');
        if (e.code == 'operation-not-allowed') {
          debugPrint(
            '⚠️ IMPORTANT: Email/Password authentication might not be enabled in Firebase Console.',
          );
          debugPrint(
            '   Go to Firebase Console > Authentication > Sign-in method > Enable Email/Password',
          );
        }
      }
      return Failure(_getAuthErrorMessage(e.code), errorCode: e.code);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error during sign up: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Failure('Une erreur inattendue s\'est produite');
    }
  }

  @override
  Future<Result<void>> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return Success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Failure(_getAuthErrorMessage(e.code), errorCode: e.code);
    } catch (e) {
      return Failure('Une erreur inattendue s\'est produite');
    }
  }

  @override
  Future<Result<User>> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return Failure('auth_googleSignInCanceled'.tr);
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return Failure('auth_googleSignInTokenError'.tr);
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        final username = _generateUsername(
          displayName: googleUser.displayName,
          email: googleUser.email,
          uid: userCredential.user!.uid,
        );

        final user = await _ensureUserInFirestore(
          userCredential.user!,
          username: username,
        );

        return Success(user);
      }

      return Failure('auth_googleSignInFailure'.tr);
    } on PlatformException catch (e) {
      String errorMessage;
      if (e.code == 'sign_in_failed' &&
          (e.message?.contains('10:') == true ||
              e.message?.contains('ApiException: 10') == true ||
              e.message?.contains('DEVELOPER_ERROR') == true)) {
        errorMessage = 'auth_googleSignInDeveloperError'.tr;
      } else if (e.code == 'channel-error' ||
          e.message?.contains('Unable to establish connection') == true) {
        errorMessage = 'auth_googleSignInConnectionError'.tr;
      } else {
        errorMessage =
            '${'auth_googleSignInPlatformError'.tr}: ${e.message ?? e.code}';
      }
      return Failure(errorMessage);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Failure(_getAuthErrorMessage(e.code), errorCode: e.code);
    } catch (e) {
      return Failure(
        '${'auth_googleSignInUnexpectedError'.tr}: ${e.toString()}',
      );
    }
  }

  @override
  Future<Result<User>> signInWithApple() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();

      if (!isAvailable) {
        return Failure('auth_appleSignInNotAvailable'.tr);
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = appleCredential.identityToken;
      final authorizationCode = appleCredential.authorizationCode;

      if (identityToken == null) {
        return Failure('auth_appleSignInTokenError'.tr);
      }

      final oauthCredential = firebase_auth.OAuthProvider(
        'apple.com',
      ).credential(idToken: identityToken, accessToken: authorizationCode);

      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );

      if (userCredential.user != null) {
        final username = _generateUsername(
          displayName: null,
          givenName: appleCredential.givenName,
          familyName: appleCredential.familyName,
          email: userCredential.user!.email,
          uid: userCredential.user!.uid,
        );

        final user = await _ensureUserInFirestore(
          userCredential.user!,
          username: username,
        );

        return Success(user);
      }

      return Failure('auth_appleSignInFailure'.tr);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return Failure('auth_appleSignInCanceled'.tr);
      }
      return Failure('${'auth_appleSignInError'.tr}: ${e.message}');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Failure(_getAuthErrorMessage(e.code), errorCode: e.code);
    } catch (e) {
      return Failure(
        '${'auth_appleSignInUnexpectedError'.tr}: ${e.toString()}',
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return Success(null);
    } catch (e) {
      return Failure('Erreur lors de la déconnexion');
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final user = await _getUserFromFirestore(firebaseUser.uid);
        return Success(user);
      }
      return Success(null);
    } catch (e) {
      return Failure('Erreur lors de la récupération de l\'utilisateur');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser != null) {
        return await _getUserFromFirestore(firebaseUser.uid);
      }
      return null;
    });
  }

  @override
  Stream<User?> get userDocumentChanges {
    return _firebaseAuth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) {
        return Stream<User?>.value(null);
      }

      return _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .map((snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              try {
                return User.fromMap(snapshot.data()!);
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('❌ Error parsing user from Firestore: $e');
                }
                return null;
              }
            }
            return null;
          });
    });
  }

  /// Génère un nom d'utilisateur à partir des informations disponibles.
  String _generateUsername({
    String? displayName,
    String? givenName,
    String? familyName,
    String? email,
    required String uid,
  }) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    if (givenName != null && familyName != null) {
      return '$givenName $familyName';
    }
    if (givenName != null) {
      return givenName;
    }
    if (email != null && email.isNotEmpty) {
      return email.split('@')[0];
    }
    return 'user_${uid.substring(0, 8)}';
  }

  /// Récupère les données utilisateur depuis Firestore.
  Future<User?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return User.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Crée ou met à jour l'utilisateur dans Firestore.
  Future<User> _ensureUserInFirestore(
    firebase_auth.User firebaseUser, {
    required String username,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        return User.fromMap(docSnapshot.data()!);
      } else {
        final newUser = User(
          id: firebaseUser.uid,
          username: username,
          email: firebaseUser.email ?? '',
          isEmailVerified: firebaseUser.emailVerified,
          credits: User.initialCredits,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await userDoc.set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      return User(
        id: firebaseUser.uid,
        username: username,
        email: firebaseUser.email ?? '',
        isEmailVerified: firebaseUser.emailVerified,
        credits: User.initialCredits,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<Result<User>> decrementCredits({int amount = 1}) async {
    try {
      if (kDebugMode) {
        debugPrint('💳 decrementCredits called with amount: $amount');
      }

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        if (kDebugMode) {
          debugPrint('❌ No authenticated user');
        }
        return Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }

      if (kDebugMode) {
        debugPrint('✅ User authenticated: ${firebaseUser.uid}');
      }

      // Récupérer l'utilisateur actuel
      final currentUser = await _getUserFromFirestore(firebaseUser.uid);
      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('❌ User not found in Firestore');
        }
        return Failure('Utilisateur non trouvé', errorCode: 'user-not-found');
      }

      if (kDebugMode) {
        debugPrint('📊 Current credits: ${currentUser.credits}');
      }

      // Vérifier que l'utilisateur a assez de crédits
      if (currentUser.credits < amount) {
        if (kDebugMode) {
          debugPrint(
            '❌ Insufficient credits: ${currentUser.credits} < $amount',
          );
        }
        return Failure(
          'credits_no_credits_available'.tr,
          errorCode: 'insufficient-credits',
        );
      }

      // Décrémenter les crédits
      final newCredits = currentUser.credits - amount;
      if (kDebugMode) {
        debugPrint('💳 Decrementing: ${currentUser.credits} -> $newCredits');
      }

      final updatedUser = currentUser.copyWith(
        credits: newCredits,
        updatedAt: DateTime.now(),
      );

      // Mettre à jour dans Firestore
      if (kDebugMode) {
        debugPrint('💾 Updating Firestore...');
      }
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'credits': newCredits,
        'updatedAt': updatedUser.updatedAt.toIso8601String(),
      });

      if (kDebugMode) {
        debugPrint(
          '✅ Firestore updated successfully. New credits: $newCredits',
        );
      }

      return Success(updatedUser);
    } on FirebaseException catch (e) {
      return Failure(
        'Erreur lors de la mise à jour des crédits',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      return Failure(
        'Erreur inattendue lors de la mise à jour des crédits',
        error: e,
      );
    }
  }

  @override
  Future<Result<User>> addCredits({required int amount}) async {
    try {
      if (kDebugMode) {
        debugPrint('💳 addCredits called with amount: $amount');
      }

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        if (kDebugMode) {
          debugPrint('❌ No authenticated user');
        }
        return Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }

      if (kDebugMode) {
        debugPrint('✅ User authenticated: ${firebaseUser.uid}');
      }

      // Récupérer l'utilisateur actuel
      final currentUser = await _getUserFromFirestore(firebaseUser.uid);
      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('❌ User not found in Firestore');
        }
        return Failure('Utilisateur non trouvé', errorCode: 'user-not-found');
      }

      if (kDebugMode) {
        debugPrint('📊 Current credits: ${currentUser.credits}');
      }

      // Incrémenter les crédits
      final newCredits = currentUser.credits + amount;
      if (kDebugMode) {
        debugPrint('💳 Adding: ${currentUser.credits} + $amount = $newCredits');
      }

      final updatedUser = currentUser.copyWith(
        credits: newCredits,
        updatedAt: DateTime.now(),
      );

      // Mettre à jour dans Firestore
      if (kDebugMode) {
        debugPrint('💾 Updating Firestore...');
      }
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'credits': newCredits,
        'updatedAt': updatedUser.updatedAt.toIso8601String(),
      });

      if (kDebugMode) {
        debugPrint(
          '✅ Firestore updated successfully. New credits: $newCredits',
        );
      }

      return Success(updatedUser);
    } on FirebaseException catch (e) {
      return Failure(
        'Erreur lors de la mise à jour des crédits',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      return Failure(
        'Erreur inattendue lors de la mise à jour des crédits',
        error: e,
      );
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        if (kDebugMode) {
          debugPrint('❌ No authenticated user to delete');
        }
        return Failure(
          'auth_userNotAuthenticated'.tr,
          errorCode: 'unauthenticated',
        );
      }

      final userId = firebaseUser.uid;

      if (kDebugMode) {
        debugPrint('🗑️ Starting account deletion for user: $userId');
      }

      // 1. Supprimer le document utilisateur dans Firestore
      try {
        await _firestore.collection('users').doc(userId).delete();
        if (kDebugMode) {
          debugPrint('✅ User document deleted from Firestore');
        }
      } on FirebaseException catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Firestore deletion error: ${e.code} - ${e.message}');
        }
        // Continuer quand même avec la suppression Firebase Auth
        // pour éviter de laisser un compte orphelin
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Unexpected Firestore error: $e');
        }
        // Continuer quand même avec la suppression Firebase Auth
      }

      // 2. Supprimer le compte Firebase Authentication
      try {
        await firebaseUser.delete();
        if (kDebugMode) {
          debugPrint('✅ Firebase Auth account deleted');
        }
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Firebase Auth deletion error: ${e.code} - ${e.message}');
        }
        return Failure(
          _getAuthErrorMessage(e.code),
          errorCode: e.code,
          error: e,
        );
      }

      if (kDebugMode) {
        debugPrint('✅ Account deletion completed successfully');
      }

      return Success(null);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error during account deletion: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Failure(
        'auth_accountDeletionError'.tr,
        error: e,
      );
    }
  }

  /// Convertit les codes d'erreur Firebase en messages utilisateur.
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'auth_userNotFound'.tr;
      case 'wrong-password':
        return 'auth_wrongPassword'.tr;
      case 'email-already-in-use':
        return 'auth_emailAlreadyInUse'.tr;
      case 'weak-password':
        return 'auth_weakPassword'.tr;
      case 'invalid-email':
        return 'auth_invalidEmailFormat'.tr;
      case 'user-disabled':
        return 'auth_userDisabled'.tr;
      case 'too-many-requests':
        return 'auth_tooManyRequests'.tr;
      case 'operation-not-allowed':
        return 'auth_operationNotAllowedDetailed'.tr;
      case 'network-request-failed':
        return 'auth_networkRequestFailed'.tr;
      default:
        return 'auth_unexpectedError'.tr;
    }
  }
}
