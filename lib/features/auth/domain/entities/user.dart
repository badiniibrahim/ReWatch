/// Entité représentant un utilisateur de l'application.
/// 
/// Cette entité est immuable et représente les données utilisateur
/// stockées dans Firestore.
class User {
  /// Nombre de crédits initiaux attribués lors de la création du compte.
  static const int initialCredits = 2;

  /// ID unique de l'utilisateur (Firebase UID).
  final String id;
  
  /// Nom d'utilisateur.
  final String username;
  
  /// Adresse email.
  final String email;
  
  /// Indique si l'email est vérifié.
  final bool isEmailVerified;
  
  /// Nombre de crédits disponibles.
  final int credits;
  
  /// Date de création du compte.
  final DateTime createdAt;
  
  /// Date de dernière mise à jour.
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.isEmailVerified,
    required this.credits,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une copie avec les champs modifiés.
  User copyWith({
    String? id,
    String? username,
    String? email,
    bool? isEmailVerified,
    int? credits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      credits: credits ?? this.credits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Sérialisation vers Map pour Firestore.
  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'email': email,
        'isEmailVerified': isEmailVerified,
        'credits': credits,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Désérialisation depuis Map.
  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] ?? '',
        username: map['username'] ?? '',
        email: map['email'] ?? '',
        isEmailVerified: map['isEmailVerified'] ?? false,
        credits: map['credits'] ?? 0,
        createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          isEmailVerified == other.isEmailVerified &&
          credits == other.credits;

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      isEmailVerified.hashCode ^
      credits.hashCode;

  @override
  String toString() =>
      'User(id: $id, username: $username, email: $email, credits: $credits)';
}

