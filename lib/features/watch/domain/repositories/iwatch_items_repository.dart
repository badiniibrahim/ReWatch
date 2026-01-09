import '../entities/watch_item.dart';

/// Repository interface pour la gestion des WatchItems dans Firestore
abstract class IWatchItemsRepository {
  /// Stream des items d'un utilisateur (mise à jour en temps réel)
  Stream<List<WatchItem>> streamItems(String uid);

  /// Crée un nouvel item
  Future<void> createItem(String uid, WatchItem item);

  /// Met à jour un item existant
  Future<void> updateItem(String uid, WatchItem item);

  /// Supprime un item
  Future<void> deleteItem(String uid, String itemId);
}
