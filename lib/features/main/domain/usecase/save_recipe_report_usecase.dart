import '../../../../core/result.dart';
import '../entities/recipe_report.dart';
import '../repositories/irecipe_report_repository.dart';

/// UseCase pour sauvegarder un signalement de recette.
/// 
/// Orchestre la sauvegarde d'un signalement utilisateur concernant
/// une recette générée.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final useCase = SaveRecipeReportUseCase(repository);
/// final result = await useCase.call(
///   recipeId: 'recipe-id',
///   userId: 'user-id',
///   reason: 'incorrect',
///   tiktokUrl: 'https://www.tiktok.com/@user/video/123',
/// );
/// 
/// result.when(
///   success: (_) => print('Report saved'),
///   failure: (message, code, error) => print('Error: $message'),
/// );
/// ```
class SaveRecipeReportUseCase {
  final IRecipeReportRepository _repository;
  
  /// Crée une nouvelle instance du usecase.
  /// 
  /// [repository] : Repository pour accéder aux données des signalements
  SaveRecipeReportUseCase(this._repository);
  
  /// Exécute le usecase et sauvegarde le signalement.
  /// 
  /// [recipeId] : ID de la recette signalée
  /// [userId] : ID de l'utilisateur qui signale
  /// [reason] : Raison du signalement ('incorrect', 'missing_ingredients', 'wrong_quantities', 'other')
  /// [tiktokUrl] : URL TikTok de la vidéo source (optionnel)
  /// [details] : Détails supplémentaires (optionnel)
  /// 
  /// Retourne un [Result<void>] :
  /// - [Success] si le signalement est sauvegardé
  /// - [Failure] en cas d'erreur
  Future<Result<void>> call({
    required String recipeId,
    required String userId,
    required String reason,
    String? tiktokUrl,
    String? details,
  }) async {
    try {
      // Validation des paramètres
      if (recipeId.isEmpty) {
        return Failure('recipeId cannot be empty', errorCode: 'validation-error');
      }
      
      if (userId.isEmpty) {
        return Failure('userId cannot be empty', errorCode: 'validation-error');
      }
      
      if (reason.isEmpty) {
        return Failure('reason cannot be empty', errorCode: 'validation-error');
      }
      
      // Créer l'entité RecipeReport
      final report = RecipeReport(
        id: '', // L'ID sera généré par Firestore
        recipeId: recipeId,
        userId: userId,
        reason: reason,
        tiktokUrl: tiktokUrl,
        details: details,
        createdAt: DateTime.now(),
      );
      
      // Sauvegarder via le repository
      return await _repository.saveReport(report);
    } catch (e) {
      return Failure(
        'Erreur lors de la sauvegarde du signalement',
        errorCode: 'save-error',
        error: e,
      );
    }
  }
}

