import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../../../core/result.dart';
import '../../domain/entities/tiktok_video.dart';
import '../../domain/repositories/itiktok_repository.dart';

/// Implémentation du repository TikTok utilisant l'API oEmbed.
/// 
/// Récupère les métadonnées publiques des vidéos TikTok via l'endpoint oEmbed.
/// 
/// Exemple :
/// ```dart
/// final repository = TikTokRepository();
/// final result = await repository.getVideoMetadata('https://www.tiktok.com/@user/video/123');
/// ```
class TikTokRepository implements ITikTokRepository {
  static const String _oEmbedBaseUrl = 'https://www.tiktok.com/oembed';
  
  @override
  Future<Result<TikTokVideo>> getVideoMetadata(String url) async {
    try {
      final encodedUrl = Uri.encodeComponent(url);
      final oEmbedUrl = '$_oEmbedBaseUrl?url=$encodedUrl';
      
      final response = await http.get(Uri.parse(oEmbedUrl));
      
      if (response.statusCode != 200) {
        return Failure(
          'Impossible de récupérer les métadonnées',
          errorCode: 'http-error',
        );
      }
      
      final data = json.decode(response.body) as Map<String, dynamic>;
      
      // Extraire les informations de l'oEmbed
      final title = data['title'] as String? ?? '';
      final authorName = data['author_name'] as String? ?? '';
      final thumbnailUrl = data['thumbnail_url'] as String?;
      
      // Extraire l'ID de la vidéo depuis l'URL
      final videoId = _extractVideoIdFromUrl(url);
      
      // Récupérer le caption si disponible (dans certains cas)
      final html = data['html'] as String? ?? '';
      final caption = _extractCaptionFromHtml(html);
      
      final video = TikTokVideo(
        id: videoId,
        url: url,
        title: title,
        authorName: authorName,
        thumbnailUrl: thumbnailUrl,
        caption: caption,
      );
      
      return Success(video);
    } on http.ClientException catch (e) {
      return Failure(
        'Erreur de connexion',
        errorCode: 'network-error',
        error: e,
      );
    } catch (e) {
      return Failure(
        'Erreur lors de la récupération des métadonnées',
        errorCode: 'unknown-error',
        error: e,
      );
    }
  }
  
  /// Extrait l'ID de la vidéo depuis l'URL TikTok.
  String _extractVideoIdFromUrl(String url) {
    // Format: https://www.tiktok.com/@user/video/1234567890
    final regex = RegExp(r'/video/(\d+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  /// Extrait le caption depuis le HTML oEmbed (si disponible).
  /// 
  /// Note: L'API oEmbed de TikTok ne fournit pas directement le caption.
  /// Cette méthode tente d'extraire des informations depuis le HTML,
  /// mais pour obtenir le vrai caption complet, il faudrait scraper
  /// la page TikTok directement (nécessite un service backend).
  String? _extractCaptionFromHtml(String html) {
    if (html.isEmpty) return null;
    
    // Tenter d'extraire le caption depuis le HTML oEmbed
    // Le HTML oEmbed contient parfois des métadonnées dans les attributs
    try {
      // Pattern 1: Chercher data-caption ou data-description avec guillemets doubles
      final captionPattern1 = RegExp(
        r'data-(?:caption|description)="([^"]+)"',
        caseSensitive: false,
      );
      final match1 = captionPattern1.firstMatch(html);
      if (match1 != null && match1.groupCount >= 1) {
        final extracted = match1.group(1);
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }
      
      // Pattern 2: Chercher data-caption ou data-description avec guillemets simples
      final captionPattern2 = RegExp(
        r"data-(?:caption|description)='([^']+)'",
        caseSensitive: false,
      );
      final match2 = captionPattern2.firstMatch(html);
      if (match2 != null && match2.groupCount >= 1) {
        final extracted = match2.group(1);
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }
      
      // Pattern 3: Chercher dans les balises meta og:description avec guillemets doubles
      final metaPattern1 = RegExp(
        r'<meta[^>]+property="og:description"[^>]+content="([^"]+)"',
        caseSensitive: false,
      );
      final metaMatch1 = metaPattern1.firstMatch(html);
      if (metaMatch1 != null && metaMatch1.groupCount >= 1) {
        final extracted = metaMatch1.group(1);
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }
      
      // Pattern 4: Chercher dans les balises meta og:description avec guillemets simples
      final metaPattern2 = RegExp(
        r"<meta[^>]+property='og:description'[^>]+content='([^']+)'",
        caseSensitive: false,
      );
      final metaMatch2 = metaPattern2.firstMatch(html);
      if (metaMatch2 != null && metaMatch2.groupCount >= 1) {
        final extracted = metaMatch2.group(1);
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }
    } catch (e) {
      // Si l'extraction échoue, retourner null
      return null;
    }
    
    // L'oEmbed ne fournit généralement pas le caption complet
    // Pour obtenir le vrai caption, il faudrait :
    // 1. Scraper la page TikTok directement (nécessite un service backend)
    // 2. Utiliser une API tierce qui fait le scraping
    // 3. Utiliser le partage natif qui peut contenir plus d'informations
    return null;
  }
  
  @override
  Future<Result<String>> downloadVideo(String url) async {
    try {
      // Utiliser une API tierce pour télécharger la vidéo TikTok
      // Note: Pour le MVP, on utilise une API publique de téléchargement TikTok
      // En production, il faudrait utiliser un service backend dédié
      
      // API tierce pour télécharger TikTok (exemple avec savefrom.net ou similaire)
      // ATTENTION: Vérifier les conditions d'utilisation de l'API tierce
      
      // Créer le répertoire temporaire
      final tempDir = await getTemporaryDirectory();
      final videoId = _extractVideoIdFromUrl(url);
      final videoPath = '${tempDir.path}/tiktok_${videoId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      // **Limitation connue** : Le téléchargement direct de vidéos TikTok n'est pas implémenté.
      // 
      // Raisons :
      // 1. TikTok ne fournit pas d'API publique pour télécharger les vidéos
      // 2. Le scraping direct pourrait violer les conditions d'utilisation de TikTok
      // 3. Les APIs tierces (savefrom.net, snaptik.app, etc.) peuvent être instables
      // 
      // Solutions possibles pour une future implémentation :
      // - Option 1: Utiliser un service backend dédié qui gère le scraping
      // - Option 2: Utiliser une API tierce avec gestion d'erreurs robuste
      // - Option 3: Implémenter une bibliothèque de scraping TikTok côté backend
      // 
      // Pour l'instant, on retourne une erreur explicite pour informer l'utilisateur
      // que cette fonctionnalité nécessite une implémentation backend.
      return const Failure(
        'Téléchargement de vidéo TikTok non implémenté. Veuillez utiliser un service backend.',
        errorCode: 'not-implemented',
      );
      
      // Code de production (exemple avec une API tierce) :
      // final downloadUrl = await _getVideoDownloadUrl(url);
      // final response = await dio.download(
      //   downloadUrl,
      //   videoPath,
      //   onReceiveProgress: (received, total) {
      //     // Gérer la progression si nécessaire
      //   },
      // );
      // 
      // if (response.statusCode == 200) {
      //   return Success(videoPath);
      // } else {
      //   return Failure(
      //     'Erreur lors du téléchargement',
      //     errorCode: 'download-error',
      //   );
      // }
    } catch (e) {
      return Failure(
        'Erreur lors du téléchargement de la vidéo',
        errorCode: 'download-error',
        error: e,
      );
    }
  }
}
