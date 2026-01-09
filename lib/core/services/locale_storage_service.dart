import 'package:get_storage/get_storage.dart';
import 'storage_key.dart';

/// Service de stockage local utilisant GetStorage.
/// 
/// Encapsule les opérations de lecture/écriture dans le stockage local
/// et fournit des méthodes utilitaires pour le debug.
class LocaleStorageService {
  final GetStorage _storage;

  LocaleStorageService() : _storage = GetStorage();

  /// Lit une valeur depuis le stockage.
  /// 
  /// [key] : Clé de stockage
  /// 
  /// Retourne la valeur stockée ou null si elle n'existe pas.
  Future<T?> read<T>(String key) async {
    try {
      return _storage.read<T>(key);
    } catch (e) {
      return null;
    }
  }

  /// Écrit une valeur dans le stockage.
  /// 
  /// [key] : Clé de stockage
  /// [value] : Valeur à stocker
  /// 
  /// Retourne true si l'écriture réussit, false sinon.
  Future<bool> write(String key, dynamic value) async {
    try {
      await _storage.write(key, value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Supprime une valeur du stockage.
  /// 
  /// [key] : Clé de stockage à supprimer
  /// 
  /// Retourne true si la suppression réussit, false sinon.
  Future<bool> remove(String key) async {
    try {
      await _storage.remove(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Efface tout le stockage.
  /// 
  /// Retourne true si l'effacement réussit, false sinon.
  Future<bool> clear() async {
    try {
      await _storage.erase();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Affiche le contenu du stockage pour le debug.
  /// 
  /// Utile pour vérifier l'état du stockage lors du développement.
  void debugStorage() {
    try {
      final keys = _storage.getKeys();
      print('📦 Storage contents:');
      for (final key in keys) {
        final value = _storage.read(key);
        print('  $key: $value');
      }
      if (keys.isEmpty) {
        print('  (empty)');
      }
    } catch (e) {
      print('❌ Error reading storage: $e');
    }
  }
}

