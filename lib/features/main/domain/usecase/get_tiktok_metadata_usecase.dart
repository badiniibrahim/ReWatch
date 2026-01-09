import '../../../../core/result.dart';
import '../entities/tiktok_video.dart';
import '../repositories/itiktok_repository.dart';

/// UseCase pour récupérer les métadonnées d'une vidéo TikTok.
/// 
/// Ce usecase orchestre la récupération des métadonnées depuis le repository
/// et gère les cas d'erreur possibles.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = GetTikTokMetadataUseCase(repository);
/// final result = await useCase.call('https://www.tiktok.com/@user/video/123');
/// 
/// result.when(
///   success: (video) => print('Titre: ${video.title}'),
///   failure: (message, code, error) => print('Erreur: $message'),
/// );
/// ```
class GetTikTokMetadataUseCase {
  final ITikTokRepository _repository;
  
  /// Crée une nouvelle instance du usecase.
  /// 
  /// [repository] : Repository pour accéder aux métadonnées TikTok
  GetTikTokMetadataUseCase(this._repository);
  
  /// Exécute le usecase et retourne le résultat.
  /// 
  /// [url] : URL complète de la vidéo TikTok
  /// 
  /// Retourne un [Result<TikTokVideo>] :
  /// - [Success] si les métadonnées sont récupérées avec succès
  /// - [Failure] avec code 'invalid-url' si l'URL est invalide
  /// - [Failure] avec code 'not-found' si la vidéo n'existe pas
  /// 
  /// Peut lancer une [TikTokException] en cas d'erreur de récupération.
  Future<Result<TikTokVideo>> call(String url) async {
    if (url.isEmpty || !url.contains('tiktok.com')) {
      return const Failure(
        'URL TikTok invalide',
        errorCode: 'invalid-url',
      );
    }
    
    try {
      return await _repository.getVideoMetadata(url);
    } catch (e) {
      return Failure(
        'Erreur lors de la récupération des métadonnées',
        errorCode: 'fetch-error',
        error: e,
      );
    }
  }
}

