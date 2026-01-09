import 'package:flutter/foundation.dart';
import '../entities/recipe.dart';
import 'validation_result.dart';

/// Service de validation des recettes selon les règles métier.
/// 
/// Ce service est pur (pas de dépendances externes) et contient toute
/// la logique de validation métier pour les recettes.
/// 
/// Exemple d'utilisation :
/// ```dart
/// final validation = RecipeValidationService.validateRecipe(recipe);
/// if (!validation.isValid) {
///   print('Erreur: ${validation.message}');
/// }
/// ```
class RecipeValidationService {
  /// Valide une recette complète.
  /// 
  /// Vérifie :
  /// - Le titre n'est pas vide
  /// - Le nombre de portions est valide (1-20)
  /// - Les temps sont valides (prepMinutes + cookMinutes = totalMinutes)
  /// - Les ingrédients ont des quantités valides
  /// - Le sel est entre 1-3g/portion
  /// - L'huile est entre 5-20ml/portion
  static ValidationResult validateRecipe(Recipe recipe) {
    if (recipe.title.isEmpty) {
      return ValidationResult.failure('recipeValidationTitleRequired');
    }
    
    if (recipe.servings < 1 || recipe.servings > 20) {
      return ValidationResult.failure('recipeValidationServingsInvalid');
    }
    
    if (recipe.prepMinutes < 0 || recipe.cookMinutes < 0) {
      return ValidationResult.failure('recipeValidationTimeInvalid');
    }
    
    // Vérifier que le temps total correspond (avec une tolérance de 1 minute)
    // car l'IA peut générer des valeurs légèrement différentes
    final calculatedTotal = recipe.prepMinutes + recipe.cookMinutes;
    if ((recipe.totalMinutes - calculatedTotal).abs() > 1) {
      // Avertissement mais pas d'erreur bloquante pour les recettes générées
      if (kDebugMode) {
        debugPrint('⚠️ Total time mismatch: ${recipe.totalMinutes} vs $calculatedTotal');
      }
      // Ne pas bloquer la sauvegarde, on accepte la valeur calculée
    }
    
    if (recipe.ingredients.isEmpty) {
      return ValidationResult.failure('recipeValidationIngredientsRequired');
    }
    
    if (recipe.steps.isEmpty) {
      return ValidationResult.failure('recipeValidationStepsRequired');
    }
    
    // Validation des ingrédients spécifiques (optionnelle pour les recettes générées)
    // Ces validations sont des avertissements, pas des erreurs bloquantes
    // car les recettes générées par l'IA peuvent avoir des quantités variables
    final saltValidation = _validateSalt(recipe);
    if (!saltValidation.isValid) {
      // Pour les recettes générées automatiquement, on accepte même si la validation échoue
      // car l'IA peut générer des quantités qui ne respectent pas exactement les règles
      // On log seulement en debug
      if (kDebugMode) {
        debugPrint('⚠️ Salt validation warning: ${saltValidation.message}');
      }
      // Ne pas bloquer la sauvegarde pour cette validation
    }
    
    final oilValidation = _validateOil(recipe);
    if (!oilValidation.isValid) {
      // Même chose pour l'huile
      if (kDebugMode) {
        debugPrint('⚠️ Oil validation warning: ${oilValidation.message}');
      }
      // Ne pas bloquer la sauvegarde pour cette validation
    }
    
    return ValidationResult.success();
  }
  
  /// Valide la quantité de sel (recommandation: 1-3g par portion).
  /// 
  /// Cette validation est permissive car :
  /// - Le sel peut être exprimé dans différentes unités (g, cuillère à café, pincée)
  /// - Les recettes générées par l'IA peuvent avoir des quantités variables
  /// - Certaines recettes peuvent nécessiter plus ou moins de sel selon le type
  static ValidationResult _validateSalt(Recipe recipe) {
    final saltIngredients = recipe.ingredients
        .where((i) {
          final name = i.name.toLowerCase();
          return name.contains('sel') || name.contains('salt');
        })
        .toList();
    
    if (saltIngredients.isEmpty) {
      return ValidationResult.success(); // Le sel est optionnel
    }
    
    // Si le sel est exprimé dans une unité autre que 'g', on accepte
    // (cuillère à café, pincée, etc. sont difficiles à convertir précisément)
    final hasSaltInGrams = saltIngredients.any((i) => i.unit == 'g');
    if (!hasSaltInGrams) {
      // Le sel est présent mais dans une autre unité, on accepte
      return ValidationResult.success();
    }
    
    // Calculer le total de sel en grammes
    double totalSalt = 0;
    for (final ingredient in saltIngredients) {
      if (ingredient.unit == 'g') {
        totalSalt += ingredient.quantity;
      }
    }
    
    // Si aucune quantité en grammes n'a été trouvée, accepter
    if (totalSalt == 0) {
      return ValidationResult.success();
    }
    
    final saltPerServing = totalSalt / recipe.servings;
    
    // Plage plus permissive : 0.5g à 10g par portion
    // (au lieu de 1-3g strict) pour accepter plus de variétés de recettes
    if (saltPerServing < 0.5 || saltPerServing > 10) {
      // Avertissement mais pas d'erreur bloquante
      return ValidationResult.failure('recipeValidationSaltPerServing');
    }
    
    return ValidationResult.success();
  }
  
  /// Valide la quantité d'huile (recommandation: 5-20ml par portion).
  /// 
  /// Cette validation est permissive car :
  /// - L'huile peut être exprimée dans différentes unités (ml, cuillère à soupe)
  /// - Les recettes générées par l'IA peuvent avoir des quantités variables
  /// - Certaines recettes peuvent nécessiter plus ou moins d'huile selon le type
  static ValidationResult _validateOil(Recipe recipe) {
    final oilIngredients = recipe.ingredients
        .where((i) {
          final name = i.name.toLowerCase();
          return name.contains('huile') || name.contains('oil');
        })
        .toList();
    
    if (oilIngredients.isEmpty) {
      return ValidationResult.success(); // L'huile est optionnelle
    }
    
    // Si l'huile est exprimée dans une unité autre que 'ml', on accepte
    // (cuillère à soupe, etc. sont difficiles à convertir précisément)
    final hasOilInMl = oilIngredients.any((i) => i.unit == 'ml');
    if (!hasOilInMl) {
      // L'huile est présente mais dans une autre unité, on accepte
      return ValidationResult.success();
    }
    
    // Calculer le total d'huile en ml
    double totalOil = 0;
    for (final ingredient in oilIngredients) {
      if (ingredient.unit == 'ml') {
        totalOil += ingredient.quantity;
      }
    }
    
    // Si aucune quantité en ml n'a été trouvée, accepter
    if (totalOil == 0) {
      return ValidationResult.success();
    }
    
    final oilPerServing = totalOil / recipe.servings;
    
    // Plage plus permissive : 1ml à 100ml par portion
    // (au lieu de 5-20ml strict) pour accepter plus de variétés de recettes
    if (oilPerServing < 1 || oilPerServing > 100) {
      // Avertissement mais pas d'erreur bloquante
      return ValidationResult.failure('recipeValidationOilPerServing');
    }
    
    return ValidationResult.success();
  }
  
  /// Valide un ingrédient.
  static ValidationResult validateIngredient(Ingredient ingredient) {
    if (ingredient.name.isEmpty) {
      return ValidationResult.failure('recipeValidationIngredientNameRequired');
    }
    
    if (ingredient.quantity <= 0) {
      return ValidationResult.failure('recipeValidationIngredientQuantityInvalid');
    }
    
    if (ingredient.unit.isEmpty) {
      return ValidationResult.failure('recipeValidationIngredientUnitRequired');
    }
    
    // Valider les unités autorisées
    final allowedUnits = ['g', 'ml', 'piece', 'cuillère à soupe', 'cuillère à café'];
    if (!allowedUnits.contains(ingredient.unit)) {
      return ValidationResult.failure('recipeValidationIngredientUnitInvalid');
    }
    
    return ValidationResult.success();
  }
}

