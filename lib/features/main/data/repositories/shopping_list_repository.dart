import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/result.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/repositories/ishopping_list_repository.dart';

/// Implémentation du repository pour les listes de courses utilisant Firestore.
///
/// Toutes les opérations sont sécurisées par les Security Rules Firestore
/// qui vérifient que l'utilisateur ne peut accéder qu'à ses propres listes.
class ShoppingListRepository implements IShoppingListRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _collectionName = 'shoppingLists';

  ShoppingListRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  @override
  Future<Result<String>> saveShoppingList(ShoppingList shoppingList, String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }

      final listMap = shoppingList.toMap();
      // Retirer 'id' car c'est l'ID du document, pas un champ
      listMap.remove('id');
      listMap['userId'] = userId;

      // Convertir les dates en Timestamp Firestore
      listMap['createdAt'] = Timestamp.fromDate(shoppingList.createdAt);
      listMap['updatedAt'] = Timestamp.fromDate(shoppingList.updatedAt);

      final docRef = _firestore
          .collection(_collectionName)
          .doc(shoppingList.id.isEmpty ? null : shoppingList.id);

      await docRef.set(listMap);

      return Success(docRef.id);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseException saving shopping list: ${e.code} - ${e.message}');
      }
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error saving shopping list: $e');
      }
      return Failure(
        'Erreur lors de la sauvegarde',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }

  @override
  Future<Result<ShoppingList>> getShoppingListById(String listId, String userId) async {
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
          .doc(listId)
          .get();

      if (!doc.exists) {
        return const Failure(
          'Liste de courses non trouvée',
          errorCode: 'not-found',
        );
      }

      final data = doc.data()!;
      if (data['userId'] != userId) {
        return const Failure(
          'Accès non autorisé',
          errorCode: 'unauthorized',
        );
      }

      // Convertir Timestamp en DateTime
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      final updatedAt = (data['updatedAt'] as Timestamp).toDate();
      data['createdAt'] = createdAt.toIso8601String();
      data['updatedAt'] = updatedAt.toIso8601String();

      final shoppingList = ShoppingList.fromMap(data);
      return Success(shoppingList);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseException getting shopping list: ${e.code} - ${e.message}');
      }
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error getting shopping list: $e');
      }
      return Failure(
        'Erreur lors de la récupération',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }

  @override
  Future<Result<List<ShoppingList>>> getUserShoppingLists(String userId) async {
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
          .orderBy('createdAt', descending: true)
          .get();

      final lists = querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Convertir Timestamp en DateTime
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final updatedAt = (data['updatedAt'] as Timestamp).toDate();
        data['createdAt'] = createdAt.toIso8601String();
        data['updatedAt'] = updatedAt.toIso8601String();
        return ShoppingList.fromMap(data);
      }).toList();

      return Success(lists);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseException getting user shopping lists: ${e.code} - ${e.message}');
      }
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error getting user shopping lists: $e');
      }
      return Failure(
        'Erreur lors de la récupération',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }

  @override
  Future<Result<ShoppingList?>> getShoppingListByRecipeId(String recipeId, String userId) async {
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
          .where('recipeId', isEqualTo: recipeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Success(null);
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      // Convertir Timestamp en DateTime
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      final updatedAt = (data['updatedAt'] as Timestamp).toDate();
      data['createdAt'] = createdAt.toIso8601String();
      data['updatedAt'] = updatedAt.toIso8601String();

      final shoppingList = ShoppingList.fromMap(data);
      return Success(shoppingList);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseException getting shopping list by recipe: ${e.code} - ${e.message}');
      }
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error getting shopping list by recipe: $e');
      }
      return Failure(
        'Erreur lors de la récupération',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }

  @override
  Future<Result<void>> updateShoppingList(ShoppingList shoppingList, String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        return const Failure(
          'Utilisateur non authentifié',
          errorCode: 'unauthenticated',
        );
      }

      // Vérifier si le document existe
      final docRef = _firestore.collection(_collectionName).doc(shoppingList.id);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        // Si le document n'existe pas, créer un nouveau document
        final listMap = shoppingList.copyWith(updatedAt: DateTime.now()).toMap();
        // Retirer 'id' car c'est l'ID du document, pas un champ
        listMap.remove('id');
        listMap['userId'] = userId;

        // Convertir les dates en Timestamp Firestore
        listMap['createdAt'] = Timestamp.fromDate(shoppingList.createdAt);
        listMap['updatedAt'] = Timestamp.fromDate(DateTime.now());

        await docRef.set(listMap);
      } else {
        // Vérifier que le document a un userId et qu'il correspond
        final existingData = docSnapshot.data();
        if (existingData == null) {
          return const Failure(
            'Document introuvable',
            errorCode: 'not-found',
          );
        }
        
        final existingUserId = existingData['userId'] as String?;
        if (existingUserId == null || existingUserId != userId) {
          return const Failure(
            'Permission refusée : vous n\'êtes pas le propriétaire de cette liste',
            errorCode: 'permission-denied',
          );
        }
        
        // Si le document existe, faire une mise à jour
        // Ne mettre à jour que les champs qui peuvent changer (pas createdAt, pas id)
        final listMap = shoppingList.copyWith(updatedAt: DateTime.now()).toMap();
        // Retirer 'id' car c'est l'ID du document, pas un champ
        listMap.remove('id');
        // Ne pas inclure createdAt dans l'update (il ne doit pas changer)
        listMap.remove('createdAt');
        // S'assurer que userId est présent et correct
        listMap['userId'] = userId;

        // Convertir updatedAt en Timestamp Firestore
        listMap['updatedAt'] = Timestamp.fromDate(DateTime.now());

        await docRef.update(listMap);
      }

      return const Success(null);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseException updating shopping list: ${e.code} - ${e.message}');
      }
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error updating shopping list: $e');
      }
      return Failure(
        'Erreur lors de la mise à jour',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }

  @override
  Future<Result<void>> deleteShoppingList(String listId, String userId) async {
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
          .doc(listId)
          .delete();

      return const Success(null);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseException deleting shopping list: ${e.code} - ${e.message}');
      }
      return Failure(
        'Erreur Firestore',
        errorCode: e.code,
        error: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error deleting shopping list: $e');
      }
      return Failure(
        'Erreur lors de la suppression',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
}

