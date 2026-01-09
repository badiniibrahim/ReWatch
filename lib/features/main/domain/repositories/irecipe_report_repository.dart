import '../../../../core/result.dart';
import '../entities/recipe_report.dart';

/// Interface du repository pour les signalements de recettes.
/// 
/// Définit les opérations disponibles pour gérer les signalements
/// de problèmes avec les recettes générées.
abstract class IRecipeReportRepository {
  /// Sauvegarde un signalement de recette.
  /// 
  /// [report] : Le signalement à sauvegarder
  /// 
  /// Retourne un [Result<void>] :
  /// - [Success] si le signalement est sauvegardé avec succès
  /// - [Failure] en cas d'erreur
  Future<Result<void>> saveReport(RecipeReport report);
  
  /// Récupère tous les signalements pour une recette donnée.
  /// 
  /// [recipeId] : L'ID de la recette
  /// 
  /// Retourne un [Result<List<RecipeReport>>] :
  /// - [Success] avec la liste des signalements
  /// - [Failure] en cas d'erreur
  Future<Result<List<RecipeReport>>> getReportsByRecipeId(String recipeId);
  
  /// Récupère tous les signalements pour un utilisateur donné.
  /// 
  /// [userId] : L'ID de l'utilisateur
  /// 
  /// Retourne un [Result<List<RecipeReport>>] :
  /// - [Success] avec la liste des signalements
  /// - [Failure] en cas d'erreur
  Future<Result<List<RecipeReport>>> getReportsByUserId(String userId);
}

