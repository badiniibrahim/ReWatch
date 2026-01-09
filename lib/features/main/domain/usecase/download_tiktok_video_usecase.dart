import '../../../../core/result.dart';
import '../repositories/itiktok_repository.dart';

/// UseCase pour télécharger une vidéo TikTok.
/// 
/// Ce usecase orchestre le téléchargement de la vidéo depuis le repository
/// et gère les cas d'erreur possibles.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = DownloadTikTokVideoUseCase(repository);
/// final result = await useCase.call('https://www.tiktok.com/@user/video/123');
/// 
/// result.when(
///   success: (videoPath) => print('Vidéo téléchargée: $videoPath'),
///   failure: (message, code, error) => print('Erreur: $message'),
/// );
/// ```
class DownloadTikTokVideoUseCase {
  final ITikTokRepository _repository;
  
  /// Crée une nouvelle instance du usecase.
  /// 
  /// [repository] : Repository pour télécharger les vidéos TikTok
  DownloadTikTokVideoUseCase(this._repository);
  
  /// Exécute le usecase et retourne le résultat.
  /// 
  /// [url] : URL complète de la vidéo TikTok
  /// 
  /// Retourne un [Result<String>] avec le chemin local du fichier vidéo :
  /// - [Success] si le téléchargement réussit
  /// - [Failure] avec code 'invalid-url' si l'URL est invalide
  /// - [Failure] avec code 'download-error' si le téléchargement échoue
  Future<Result<String>> call(String url) async {
    if (url.isEmpty || !url.contains('tiktok.com')) {
      return const Failure(
        'URL TikTok invalide',
        errorCode: 'invalid-url',
      );
    }
    
    try {
      return await _repository.downloadVideo(url);
    } catch (e) {
      return Failure(
        'Erreur lors du téléchargement de la vidéo',
        errorCode: 'download-error',
        error: e,
      );
    }
  }
}

