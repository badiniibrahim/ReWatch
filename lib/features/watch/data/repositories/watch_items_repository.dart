import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/watch_item.dart';
import '../../domain/repositories/iwatch_items_repository.dart';

/// Repository Firestore pour la gestion des WatchItems
class WatchItemsRepository implements IWatchItemsRepository {
  final FirebaseFirestore _firestore;

  WatchItemsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  String get _collectionPath => 'watchItems';

  @override
  Stream<List<WatchItem>> streamItems(String uid) {
    return _firestore
        .collection(_collectionPath)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => WatchItem.fromJson(doc.data(), doc.id))
              .toList();

          // Tri en mémoire pour éviter l'erreur d'index Firestore combiné (where + orderBy)
          items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return items;
        });
  }

  @override
  Future<void> createItem(String uid, WatchItem item) async {
    try {
      final now = DateTime.now();
      final itemData = item.copyWith(createdAt: now, updatedAt: now).toJson();

      itemData['uid'] = uid;

      await _firestore.collection(_collectionPath).add(itemData);
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'item: $e');
    }
  }

  @override
  Future<void> updateItem(String uid, WatchItem item) async {
    try {
      final now = DateTime.now();
      final itemData = item.copyWith(updatedAt: now).toJson();

      itemData['uid'] = uid;

      await _firestore
          .collection(_collectionPath)
          .doc(item.id)
          .update(itemData);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'item: $e');
    }
  }

  @override
  Future<void> deleteItem(String uid, String itemId) async {
    try {
      await _firestore.collection(_collectionPath).doc(itemId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'item: $e');
    }
  }
}
