/// Entité représentant une recette de cuisine.
/// 
/// Cette entité est immuable et représente une recette complète avec
/// ses ingrédients, étapes et informations nutritionnelles.
/// 
/// Exemple :
/// ```dart
/// final recipe = Recipe(
///   id: 'recipe-id',
///   title: 'Gâteau au chocolat',
///   description: 'Un délicieux gâteau au chocolat',
///   servings: 8,
///   prepMinutes: 15,
///   cookMinutes: 30,
///   ingredients: [/* ... */],
///   steps: [/* ... */],
/// );
/// ```
class Recipe {
  /// Identifiant unique de la recette.
  final String id;
  
  /// Titre de la recette.
  final String title;
  
  /// Description de la recette.
  final String? description;
  
  /// Nombre de portions.
  final int servings;
  
  /// Temps de préparation en minutes.
  final int prepMinutes;
  
  /// Temps de cuisson en minutes.
  final int cookMinutes;
  
  /// Temps total en minutes (prepMinutes + cookMinutes).
  int get totalMinutes => prepMinutes + cookMinutes;
  
  /// Liste des ingrédients.
  final List<Ingredient> ingredients;
  
  /// Liste des étapes de préparation.
  final List<RecipeStep> steps;
  
  /// Source TikTok (si applicable).
  final TikTokSource? tiktokSource;
  
  /// Informations nutritionnelles (si disponibles).
  final Nutrition? nutrition;
  
  /// URL de l'image de la recette (sauvegardée dans Firebase Storage).
  final String? imageUrl;
  
  /// Date de création.
  final DateTime createdAt;
  
  /// Date de dernière modification.
  final DateTime updatedAt;
  
  /// Crée une nouvelle instance de [Recipe].
  const Recipe({
    required this.id,
    required this.title,
    this.description,
    required this.servings,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.ingredients,
    required this.steps,
    this.tiktokSource,
    this.nutrition,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Crée une copie avec les champs modifiés.
  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    int? servings,
    int? prepMinutes,
    int? cookMinutes,
    List<Ingredient>? ingredients,
    List<RecipeStep>? steps,
    TikTokSource? tiktokSource,
    Nutrition? nutrition,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      servings: servings ?? this.servings,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      cookMinutes: cookMinutes ?? this.cookMinutes,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      tiktokSource: tiktokSource ?? this.tiktokSource,
      nutrition: nutrition ?? this.nutrition,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Sérialisation vers Map pour Firestore.
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'servings': servings,
    'prepMinutes': prepMinutes,
    'cookMinutes': cookMinutes,
    'ingredients': ingredients.map((i) => i.toMap()).toList(),
    'steps': steps.map((s) => s.toMap()).toList(),
    'tiktokSource': tiktokSource?.toMap(),
    'nutrition': nutrition?.toMap(),
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  
  /// Désérialisation depuis Map.
  factory Recipe.fromMap(Map<String, dynamic> map) => Recipe(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    description: map['description'],
    servings: map['servings'] ?? 1,
    prepMinutes: map['prepMinutes'] ?? 0,
    cookMinutes: map['cookMinutes'] ?? 0,
    ingredients: (map['ingredients'] as List<dynamic>?)
        ?.map((i) => Ingredient.fromMap(i as Map<String, dynamic>))
        .toList() ?? [],
    steps: (map['steps'] as List<dynamic>?)
        ?.map((s) => RecipeStep.fromMap(s as Map<String, dynamic>))
        .toList() ?? [],
    tiktokSource: map['tiktokSource'] != null
        ? TikTokSource.fromMap(map['tiktokSource'] as Map<String, dynamic>)
        : null,
    nutrition: map['nutrition'] != null
        ? Nutrition.fromMap(map['nutrition'] as Map<String, dynamic>)
        : null,
    imageUrl: map['imageUrl'] as String?,
    createdAt: _parseDateTimeFromMap(map['createdAt']),
    updatedAt: _parseDateTimeFromMap(map['updatedAt']),
  );
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Recipe &&
    runtimeType == other.runtimeType &&
    id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() => 'Recipe(id: $id, title: $title)';
  
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

/// Entité représentant un ingrédient de recette.
class Ingredient {
  /// Nom de l'ingrédient.
  final String name;
  
  /// Quantité.
  final double quantity;
  
  /// Unité de mesure (g, ml, piece, etc.).
  final String unit;
  
  /// Note optionnelle (ex: "en morceaux", "coupé en dés").
  final String? note;
  
  const Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.note,
  });
  
  Ingredient copyWith({
    String? name,
    double? quantity,
    String? unit,
    String? note,
  }) {
    return Ingredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      note: note ?? this.note,
    );
  }
  
  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'note': note,
  };
  
  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
    name: map['name'] ?? '',
    quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
    unit: map['unit'] ?? 'piece',
    note: map['note'],
  );
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Ingredient &&
    runtimeType == other.runtimeType &&
    name == other.name &&
    quantity == other.quantity &&
    unit == other.unit &&
    note == other.note;
  
  @override
  int get hashCode => name.hashCode ^ quantity.hashCode ^ unit.hashCode ^ (note?.hashCode ?? 0);
}

/// Entité représentant une étape de préparation.
class RecipeStep {
  /// Numéro de l'étape (commence à 1).
  final int number;
  
  /// Description de l'étape.
  final String description;
  
  /// Durée estimée en minutes (optionnel).
  final int? durationMinutes;
  
  const RecipeStep({
    required this.number,
    required this.description,
    this.durationMinutes,
  });
  
  RecipeStep copyWith({
    int? number,
    String? description,
    int? durationMinutes,
  }) {
    return RecipeStep(
      number: number ?? this.number,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
  
  Map<String, dynamic> toMap() => {
    'number': number,
    'description': description,
    'durationMinutes': durationMinutes,
  };
  
  factory RecipeStep.fromMap(Map<String, dynamic> map) => RecipeStep(
    number: map['number'] ?? 0,
    description: map['description'] ?? '',
    durationMinutes: map['durationMinutes'] as int?,
  );
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is RecipeStep &&
    runtimeType == other.runtimeType &&
    number == other.number &&
    description == other.description &&
    durationMinutes == other.durationMinutes;
  
  @override
  int get hashCode => number.hashCode ^ description.hashCode ^ (durationMinutes?.hashCode ?? 0);
}

/// Entité représentant la source TikTok d'une recette.
class TikTokSource {
  /// URL de la vidéo TikTok.
  final String url;
  
  /// Nom d'utilisateur du créateur.
  final String authorName;
  
  /// ID de la vidéo TikTok.
  final String videoId;
  
  const TikTokSource({
    required this.url,
    required this.authorName,
    required this.videoId,
  });
  
  TikTokSource copyWith({
    String? url,
    String? authorName,
    String? videoId,
  }) {
    return TikTokSource(
      url: url ?? this.url,
      authorName: authorName ?? this.authorName,
      videoId: videoId ?? this.videoId,
    );
  }
  
  Map<String, dynamic> toMap() => {
    'url': url,
    'authorName': authorName,
    'videoId': videoId,
  };
  
  factory TikTokSource.fromMap(Map<String, dynamic> map) => TikTokSource(
    url: map['url'] ?? '',
    authorName: map['authorName'] ?? '',
    videoId: map['videoId'] ?? '',
  );
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TikTokSource &&
    runtimeType == other.runtimeType &&
    url == other.url &&
    authorName == other.authorName &&
    videoId == other.videoId;
  
  @override
  int get hashCode => url.hashCode ^ authorName.hashCode ^ videoId.hashCode;
}

/// Entité représentant les informations nutritionnelles d'une recette.
/// 
/// Contient les macronutriments (calories, protéines, glucides, lipides)
/// pour une portion de la recette.
class Nutrition {
  /// Calories par portion (kcal).
  final double calories;
  
  /// Protéines par portion (g).
  final double proteins;
  
  /// Glucides par portion (g).
  final double carbohydrates;
  
  /// Lipides par portion (g).
  final double fats;
  
  /// Fibres par portion (g) - optionnel.
  final double? fiber;
  
  /// Sucre par portion (g) - optionnel.
  final double? sugar;
  
  /// Sel par portion (g) - optionnel.
  final double? salt;
  
  const Nutrition({
    required this.calories,
    required this.proteins,
    required this.carbohydrates,
    required this.fats,
    this.fiber,
    this.sugar,
    this.salt,
  });
  
  /// Crée une copie avec les champs modifiés.
  Nutrition copyWith({
    double? calories,
    double? proteins,
    double? carbohydrates,
    double? fats,
    double? fiber,
    double? sugar,
    double? salt,
  }) {
    return Nutrition(
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fats: fats ?? this.fats,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      salt: salt ?? this.salt,
    );
  }
  
  /// Sérialisation vers Map.
  Map<String, dynamic> toMap() => {
    'calories': calories,
    'proteins': proteins,
    'carbohydrates': carbohydrates,
    'fats': fats,
    if (fiber != null) 'fiber': fiber,
    if (sugar != null) 'sugar': sugar,
    if (salt != null) 'salt': salt,
  };
  
  /// Désérialisation depuis Map.
  factory Nutrition.fromMap(Map<String, dynamic> map) => Nutrition(
    calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
    proteins: (map['proteins'] as num?)?.toDouble() ?? 0.0,
    carbohydrates: (map['carbohydrates'] as num?)?.toDouble() ?? 0.0,
    fats: (map['fats'] as num?)?.toDouble() ?? 0.0,
    fiber: (map['fiber'] as num?)?.toDouble(),
    sugar: (map['sugar'] as num?)?.toDouble(),
    salt: (map['salt'] as num?)?.toDouble(),
  );
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Nutrition &&
    runtimeType == other.runtimeType &&
    calories == other.calories &&
    proteins == other.proteins &&
    carbohydrates == other.carbohydrates &&
    fats == other.fats &&
    fiber == other.fiber &&
    sugar == other.sugar &&
    salt == other.salt;
  
  @override
  int get hashCode =>
    calories.hashCode ^
    proteins.hashCode ^
    carbohydrates.hashCode ^
    fats.hashCode ^
    (fiber?.hashCode ?? 0) ^
    (sugar?.hashCode ?? 0) ^
    (salt?.hashCode ?? 0);
}

