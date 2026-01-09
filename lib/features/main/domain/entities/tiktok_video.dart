/// Entité représentant les métadonnées d'une vidéo TikTok.
/// 
/// Cette entité est immuable et contient uniquement les informations publiques
/// récupérées via l'API oEmbed de TikTok.
/// 
/// Exemple :
/// ```dart
/// final video = TikTokVideo(
///   id: 'video-id',
///   url: 'https://www.tiktok.com/@user/video/123',
///   title: 'Recette de gâteau',
///   authorName: 'chef_cuisine',
///   thumbnailUrl: 'https://example.com/thumb.jpg',
/// );
/// ```
class TikTokVideo {
  /// Identifiant unique de la vidéo TikTok.
  final String id;
  
  /// URL complète de la vidéo TikTok.
  final String url;
  
  /// Titre de la vidéo.
  final String title;
  
  /// Nom d'utilisateur du créateur.
  final String authorName;
  
  /// URL de la miniature de la vidéo.
  final String? thumbnailUrl;
  
  /// Description/caption de la vidéo (texte uniquement).
  final String? caption;
  
  /// Crée une nouvelle instance de [TikTokVideo].
  const TikTokVideo({
    required this.id,
    required this.url,
    required this.title,
    required this.authorName,
    this.thumbnailUrl,
    this.caption,
  });
  
  /// Crée une copie avec les champs modifiés.
  TikTokVideo copyWith({
    String? id,
    String? url,
    String? title,
    String? authorName,
    String? thumbnailUrl,
    String? caption,
  }) {
    return TikTokVideo(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
    );
  }
  
  /// Sérialisation vers Map pour Firestore.
  Map<String, dynamic> toMap() => {
    'id': id,
    'url': url,
    'title': title,
    'authorName': authorName,
    'thumbnailUrl': thumbnailUrl,
    'caption': caption,
  };
  
  /// Désérialisation depuis Map.
  factory TikTokVideo.fromMap(Map<String, dynamic> map) => TikTokVideo(
    id: map['id'] ?? '',
    url: map['url'] ?? '',
    title: map['title'] ?? '',
    authorName: map['authorName'] ?? '',
    thumbnailUrl: map['thumbnailUrl'],
    caption: map['caption'],
  );
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TikTokVideo &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    url == other.url &&
    title == other.title &&
    authorName == other.authorName &&
    thumbnailUrl == other.thumbnailUrl &&
    caption == other.caption;
  
  @override
  int get hashCode =>
    id.hashCode ^
    url.hashCode ^
    title.hashCode ^
    authorName.hashCode ^
    (thumbnailUrl?.hashCode ?? 0) ^
    (caption?.hashCode ?? 0);
  
  @override
  String toString() =>
    'TikTokVideo(id: $id, title: $title, author: $authorName)';
}

