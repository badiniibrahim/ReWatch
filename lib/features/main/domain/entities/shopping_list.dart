import 'package:uuid/uuid.dart';

/// Entité représentant une liste de courses générée depuis une recette.
/// 
/// Cette entité est immuable et représente une liste d'ingrédients
/// nécessaires pour préparer une recette.
/// 
/// Exemple :
/// ```dart
/// final shoppingList = ShoppingList(
///   recipeId: 'recipe-id',
///   recipeTitle: 'Gâteau au chocolat',
///   items: [
///     ShoppingListItem(name: 'Farine', quantity: 200, unit: 'g'),
///     ShoppingListItem(name: 'Chocolat', quantity: 150, unit: 'g'),
///   ],
/// );
/// ```
class ShoppingList {
  /// Identifiant unique de la liste de courses.
  final String id;
  
  /// ID de la recette associée.
  final String recipeId;
  
  /// Titre de la recette.
  final String recipeTitle;
  
  /// Liste des items de courses.
  final List<ShoppingListItem> items;
  
  /// Date de création.
  final DateTime createdAt;
  
  /// Date de dernière modification.
  final DateTime updatedAt;
  
  /// Crée une nouvelle instance de [ShoppingList].
  ShoppingList({
    String? id,
    required this.recipeId,
    required this.recipeTitle,
    required this.items,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  /// Crée une copie avec les champs modifiés.
  ShoppingList copyWith({
    String? id,
    String? recipeId,
    String? recipeTitle,
    List<ShoppingListItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Sérialisation vers Map pour Firestore.
  Map<String, dynamic> toMap() => {
    'id': id,
    'recipeId': recipeId,
    'recipeTitle': recipeTitle,
    'items': items.map((item) => item.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  
  /// Désérialisation depuis Map.
  factory ShoppingList.fromMap(Map<String, dynamic> map) => ShoppingList(
    id: map['id'] ?? '',
    recipeId: map['recipeId'] ?? '',
    recipeTitle: map['recipeTitle'] ?? '',
    items: (map['items'] as List<dynamic>?)
        ?.map((item) => ShoppingListItem.fromMap(item as Map<String, dynamic>))
        .toList() ?? [],
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ShoppingList &&
    runtimeType == other.runtimeType &&
    id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() => 'ShoppingList(id: $id, recipeTitle: $recipeTitle, items: ${items.length})';
}

/// Entité représentant un item de liste de courses.
/// 
/// Représente un ingrédient à acheter avec sa quantité et son unité.
class ShoppingListItem {
  /// Nom de l'ingrédient.
  final String name;
  
  /// Quantité nécessaire.
  final double quantity;
  
  /// Unité de mesure (g, ml, pièce, etc.).
  final String unit;
  
  /// Indique si l'item a été coché (acheté).
  final bool isChecked;
  
  /// Note optionnelle.
  final String? note;
  
  /// Crée une nouvelle instance de [ShoppingListItem].
  const ShoppingListItem({
    required this.name,
    required this.quantity,
    required this.unit,
    this.isChecked = false,
    this.note,
  });
  
  /// Crée une copie avec les champs modifiés.
  ShoppingListItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    bool? isChecked,
    String? note,
  }) {
    return ShoppingListItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      note: note ?? this.note,
    );
  }
  
  /// Sérialisation vers Map.
  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'isChecked': isChecked,
    if (note != null) 'note': note,
  };
  
  /// Désérialisation depuis Map.
  factory ShoppingListItem.fromMap(Map<String, dynamic> map) => ShoppingListItem(
    name: map['name'] ?? '',
    quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
    unit: map['unit'] ?? 'piece',
    isChecked: map['isChecked'] ?? false,
    note: map['note'] as String?,
  );
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ShoppingListItem &&
    runtimeType == other.runtimeType &&
    name == other.name &&
    quantity == other.quantity &&
    unit == other.unit &&
    isChecked == other.isChecked &&
    note == other.note;
  
  @override
  int get hashCode => name.hashCode ^ quantity.hashCode ^ unit.hashCode ^ isChecked.hashCode ^ (note?.hashCode ?? 0);
  
  /// Formatage de la quantité avec l'unité.
  String get formattedQuantity {
    if (quantity == quantity.toInt()) {
      return '${quantity.toInt()} $unit';
    }
    return '${quantity.toStringAsFixed(1)} $unit';
  }
}

