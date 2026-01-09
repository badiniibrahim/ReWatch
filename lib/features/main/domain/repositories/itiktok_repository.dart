import '../../../../core/result.dart';
import '../entities/tiktok_video.dart';

/// Interface du repository pour les opérations TikTok.
/// 
/// Cette interface définit les opérations métier pour récupérer
/// les métadonnées des vidéos TikTok via l'API oEmbed.
abstract class ITikTokRepository {
  /// Récupère les métadonnées d'une vidéo TikTok depuis son URL.
  /// 
  /// [url] : URL complète de la vidéo TikTok
  /// 
  /// Retourne un [Result<TikTokVideo>] :
  /// - [Success] avec les métadonnées si l'URL est valide
  /// - [Failure] avec un code d'erreur si l'URL est invalide ou inaccessible
  Future<Result<TikTokVideo>> getVideoMetadata(String url);
  
  /// Télécharge une vidéo TikTok depuis son URL.
  /// 
  /// [url] : URL complète de la vidéo TikTok
  /// 
  /// Retourne un [Result<String>] avec le chemin local du fichier vidéo téléchargé :
  /// - [Success] avec le chemin du fichier si le téléchargement réussit
  /// - [Failure] avec un code d'erreur si le téléchargement échoue
  Future<Result<String>> downloadVideo(String url);
}

