import 'package:cloud_firestore/cloud_firestore.dart';

/// Type de contenu (série ou film)
enum WatchItemType {
  series,
  movie,
}

/// Statut de visionnage
enum WatchItemStatus {
  watching,
  completed,
  planned,
}

/// Entité représentant un élément à suivre (série ou film)
class WatchItem {
  final String id;
  final WatchItemType type;
  final String platform;
  final String title;
  final String? image;
  final String? description;
  final String? personalNote;
  final WatchItemStatus status;
  final int? seasonsCount;
  final int? currentSeason;
  final int? currentEpisode;
  final DateTime? lastWatchedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  WatchItem({
    required this.id,
    required this.type,
    required this.platform,
    required this.title,
    this.image,
    this.description,
    this.personalNote,
    required this.status,
    this.seasonsCount,
    this.currentSeason,
    this.currentEpisode,
    this.lastWatchedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée un WatchItem depuis un document Firestore
  factory WatchItem.fromJson(Map<String, dynamic> json, String id) {
    return WatchItem(
      id: id,
      type: WatchItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WatchItemType.movie,
      ),
      platform: json['platform'] as String,
      title: json['title'] as String,
      image: json['image'] as String?,
      description: json['description'] as String?,
      personalNote: json['personalNote'] as String?,
      status: WatchItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WatchItemStatus.planned,
      ),
      seasonsCount: json['seasonsCount'] as int?,
      currentSeason: json['currentSeason'] as int?,
      currentEpisode: json['currentEpisode'] as int?,
      lastWatchedAt: json['lastWatchedAt'] != null
          ? (json['lastWatchedAt'] as Timestamp).toDate()
          : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convertit un WatchItem en Map pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'platform': platform,
      'title': title,
      if (image != null) 'image': image,
      if (description != null) 'description': description,
      if (personalNote != null) 'personalNote': personalNote,
      'status': status.name,
      if (seasonsCount != null) 'seasonsCount': seasonsCount,
      if (currentSeason != null) 'currentSeason': currentSeason,
      if (currentEpisode != null) 'currentEpisode': currentEpisode,
      if (lastWatchedAt != null)
        'lastWatchedAt': Timestamp.fromDate(lastWatchedAt!),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Crée une copie avec des champs modifiés
  WatchItem copyWith({
    String? id,
    WatchItemType? type,
    String? platform,
    String? title,
    String? image,
    String? description,
    String? personalNote,
    WatchItemStatus? status,
    int? seasonsCount,
    int? currentSeason,
    int? currentEpisode,
    DateTime? lastWatchedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WatchItem(
      id: id ?? this.id,
      type: type ?? this.type,
      platform: platform ?? this.platform,
      title: title ?? this.title,
      image: image ?? this.image,
      description: description ?? this.description,
      personalNote: personalNote ?? this.personalNote,
      status: status ?? this.status,
      seasonsCount: seasonsCount ?? this.seasonsCount,
      currentSeason: currentSeason ?? this.currentSeason,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
