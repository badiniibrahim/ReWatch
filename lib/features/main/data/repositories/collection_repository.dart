import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/result.dart';
import '../../domain/entities/collection.dart';
import '../../domain/repositories/icollection_repository.dart';
import '../../domain/repositories/irecipe_repository.dart';

/// Implémentation du repository de collections utilisant Firestore.
/// 
/// Toutes les opérations sont sécurisées par les Security Rules Firestore
/// qui vérifient que l'utilisateur ne peut accéder qu'à ses propres collections.
/// 
/// Exemple :
/// ```dart
/// final repository = CollectionRepository(
///   firestore: FirebaseFirestore.instance,
///   auth: FirebaseAuth.instance,
/// );
/// ```
class CollectionRepository implements ICollectionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final IRecipeRepository? _recipeRepository;
  static const String _collectionName = 'collections';
  
  /// Crée une nouvelle instance du repository.
  /// 
  /// [firestore] : Instance Firestore pour les opérations de base de données
  /// [auth] : Instance Firebase Auth pour l'authentification
  /// [recipeRepository] : Repository des recettes (optionnel, pour récupérer les images)
  CollectionRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    IRecipeRepository? recipeRepository,
  })  : _firestore = firestore,
        _auth = auth,
        _recipeRepository = recipeRepository;
  
  @override
  Future<Result<String>> createCollection(Collection collection) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != collection.userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      // Générer un ID si vide
      final collectionId = collection.id.isEmpty
          ? _firestore.collection(_collectionName).doc().id
          : collection.id;
      
      final collectionToSave = collection.copyWith(
        id: collectionId,
        updatedAt: DateTime.now(),
      );
      
      final collectionMap = collectionToSave.toMap();
      collectionMap['userId'] = collection.userId; // Pour les Security Rules
      
      await _firestore
          .collection(_collectionName)
          .doc(collectionId)
          .set(collectionMap);
      
      if (kDebugMode) {
        debugPrint('✅ Collection created: $collectionId');
      }
      
      return Success(collectionId);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseException creating collection: ${e.code} - ${e.message}');
      }
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error creating collection: $e');
      }
      return Failure(
        'Erreur lors de la création de la collection',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<List<Collection>>> getUserCollections(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();
      
      final collections = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id; // Ajouter l'ID du document
              return Collection.fromMap(data);
            } catch (e) {
              if (kDebugMode) {
                debugPrint('⚠️ Error parsing collection ${doc.id}: $e');
              }
              return null;
            }
          })
          .whereType<Collection>()
          .toList();
      
      if (kDebugMode) {
        debugPrint('✅ Found ${collections.length} collections for user $userId');
      }
      
      return Success(collections);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseException getting collections: ${e.code} - ${e.message}');
      }
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting collections: $e');
      }
      return Failure(
        'Erreur lors de la récupération des collections',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<Collection?>> getCollectionById(
    String collectionId,
    String userId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      final doc = await _firestore
          .collection(_collectionName)
          .doc(collectionId)
          .get();
      
      if (!doc.exists) {
        return const Success(null);
      }
      
      final data = doc.data()!;
      if (data['userId'] != userId) {
        return const Failure(
          'Collection non autorisée',
          errorCode: 'unauthorized',
        );
      }
      
      data['id'] = doc.id;
      final collection = Collection.fromMap(data);
      
      return Success(collection);
    } on FirebaseException catch (e) {
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      return Failure(
        'Erreur lors de la récupération de la collection',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<void>> updateCollection(Collection collection) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != collection.userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      final collectionMap = collection.copyWith(updatedAt: DateTime.now()).toMap();
      collectionMap['userId'] = collection.userId;
      
      await _firestore
          .collection(_collectionName)
          .doc(collection.id)
          .update(collectionMap);
      
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      return Failure(
        'Erreur lors de la mise à jour de la collection',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<void>> deleteCollection(String collectionId, String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      // Vérifier que la collection appartient à l'utilisateur
      final doc = await _firestore
          .collection(_collectionName)
          .doc(collectionId)
          .get();
      
      if (!doc.exists) {
        return const Failure(
          'Collection non trouvée',
          errorCode: 'not-found',
        );
      }
      
      if (doc.data()?['userId'] != userId) {
        return const Failure(
          'Collection non autorisée',
          errorCode: 'unauthorized',
        );
      }
      
      await _firestore
          .collection(_collectionName)
          .doc(collectionId)
          .delete();
      
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      return Failure(
        'Erreur lors de la suppression de la collection',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<void>> addRecipeToCollection(
    String collectionId,
    String recipeId,
    String userId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      // Récupérer la collection
      final collectionResult = await getCollectionById(collectionId, userId);
      
      return await collectionResult.when(
        success: (collection) async {
          if (collection == null) {
            return const Failure(
              'Collection non trouvée',
              errorCode: 'not-found',
            );
          }
          
          // Vérifier que la recette n'est pas déjà dans la collection
          if (collection.containsRecipe(recipeId)) {
            return const Success(null); // Déjà présente, pas d'erreur
          }
          
          // Si la collection n'a pas d'image et qu'on a accès au repository de recettes,
          // récupérer l'image de la première recette ajoutée
          String? newImageUrl = collection.imageUrl;
          if (newImageUrl == null && _recipeRepository != null) {
            // Récupérer l'image de la recette
            final recipeResult = await _recipeRepository.getRecipeById(recipeId, userId);
            recipeResult.when(
              success: (recipe) {
                if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
                  newImageUrl = recipe.imageUrl;
                  if (kDebugMode) {
                    debugPrint('✅ Using recipe image as collection cover: $newImageUrl');
                  }
                }
              },
              failure: (message, errorCode, error) {
                if (kDebugMode) {
                  debugPrint('⚠️ Could not get recipe image for collection: $message');
                }
                // Continuer sans image si on ne peut pas récupérer la recette
              },
            );
          }
          
          // Ajouter la recette
          final updatedCollection = collection.addRecipe(recipeId);
          
          // Mettre à jour l'image si on en a une nouvelle
          final collectionToUpdate = newImageUrl != null
              ? updatedCollection.copyWith(imageUrl: newImageUrl)
              : updatedCollection;
          
          return await updateCollection(collectionToUpdate);
        },
        failure: (message, errorCode, error) {
          return Failure(message, errorCode: errorCode, error: error);
        },
      );
    } catch (e) {
      return Failure(
        'Erreur lors de l\'ajout de la recette à la collection',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<void>> removeRecipeFromCollection(
    String collectionId,
    String recipeId,
    String userId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      // Récupérer la collection
      final collectionResult = await getCollectionById(collectionId, userId);
      
      return await collectionResult.when(
        success: (collection) async {
          if (collection == null) {
            return const Failure(
              'Collection non trouvée',
              errorCode: 'not-found',
            );
          }
          
          // Retirer la recette
          final updatedCollection = collection.removeRecipe(recipeId);
          return await updateCollection(updatedCollection);
        },
        failure: (message, errorCode, error) {
          return Failure(message, errorCode: errorCode, error: error);
        },
      );
    } catch (e) {
      return Failure(
        'Erreur lors du retrait de la recette de la collection',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<void>> addRecipeToCollections(
    List<String> collectionIds,
    String recipeId,
    String userId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      // Ajouter la recette à chaque collection
      // Note: addRecipeToCollection gère automatiquement l'image de la collection
      for (final collectionId in collectionIds) {
        final result = await addRecipeToCollection(collectionId, recipeId, userId);
        
        // Si une erreur survient, continuer avec les autres mais logger
        result.when(
          success: (_) {
            if (kDebugMode) {
              debugPrint('✅ Recipe $recipeId added to collection $collectionId');
            }
          },
          failure: (message, errorCode, error) {
            if (kDebugMode) {
              debugPrint('⚠️ Failed to add recipe to collection $collectionId: $message');
            }
            // Ne pas arrêter le processus, continuer avec les autres collections
          },
        );
      }
      
      return const Success(null);
    } catch (e) {
      return Failure(
        'Erreur lors de l\'ajout de la recette aux collections',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
}

