import '../../../../core/result.dart';
import '../entities/collection.dart';
import '../repositories/icollection_repository.dart';

/// UseCase pour récupérer toutes les collections d'un utilisateur.
/// 
/// Ce usecase orchestre la récupération des collections et gère les cas d'erreur.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = GetUserCollectionsUseCase(repository);
/// final result = await useCase.call('user-id');
/// 
/// result.when(
///   success: (collections) => print('${collections.length} collections'),
///   failure: (message, code, error) => print('Erreur: $message'),
/// );
/// ```
class GetUserCollectionsUseCase {
  final ICollectionRepository _repository;
  
  /// Crée une nouvelle instance du usecase.
  /// 
  /// [repository] : Repository pour accéder aux données des collections
  GetUserCollectionsUseCase(this._repository);
  
  /// Exécute le usecase et récupère les collections.
  /// 
  /// [userId] : ID de l'utilisateur
  /// 
  /// Retourne un [Result<List<Collection>>] :
  /// - [Success] avec la liste des collections (peut être vide)
  /// - [Failure] en cas d'erreur
  Future<Result<List<Collection>>> call(String userId) async {
    if (userId.isEmpty) {
      return const Failure('L\'ID utilisateur est requis');
    }
    
    try {
      return await _repository.getUserCollections(userId);
    } catch (e) {
      return Failure('Erreur lors de la récupération des collections', error: e);
    }
  }
}

