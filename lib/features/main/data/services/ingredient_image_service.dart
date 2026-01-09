import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Service pour récupérer les images d'ingrédients.
///
/// Utilise l'API Unsplash pour récupérer des images de qualité
/// pour chaque ingrédient.
///
/// Exemple :
/// ```dart
/// final service = Get.find<IngredientImageService>();
/// final imageUrl = await service.getIngredientImage('tomate');
/// ```
class IngredientImageService extends GetxService {
  late Dio _dio;
  
  // Cache pour éviter de refaire les mêmes requêtes
  final Map<String, String?> _imageCache = {};
  
  // Utilisation de l'API Spoonacular pour les images d'ingrédients
  // API gratuite: 150 requêtes/jour (sans clé API) ou 1500 requêtes/jour (avec clé API gratuite)
  // Documentation: https://spoonacular.com/food-api
  // Format d'URL: https://spoonacular.com/cdn/ingredients_100x100/{ingredient-name}.jpg
  
  // Alternative: utiliser l'API Unsplash (nécessite une clé API)
  // ou utiliser des assets locaux pour les ingrédients les plus communs
  
  @override
  Future<void> onInit() async {
    super.onInit();
    if (kDebugMode) {
      debugPrint('🚀 Initializing IngredientImageService...');
    }
    
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept-Version': 'v1',
        },
      ),
    );
    
    if (kDebugMode) {
      debugPrint('✅ IngredientImageService initialized');
    }
  }
  
  /// Récupère l'URL d'une image pour un ingrédient.
  ///
  /// [ingredientName] : Nom de l'ingrédient (ex: "tomate", "poulet")
  ///
  /// Retourne l'URL de l'image ou null si aucune image n'est trouvée.
  ///
  /// Les résultats sont mis en cache pour éviter les requêtes répétées.
  Future<String?> getIngredientImage(String ingredientName) async {
    if (ingredientName.isEmpty) {
      return null;
    }
    
    // Normaliser le nom de l'ingrédient (minuscules, sans accents si possible)
    final normalizedName = _normalizeIngredientName(ingredientName);
    
    // Vérifier le cache
    if (_imageCache.containsKey(normalizedName)) {
      return _imageCache[normalizedName];
    }
    
    try {
      if (kDebugMode) {
        debugPrint('🔍 Searching image for ingredient: $ingredientName');
      }
      
      // Utiliser l'API Spoonacular pour obtenir l'image d'un ingrédient
      // Format: https://spoonacular.com/cdn/ingredients_100x100/{ingredient-name}.jpg
      // Cette URL fonctionne sans clé API et retourne directement l'image
      // Le nom est déjà normalisé avec des tirets par _normalizeIngredientName
      final imageUrl = 'https://spoonacular.com/cdn/ingredients_100x100/$normalizedName.jpg';
      
      // Vérifier si l'image existe en faisant une requête HEAD
      try {
        final headResponse = await _dio.head(
          imageUrl,
          options: Options(
            followRedirects: false,
            validateStatus: (status) => status != null && status < 500,
          ),
        );
        
        if (headResponse.statusCode == 200) {
          // L'image existe, la mettre en cache
          _imageCache[normalizedName] = imageUrl;
          
          if (kDebugMode) {
            debugPrint('✅ Image found for $ingredientName: $imageUrl');
          }
          
          return imageUrl;
        }
      } catch (e) {
        // Si la requête HEAD échoue, l'image n'existe probablement pas
        if (kDebugMode) {
          debugPrint('⚠️ No image found for $ingredientName (normalized: $normalizedName)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error fetching image for $ingredientName: $e');
      }
      // En cas d'erreur, ne pas mettre null en cache pour permettre de réessayer
    }
    
    // Si aucune image n'est trouvée, mettre null en cache
    _imageCache[normalizedName] = null;
    return null;
  }
  
  /// Normalise le nom de l'ingrédient pour améliorer la recherche.
  ///
  /// Supprime les accents, convertit en minuscules, et nettoie le texte.
  /// Essaie aussi de traduire les noms français en anglais pour Spoonacular.
  String _normalizeIngredientName(String name) {
    // Convertir en minuscules
    var normalized = name.toLowerCase().trim();
    
    // Supprimer les quantités et unités communes au début
    final quantityPattern = RegExp(r'^\d+\s*(g|kg|ml|l|cl|dl|cuillère|cuillères|tasse|tasses|pincée|pincées)\s+');
    normalized = normalized.replaceAll(quantityPattern, '');
    
    // Supprimer "de" au début
    if (normalized.startsWith('de ')) {
      normalized = normalized.substring(3);
    }
    
    // Supprimer les notes entre parenthèses
    normalized = normalized.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
    
    // Traduire les noms français communs en anglais pour Spoonacular
    normalized = _translateToEnglish(normalized);
    
    // Normaliser les accents (simplifié)
    normalized = normalized
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ç', 'c');
    
    // Remplacer les espaces par des tirets (format Spoonacular)
    normalized = normalized.replaceAll(RegExp(r'\s+'), '-');
    
    return normalized.trim();
  }
  
  /// Traduit les noms d'ingrédients français communs en anglais.
  ///
  /// Spoonacular utilise principalement des noms en anglais.
  String _translateToEnglish(String name) {
    // Dictionnaire de traduction français -> anglais pour les ingrédients communs
    final translations = {
      'tomate': 'tomato',
      'oignon': 'onion',
      'ail': 'garlic',
      'poulet': 'chicken',
      'boeuf': 'beef',
      'porc': 'pork',
      'poisson': 'fish',
      'crevette': 'shrimp',
      'saumon': 'salmon',
      'fromage': 'cheese',
      'lait': 'milk',
      'creme': 'cream',
      'beurre': 'butter',
      'huile': 'oil',
      'farine': 'flour',
      'sucre': 'sugar',
      'sel': 'salt',
      'poivre': 'pepper',
      'epices': 'spices',
      'herbes': 'herbs',
      'basilic': 'basil',
      'persil': 'parsley',
      'thym': 'thyme',
      'romarin': 'rosemary',
      'carotte': 'carrot',
      'pomme de terre': 'potato',
      'pomme': 'apple',
      'banane': 'banana',
      'citron': 'lemon',
      'orange': 'orange',
      'champignon': 'mushroom',
      'epinard': 'spinach',
      'salade': 'lettuce',
      'concombre': 'cucumber',
      'avocat': 'avocado',
      'riz': 'rice',
      'pates': 'pasta',
      'pain': 'bread',
      'oeuf': 'egg',
      'oeufs': 'eggs',
    };
    
    // Chercher une traduction exacte
    if (translations.containsKey(name)) {
      return translations[name]!;
    }
    
    // Chercher une traduction partielle (si le nom contient le mot français)
    for (final entry in translations.entries) {
      if (name.contains(entry.key)) {
        return name.replaceAll(entry.key, entry.value);
      }
    }
    
    // Si aucune traduction trouvée, retourner le nom original
    return name;
  }
  
  /// Vide le cache des images.
  void clearCache() {
    _imageCache.clear();
    if (kDebugMode) {
      debugPrint('🗑️ Ingredient image cache cleared');
    }
  }
  
  /// Récupère plusieurs images d'ingrédients en parallèle.
  ///
  /// [ingredientNames] : Liste des noms d'ingrédients
  ///
  /// Retourne une Map avec les noms d'ingrédients comme clés et les URLs d'images comme valeurs.
  Future<Map<String, String?>> getIngredientImages(List<String> ingredientNames) async {
    final results = <String, String?>{};
    
    // Récupérer les images en parallèle
    final futures = ingredientNames.map((name) async {
      final imageUrl = await getIngredientImage(name);
      return MapEntry(name, imageUrl);
    });
    
    final entries = await Future.wait(futures);
    for (final entry in entries) {
      results[entry.key] = entry.value;
    }
    
    return results;
  }
}

