/// Entité représentant un signalement de problème pour une recette.
/// 
/// Cette entité est immuable et représente un signalement utilisateur
/// concernant une recette générée.
/// 
/// Exemple :
/// ```dart
/// final report = RecipeReport(
///   id: 'report-id',
///   recipeId: 'recipe-id',
///   userId: 'user-id',
///   reason: 'incorrect',
///   tiktokUrl: 'https://www.tiktok.com/@user/video/123',
///   createdAt: DateTime.now(),
/// );
/// ```
class RecipeReport {
  /// Identifiant unique du signalement.
  final String id;
  
  /// ID de la recette signalée.
  final String recipeId;
  
  /// ID de l'utilisateur qui a signalé.
  final String userId;
  
  /// Raison du signalement.
  /// 
  /// Valeurs possibles :
  /// - 'incorrect' : Recette incorrecte
  /// - 'missing_ingredients' : Ingrédients manquants
  /// - 'wrong_quantities' : Quantités incorrectes
  /// - 'other' : Autre
  final String reason;
  
  /// URL TikTok de la vidéo source (si applicable).
  final String? tiktokUrl;
  
  /// Détails supplémentaires (optionnel).
  final String? details;
  
  /// Date de création du signalement.
  final DateTime createdAt;
  
  /// Crée une nouvelle instance de [RecipeReport].
  const RecipeReport({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.reason,
    this.tiktokUrl,
    this.details,
    required this.createdAt,
  });
  
  /// Crée une copie avec les champs modifiés.
  RecipeReport copyWith({
    String? id,
    String? recipeId,
    String? userId,
    String? reason,
    String? tiktokUrl,
    String? details,
    DateTime? createdAt,
  }) {
    return RecipeReport(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      userId: userId ?? this.userId,
      reason: reason ?? this.reason,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  /// Sérialisation vers Map pour Firestore.
  Map<String, dynamic> toMap() => {
    'id': id,
    'recipeId': recipeId,
    'userId': userId,
    'reason': reason,
    'tiktokUrl': tiktokUrl,
    'details': details,
    'createdAt': createdAt.toIso8601String(),
  };
  
  /// Désérialisation depuis Map.
  factory RecipeReport.fromMap(Map<String, dynamic> map) => RecipeReport(
    id: map['id'] ?? '',
    recipeId: map['recipeId'] ?? '',
    userId: map['userId'] ?? '',
    reason: map['reason'] ?? '',
    tiktokUrl: map['tiktokUrl'] as String?,
    details: map['details'] as String?,
    createdAt: _parseDateTimeFromMap(map['createdAt']),
  );
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is RecipeReport &&
    runtimeType == other.runtimeType &&
    id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() => 'RecipeReport(id: $id, recipeId: $recipeId, reason: $reason)';
  
  /// Parse une date depuis un Map (peut être String ISO ou déjà un DateTime).
  static DateTime _parseDateTimeFromMap(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }
    
    // Si c'est une string ISO
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    // Si c'est déjà un DateTime
    if (dateValue is DateTime) {
      return dateValue;
    }
    
    // Par défaut
    return DateTime.now();
  }
}

