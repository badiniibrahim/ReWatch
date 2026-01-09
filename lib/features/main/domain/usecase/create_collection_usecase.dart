import '../../../../core/result.dart';
import '../entities/collection.dart';
import '../repositories/icollection_repository.dart';

/// UseCase pour créer une nouvelle collection de recettes.
/// 
/// Ce usecase orchestre la création d'une collection et gère les cas d'erreur.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = CreateCollectionUseCase(repository);
/// final result = await useCase.call(
///   name: 'Mes desserts',
///   userId: 'user-id',
/// );
/// 
/// result.when(
///   success: (collectionId) => print('Collection créée: $collectionId'),
///   failure: (message, code, error) => print('Erreur: $message'),
/// );
/// ```
class CreateCollectionUseCase {
  final ICollectionRepository _repository;
  
  /// Crée une nouvelle instance du usecase.
  /// 
  /// [repository] : Repository pour accéder aux données des collections
  CreateCollectionUseCase(this._repository);
  
  /// Exécute le usecase et crée une collection.
  /// 
  /// [name] : Nom de la collection (doit être non vide)
  /// [userId] : ID de l'utilisateur propriétaire
  /// [imageUrl] : URL de l'image de couverture (optionnel)
  /// 
  /// Retourne un [Result<String>] :
  /// - [Success] avec l'ID de la collection créée
  /// - [Failure] si le nom est vide ou en cas d'erreur
  Future<Result<String>> call({
    required String name,
    required String userId,
    String? imageUrl,
  }) async {
    // Validation
    if (name.trim().isEmpty) {
      return const Failure('Le nom de la collection est requis');
    }
    
    if (userId.isEmpty) {
      return const Failure('L\'ID utilisateur est requis');
    }
    
    // Créer la collection
    final now = DateTime.now();
    final collection = Collection(
      id: '', // Sera généré par le repository
      name: name.trim(),
      userId: userId,
      imageUrl: imageUrl,
      recipeIds: [],
      createdAt: now,
      updatedAt: now,
    );
    
    try {
      return await _repository.createCollection(collection);
    } catch (e) {
      return Failure('Erreur lors de la création de la collection', error: e);
    }
  }
}

