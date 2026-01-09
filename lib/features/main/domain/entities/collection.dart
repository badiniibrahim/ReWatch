/// Entité représentant une collection de recettes (livre de recettes).
/// 
/// Cette entité est immuable et représente un regroupement de recettes
/// créé par l'utilisateur pour organiser ses recettes.
/// 
/// Exemple :
/// ```dart
/// final collection = Collection(
///   id: 'collection-id',
///   name: 'Mes desserts',
///   userId: 'user-id',
///   recipeIds: ['recipe-1', 'recipe-2'],
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
/// );
/// ```
class Collection {
  /// Identifiant unique de la collection.
  final String id;
  
  /// Nom de la collection.
  final String name;
  
  /// ID de l'utilisateur propriétaire.
  final String userId;
  
  /// URL de l'image de couverture (optionnel).
  final String? imageUrl;
  
  /// Liste des IDs des recettes dans cette collection.
  final List<String> recipeIds;
  
  /// Nombre de recettes dans la collection.
  int get recipeCount => recipeIds.length;
  
  /// Date de création.
  final DateTime createdAt;
  
  /// Date de dernière modification.
  final DateTime updatedAt;
  
  /// Crée une nouvelle instance de [Collection].
  const Collection({
    required this.id,
    required this.name,
    required this.userId,
    this.imageUrl,
    required this.recipeIds,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Crée une copie avec les champs modifiés.
  Collection copyWith({
    String? id,
    String? name,
    String? userId,
    String? imageUrl,
    List<String>? recipeIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      recipeIds: recipeIds ?? this.recipeIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Ajoute une recette à la collection (retourne une nouvelle instance).
  Collection addRecipe(String recipeId) {
    if (recipeIds.contains(recipeId)) {
      return this; // Déjà présente
    }
    return copyWith(
      recipeIds: [...recipeIds, recipeId],
      updatedAt: DateTime.now(),
    );
  }
  
  /// Retire une recette de la collection (retourne une nouvelle instance).
  Collection removeRecipe(String recipeId) {
    return copyWith(
      recipeIds: recipeIds.where((id) => id != recipeId).toList(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Vérifie si la collection contient une recette.
  bool containsRecipe(String recipeId) {
    return recipeIds.contains(recipeId);
  }
  
  /// Sérialisation vers Map pour Firestore.
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'userId': userId,
    'imageUrl': imageUrl,
    'recipeIds': recipeIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  
  /// Désérialisation depuis Map.
  factory Collection.fromMap(Map<String, dynamic> map) => Collection(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    userId: map['userId'] ?? '',
    imageUrl: map['imageUrl'] as String?,
    recipeIds: (map['recipeIds'] as List<dynamic>?)
        ?.map((id) => id.toString())
        .toList() ?? [],
    createdAt: _parseDateTimeFromMap(map['createdAt']),
    updatedAt: _parseDateTimeFromMap(map['updatedAt']),
  );
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Collection &&
    runtimeType == other.runtimeType &&
    id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() => 'Collection(id: $id, name: $name, recipeCount: $recipeCount)';
  
  /// Parse une date depuis un Map (peut être String ISO ou déjà un DateTime).
  /// 
  /// Note: Le parsing des Timestamp Firestore est fait dans le repository data.
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

