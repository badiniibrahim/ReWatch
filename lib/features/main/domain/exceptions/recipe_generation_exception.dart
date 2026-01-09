/// Exception personnalisée pour les erreurs de génération de recette.
/// 
/// Permet de distinguer les différents types d'erreurs et d'afficher
/// des messages user-friendly appropriés.
class RecipeGenerationException implements Exception {
  final String message;
  final String code;
  final String? originalMessage;

  const RecipeGenerationException({
    required this.message,
    required this.code,
    this.originalMessage,
  });

  /// Exception pour une légende trop vague ou insuffisante.
  factory RecipeGenerationException.insufficientCaption({
    String? originalMessage,
  }) {
    return RecipeGenerationException(
      message: 'recipe_error_insufficient_caption',
      code: 'insufficient-caption',
      originalMessage: originalMessage,
    );
  }

  /// Exception pour une erreur de parsing JSON.
  factory RecipeGenerationException.parsingError({
    required String originalError,
    String? originalMessage,
  }) {
    // Vérifier si c'est une erreur de légende insuffisante
    if (originalMessage != null &&
        (originalMessage.toLowerCase().contains('ne contient pas suffisamment') ||
         originalMessage.toLowerCase().contains('trop vague') ||
         originalMessage.toLowerCase().contains('pas suffisamment d\'informations'))) {
      return RecipeGenerationException.insufficientCaption(
        originalMessage: originalMessage,
      );
    }

    return RecipeGenerationException(
      message: 'recipe_error_parsing',
      code: 'parsing-error',
      originalMessage: originalMessage,
    );
  }

  @override
  String toString() => message;
}

