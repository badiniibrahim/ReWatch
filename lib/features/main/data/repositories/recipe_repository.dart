import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/result.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/irecipe_repository.dart';

/// Implémentation du repository de recettes utilisant Firestore.
/// 
/// Toutes les opérations sont sécurisées par les Security Rules Firestore
/// qui vérifient que l'utilisateur ne peut accéder qu'à ses propres recettes.
/// 
/// Exemple :
/// ```dart
/// final repository = RecipeRepository(
///   firestore: FirebaseFirestore.instance,
///   auth: FirebaseAuth.instance,
/// );
/// ```
class RecipeRepository implements IRecipeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _collectionName = 'recipes';
  
  /// Crée une nouvelle instance du repository.
  /// 
  /// [firestore] : Instance Firestore pour les opérations de base de données
  /// [auth] : Instance Firebase Auth pour l'authentification
  RecipeRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;
  
  @override
  Future<Result<String>> saveRecipe(Recipe recipe, String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      // Mettre à jour les dates
      final now = DateTime.now();
      final recipeToSave = recipe.copyWith(
        createdAt: recipe.id.isEmpty ? now : recipe.createdAt,
        updatedAt: now,
      );
      
      final recipeMap = recipeToSave.toMap();
      recipeMap['userId'] = userId; // Ajouter userId pour les Security Rules
      
      final docRef = _firestore
          .collection(_collectionName)
          .doc(recipe.id.isEmpty ? null : recipe.id);
      
      await docRef.set(recipeMap);
      
      return Success(docRef.id);
    } on FirebaseException catch (e) {
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      return Failure(
        'Erreur lors de la sauvegarde',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<Recipe>> getRecipeById(String recipeId, String userId) async {
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
          .doc(recipeId)
          .get();
      
      if (!doc.exists) {
        return const Failure(
          'Recette non trouvée',
          errorCode: 'not-found',
        );
      }
      
      final data = doc.data();
      if (data == null) {
        return const Failure(
          'Données de recette invalides',
          errorCode: 'invalid-data',
        );
      }
      
      final recipe = Recipe.fromMap({
        ...data,
        'id': doc.id,
      });
      
      return Success(recipe);
    } on FirebaseException catch (e) {
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      return Failure(
        'Erreur lors de la récupération',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<List<Recipe>>> getUserRecipes(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      if (kDebugMode) {
        debugPrint('📥 RecipeRepository: Fetching recipes for user: $userId');
        debugPrint('  - Collection: $_collectionName');
      }
      
      // Utiliser une requête qui ne nécessite pas d'index composite
      // On récupère d'abord par userId, puis on trie en mémoire
      // Cela évite d'avoir besoin d'un index Firestore
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();
      
      if (kDebugMode) {
        debugPrint('✅ RecipeRepository: Found ${querySnapshot.docs.length} documents');
      }
      
      // Trier les documents par createdAt en mémoire (descending)
      final sortedDocs = querySnapshot.docs.toList()
        ..sort((a, b) {
          final aCreatedAt = a.data()['createdAt'];
          final bCreatedAt = b.data()['createdAt'];
          
          if (aCreatedAt == null && bCreatedAt == null) return 0;
          if (aCreatedAt == null) return 1;
          if (bCreatedAt == null) return -1;
          
          // Comparer les Timestamp
          if (aCreatedAt is Timestamp && bCreatedAt is Timestamp) {
            return bCreatedAt.compareTo(aCreatedAt); // Descending
          }
          
          return 0;
        });
      
      final recipes = <Recipe>[];
      for (final doc in sortedDocs) {
        try {
          final data = doc.data();
          if (kDebugMode) {
            debugPrint('  - Document ${doc.id}: ${data.keys.join(", ")}');
          }
          
          // Convertir les Timestamp Firestore en String ISO pour le domain
          final convertedData = <String, dynamic>{
            ...data,
            'id': doc.id,
          };
          
          // Convertir createdAt si c'est un Timestamp
          if (data['createdAt'] != null) {
            if (data['createdAt'] is Timestamp) {
              convertedData['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
            }
          } else {
            convertedData['createdAt'] = DateTime.now().toIso8601String();
          }
          
          // Convertir updatedAt si c'est un Timestamp
          if (data['updatedAt'] != null) {
            if (data['updatedAt'] is Timestamp) {
              convertedData['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
            }
          } else {
            convertedData['updatedAt'] = DateTime.now().toIso8601String();
          }
          
          final recipe = Recipe.fromMap(convertedData);
          recipes.add(recipe);
          
          if (kDebugMode) {
            debugPrint('  ✅ Parsed recipe: ${recipe.title}');
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('  ❌ Error parsing document ${doc.id}: $e');
            debugPrint('  - Stack trace: $stackTrace');
            debugPrint('  - Document data: ${doc.data()}');
          }
          // Continuer avec les autres documents même si un échoue
        }
      }
      
      if (kDebugMode) {
        debugPrint('✅ RecipeRepository: Successfully parsed ${recipes.length} recipes');
      }
      
      return Success(recipes);
    } on FirebaseException catch (e) {
      // Extraire le lien de création d'index si disponible
      String errorMessage = 'Erreur Firestore';
      if (e.code == 'failed-precondition' && e.message != null) {
        // Chercher le lien d'index dans le message d'erreur
        final indexUrlMatch = RegExp(r'https://[^\s]+').firstMatch(e.message!);
        if (indexUrlMatch != null) {
          final indexUrl = indexUrlMatch.group(0);
          errorMessage = 'Un index Firestore est requis. Créez-le ici: $indexUrl';
          if (kDebugMode) {
            debugPrint('🔗 Index URL: $indexUrl');
          }
        } else {
          errorMessage = 'Un index Firestore est requis pour cette requête. Vérifiez la console Firebase.';
        }
      }
      
      return Failure(
        errorMessage,
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      return Failure(
        'Erreur lors de la récupération',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<List<Recipe>>> searchRecipes(String query, String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      // Recherche simple par titre (Firestore ne supporte pas la recherche full-text native)
      // Pour une recherche plus avancée, utiliser Algolia ou Elasticsearch
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      
      final recipes = querySnapshot.docs
          .map((doc) => Recipe.fromMap({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
      
      return Success(recipes);
    } on FirebaseException catch (e) {
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      return Failure(
        'Erreur lors de la recherche',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  @override
  Future<Result<void>> deleteRecipe(String recipeId, String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }
      
      await _firestore
          .collection(_collectionName)
          .doc(recipeId)
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
        'Erreur lors de la suppression',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
}

