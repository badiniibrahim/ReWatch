import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/environment.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/exceptions/recipe_generation_exception.dart';

/// Service de génération de recettes structurées à partir de texte avec Gemini API.
///
/// Ce service utilise Gemini API pour générer des recettes structurées en JSON
/// à partir de transcriptions audio et de captions TikTok.
///
/// Exemple d'utilisation :
/// ```dart
/// final service = Get.find<RecipeAIService>();
/// final recipe = await service.generateRecipe(
///   transcription: 'Ajoutez 200g de farine...',
///   caption: 'Gâteau au chocolat facile',
/// );
/// ```
class RecipeAIService extends GetxService {
  late Dio _dio;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (kDebugMode) {
      debugPrint('🚀 Initializing RecipeAIService...');
    }
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    _setupInterceptors();

    // Vérifier que la clé API est disponible
    try {
      final apiKey = Environment.googleGeminiApiKey;
      if (kDebugMode) {
        debugPrint('✅ Gemini API Key loaded: ${apiKey.substring(0, 10)}...');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading Gemini API Key: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('✅ RecipeAIService initialized successfully');
    }
  }

  void _setupInterceptors() {
    if (kDebugMode) {
      debugPrint('🔧 Setting up HTTP interceptors...');
    }
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            debugPrint('📤 HTTP Request: ${options.method} ${options.uri}');
          }
          try {
            final apiKey = Environment.googleGeminiApiKey;
            options.headers['x-goog-api-key'] = apiKey;
            options.headers['Content-Type'] = 'application/json';
            if (kDebugMode) {
              debugPrint('✅ API Key set: ${apiKey.substring(0, 10)}...');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ Error getting API key: $e');
            }
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'API Key not found',
                type: DioExceptionType.unknown,
              ),
            );
            return;
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('📥 HTTP Response: ${response.statusCode}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint('❌ Gemini API Error: ${error.message}');
            debugPrint('❌ Error type: ${error.type}');
            debugPrint('❌ Error response: ${error.response?.data}');
            debugPrint('❌ Error status code: ${error.response?.statusCode}');
            debugPrint('❌ Error request path: ${error.requestOptions.path}');
            debugPrint('❌ Error request data: ${error.requestOptions.data}');
            if (error.error != null) {
              debugPrint('❌ Error underlying: ${error.error}');
            }
          }
          handler.next(error);
        },
      ),
    );
    if (kDebugMode) {
      debugPrint('✅ HTTP interceptors configured');
    }
  }

  /// Génère une recette structurée à partir d'une transcription et d'un caption.
  ///
  /// [transcription] : Transcription audio de la vidéo
  /// [caption] : Caption/Texte de la vidéo TikTok (optionnel)
  ///
  /// Retourne une [Recipe] générée avec les ingrédients et étapes extraits.
  Future<Recipe> generateRecipe({
    required String transcription,
    String? caption,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🎯 Generating recipe from transcription...');
        debugPrint(
          '📝 Transcription: ${transcription.substring(0, transcription.length > 100 ? 100 : transcription.length)}...',
        );
        debugPrint('📝 Caption: ${caption ?? 'N/A'}');
      }

      final prompt = _buildPrompt(transcription, caption);

      final requestData = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        },
      };

      if (kDebugMode) {
        debugPrint('📤 Sending request to Gemini API...');
      }

      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent',
        data: requestData,
      );

      if (kDebugMode) {
        debugPrint('📥 Received response from Gemini API');
        debugPrint('📥 Response status: ${response.statusCode}');
      }

      // Extraire le texte de la réponse
      final candidates = response.data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Aucune réponse de Gemini');
      }

      final candidate = candidates[0] as Map<String, dynamic>;
      final content = candidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;

      if (parts == null || parts.isEmpty) {
        throw Exception('Aucune partie de contenu dans la réponse');
      }

      final textPart = parts[0] as Map<String, dynamic>?;
      final text = textPart?['text'] as String?;

      if (text == null || text.isEmpty) {
        throw Exception('Réponse vide de Gemini');
      }

      if (kDebugMode) {
        debugPrint(
          '📥 Gemini response text: ${text.substring(0, text.length > 200 ? 200 : text.length)}...',
        );
      }

      // Parser la réponse JSON
      final recipe = _parseGeminiResponse(text);

      if (kDebugMode) {
        debugPrint('✅ Recipe generated successfully: ${recipe.title}');
      }

      return recipe;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DioException in generateRecipe: ${e.message}');
        debugPrint('❌ Error type: ${e.type}');
        debugPrint('❌ Error response: ${e.response?.data}');
        debugPrint('❌ Error status code: ${e.response?.statusCode}');
      }

      // Améliorer les messages d'erreur
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Timeout de connexion. Vérifiez votre connexion internet et réessayez.',
        );
      }
      if (e.response?.statusCode == 401) {
        throw Exception(
          'Clé API invalide. Vérifiez votre clé API Google Gemini.',
        );
      }
      if (e.response?.statusCode == 429) {
        throw Exception('Quota API dépassé. Veuillez réessayer plus tard.');
      }
      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        throw Exception(
          'Erreur serveur. Veuillez réessayer dans quelques instants.',
        );
      }

      throw Exception(
        'Erreur lors de la génération de la recette: ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error in generateRecipe: $e');
        debugPrint('❌ Error type: ${e.runtimeType}');
      }
      throw Exception(
        'Erreur inattendue lors de la génération de la recette: $e',
      );
    }
  }

  /// Génère une recette structurée à partir de la légende TikTok uniquement.
  ///
  /// Cette méthode est utilisée en priorité (ordre ReciMe) pour extraire
  /// la recette directement depuis la légende de la vidéo TikTok.
  ///
  /// [caption] : Légende/Caption de la vidéo TikTok
  ///
  /// Retourne une [Recipe] générée depuis la légende.
  Future<Recipe> generateRecipeFromCaption({required String caption}) async {
    try {
      if (kDebugMode) {
        debugPrint('🎯 Generating recipe from caption...');
        debugPrint(
          '📝 Caption: ${caption.substring(0, caption.length > 100 ? 100 : caption.length)}...',
        );
      }

      final prompt = _buildCaptionPrompt(caption);

      final requestData = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        },
      };

      if (kDebugMode) {
        debugPrint('📤 Sending request to Gemini API...');
      }

      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent',
        data: requestData,
      );

      if (kDebugMode) {
        debugPrint('📥 Received response from Gemini API');
        debugPrint('📥 Response status: ${response.statusCode}');
      }

      // Extraire le texte de la réponse
      final candidates = response.data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Aucune réponse de Gemini');
      }

      final candidate = candidates[0] as Map<String, dynamic>;
      final content = candidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;

      if (parts == null || parts.isEmpty) {
        throw Exception('Aucune partie de contenu dans la réponse');
      }

      final textPart = parts[0] as Map<String, dynamic>?;
      final text = textPart?['text'] as String?;

      if (text == null || text.isEmpty) {
        throw Exception('Réponse vide de Gemini');
      }

      if (kDebugMode) {
        debugPrint(
          '📥 Gemini response text: ${text.substring(0, text.length > 200 ? 200 : text.length)}...',
        );
      }

      // Parser la réponse JSON
      final recipe = _parseGeminiResponse(text);

      if (kDebugMode) {
        debugPrint(
          '✅ Recipe generated successfully from caption: ${recipe.title}',
        );
      }

      return recipe;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DioException in generateRecipeFromCaption: ${e.message}');
        debugPrint('❌ Error type: ${e.type}');
        debugPrint('❌ Error response: ${e.response?.data}');
        debugPrint('❌ Error status code: ${e.response?.statusCode}');
        if (e.error != null) {
          debugPrint('❌ Error underlying: ${e.error}');
        }
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Timeout de connexion. Vérifiez votre connexion internet et réessayez.',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Erreur de connexion. Vérifiez votre connexion internet et réessayez.',
        );
      }

      if (e.response?.statusCode == 401) {
        throw Exception(
          'Clé API invalide. Vérifiez votre clé API Google Gemini dans le fichier .env.',
        );
      }

      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (kDebugMode) {
          debugPrint('❌ Bad Request details: $errorData');
        }
        throw Exception(
          'Requête invalide. Vérifiez le format de votre requête.',
        );
      }

      if (e.response?.statusCode == 429) {
        throw Exception('Quota API dépassé. Veuillez réessayer plus tard.');
      }

      if (e.response?.statusCode != null) {
        throw Exception(
          'Erreur API (${e.response!.statusCode}): ${e.response?.data ?? e.message ?? 'Erreur inconnue'}',
        );
      }

      throw Exception(
        'Erreur de connexion: ${e.message ?? 'Vérifiez votre connexion internet'}',
      );
    } on RecipeGenerationException {
      // Re-lancer les exceptions personnalisées telles quelles
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error in generateRecipeFromCaption: $e');
        debugPrint('❌ Error type: ${e.runtimeType}');
      }
      throw Exception(
        'Erreur inattendue lors de la génération de la recette: $e',
      );
    }
  }

  /// Analyse une image de plat avec Gemini et extrait les informations nutritionnelles.
  ///
  /// [imageUrl] : URL de l'image à analyser (thumbnail TikTok)
  /// [ingredients] : Liste des ingrédients de la recette pour contexte
  /// [servings] : Nombre de portions
  ///
  /// Retourne une [Nutrition] avec les macros estimées.
  Future<Nutrition> analyzeNutritionFromImage({
    required String imageUrl,
    required List<Ingredient> ingredients,
    required int servings,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🍎 Analyzing nutrition from image: $imageUrl');
      }

      // Télécharger l'image
      final imageResponse = await http.get(Uri.parse(imageUrl));
      if (imageResponse.statusCode != 200) {
        throw Exception('Impossible de télécharger l\'image');
      }

      // Convertir en base64
      final imageBytes = imageResponse.bodyBytes;
      final base64Image = base64Encode(imageBytes);

      // Construire la liste des ingrédients pour le contexte
      final ingredientsText = ingredients
          .map((ing) => '${ing.quantity} ${ing.unit} de ${ing.name}')
          .join(', ');

      final prompt = _buildNutritionPrompt(ingredientsText, servings);

      final requestData = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image},
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.3,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
      };

      if (kDebugMode) {
        debugPrint('📤 Sending nutrition analysis request to Gemini API...');
      }

      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent',
        data: requestData,
      );

      if (kDebugMode) {
        debugPrint('📥 Received nutrition response from Gemini API');
        debugPrint('📥 Response status: ${response.statusCode}');
      }

      // Extraire le texte de la réponse
      final candidates = response.data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Aucune réponse de Gemini');
      }

      final candidate = candidates[0] as Map<String, dynamic>;
      final content = candidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;

      if (parts == null || parts.isEmpty) {
        throw Exception('Aucune partie de contenu dans la réponse');
      }

      final textPart = parts[0] as Map<String, dynamic>?;
      final text = textPart?['text'] as String?;

      if (text == null || text.isEmpty) {
        throw Exception('Réponse vide de Gemini');
      }

      if (kDebugMode) {
        debugPrint(
          '📥 Gemini nutrition response: ${text.substring(0, text.length > 200 ? 200 : text.length)}...',
        );
      }

      // Parser la réponse JSON
      final nutrition = _parseNutritionResponse(text);

      if (kDebugMode) {
        debugPrint(
          '✅ Nutrition analyzed successfully: ${nutrition.calories} kcal',
        );
      }

      return nutrition;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DioException in analyzeNutritionFromImage: ${e.message}');
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Timeout de connexion. Vérifiez votre connexion internet et réessayez.',
        );
      }
      if (e.response?.statusCode == 401) {
        throw Exception(
          'Clé API invalide. Vérifiez votre clé API Google Gemini.',
        );
      }
      if (e.response?.statusCode == 429) {
        throw Exception('Quota API dépassé. Veuillez réessayer plus tard.');
      }

      throw Exception('Erreur lors de l\'analyse nutritionnelle: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error in analyzeNutritionFromImage: $e');
      }
      throw Exception(
        'Erreur inattendue lors de l\'analyse nutritionnelle: $e',
      );
    }
  }

  /// Construit le prompt pour l'analyse nutritionnelle.
  String _buildNutritionPrompt(String ingredientsText, int servings) {
    return '''Tu es un expert en nutrition. Analyse cette image de plat et estime les valeurs nutritionnelles pour $servings portions.

Ingrédients de la recette: $ingredientsText

Génère UNIQUEMENT un JSON valide avec cette structure exacte (sans markdown, sans code blocks, juste le JSON brut):
{
  "calories": 450.0,
  "proteins": 25.0,
  "carbohydrates": 40.0,
  "fats": 20.0,
  "fiber": 5.0,
  "sugar": 8.0,
  "salt": 2.0
}

Règles importantes:
- Les valeurs sont pour $servings portions au total
- Utilise les ingrédients listés pour estimer les valeurs
- Analyse l'image pour affiner les estimations (quantités visibles, type de cuisson, etc.)
- Les valeurs doivent être réalistes et cohérentes
- Réponds UNIQUEMENT avec le JSON, sans texte avant ou après''';
  }

  /// Parse la réponse JSON de Gemini en Nutrition.
  Nutrition _parseNutritionResponse(String text) {
    try {
      // Nettoyer le texte (enlever markdown code blocks si présents)
      String cleanedText = text.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      }
      if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      // Parser le JSON
      final jsonData = json.decode(cleanedText) as Map<String, dynamic>;

      return Nutrition(
        calories: (jsonData['calories'] as num?)?.toDouble() ?? 0.0,
        proteins: (jsonData['proteins'] as num?)?.toDouble() ?? 0.0,
        carbohydrates: (jsonData['carbohydrates'] as num?)?.toDouble() ?? 0.0,
        fats: (jsonData['fats'] as num?)?.toDouble() ?? 0.0,
        fiber: (jsonData['fiber'] as num?)?.toDouble(),
        sugar: (jsonData['sugar'] as num?)?.toDouble(),
        salt: (jsonData['salt'] as num?)?.toDouble(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error parsing nutrition response: $e');
      }
      throw Exception(
        'Erreur lors du parsing de la réponse nutritionnelle: $e',
      );
    }
  }

  /// Construit le prompt pour Gemini API depuis une transcription.
  String _buildPrompt(String transcription, String? caption) {
    return '''Tu es un expert en cuisine. Analyse cette transcription audio d'une vidéo TikTok de recette et génère une recette structurée en JSON.

Transcription audio: $transcription
${caption != null ? 'Légende TikTok: $caption' : ''}

Génère UNIQUEMENT un JSON valide avec cette structure exacte (sans markdown, sans code blocks, juste le JSON brut):
{
  "title": "Titre de la recette",
  "description": "Description courte de la recette",
  "servings": 4,
  "prepMinutes": 15,
  "cookMinutes": 30,
  "ingredients": [
    {"name": "Farine", "quantity": 200, "unit": "g", "note": null}
  ],
  "steps": [
    {"number": 1, "description": "Description détaillée de l'étape", "durationMinutes": 5}
  ]
}

Règles importantes:
- Extrais TOUS les ingrédients mentionnés avec leurs quantités exactes
- Extrais TOUTES les étapes de préparation dans l'ordre
- Utilise les unités françaises (g, ml, pièce, c. à s., etc.)
- Les durées sont en minutes
- Le nombre de portions doit être réaliste
- Réponds UNIQUEMENT avec le JSON, sans texte avant ou après''';
  }

  /// Construit le prompt pour Gemini API depuis une légende TikTok.
  String _buildCaptionPrompt(String caption) {
    return '''Tu es un expert en cuisine. Analyse cette légende TikTok de recette et génère une recette structurée en JSON.

Légende TikTok: $caption

Génère UNIQUEMENT un JSON valide avec cette structure exacte (sans markdown, sans code blocks, juste le JSON brut):
{
  "title": "Titre de la recette",
  "description": "Description courte de la recette",
  "servings": 4,
  "prepMinutes": 15,
  "cookMinutes": 30,
  "ingredients": [
    {"name": "Farine", "quantity": 200, "unit": "g", "note": null}
  ],
  "steps": [
    {"number": 1, "description": "Description détaillée de l'étape", "durationMinutes": 5}
  ]
}

Règles importantes:
- Extrais TOUS les ingrédients mentionnés avec leurs quantités exactes
- Extrais TOUTES les étapes de préparation dans l'ordre
- Utilise les unités françaises (g, ml, pièce, c. à s., etc.)
- Les durées sont en minutes
- Le nombre de portions doit être réaliste
- Si des informations manquent, utilise des valeurs par défaut réalistes
- Réponds UNIQUEMENT avec le JSON, sans texte avant ou après''';
  }

  /// Parse la réponse JSON de Gemini en Recipe.
  Recipe _parseGeminiResponse(String text) {
    try {
      // Nettoyer le texte (enlever markdown code blocks si présents)
      String cleanedText = text.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      }
      if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      // Parser le JSON
      final jsonData = json.decode(cleanedText) as Map<String, dynamic>;

      // Extraire les données
      final title = jsonData['title'] as String? ?? 'Recette générée';
      final description = jsonData['description'] as String?;
      final servings = jsonData['servings'] as int? ?? 4;
      final prepMinutes = jsonData['prepMinutes'] as int? ?? 15;
      final cookMinutes = jsonData['cookMinutes'] as int? ?? 30;

      // Parser les ingrédients
      final ingredientsList = jsonData['ingredients'] as List? ?? [];
      final ingredients = ingredientsList.map((ing) {
        final ingMap = ing as Map<String, dynamic>;
        return Ingredient(
          name: ingMap['name'] as String? ?? 'Ingrédient',
          quantity: (ingMap['quantity'] as num?)?.toDouble() ?? 1.0,
          unit: ingMap['unit'] as String? ?? 'portion',
          note: ingMap['note'] as String?,
        );
      }).toList();

      // Parser les étapes
      final stepsList = jsonData['steps'] as List? ?? [];
      final steps = stepsList.map((step) {
        final stepMap = step as Map<String, dynamic>;
        return RecipeStep(
          number: stepMap['number'] as int? ?? 1,
          description: stepMap['description'] as String? ?? 'Étape',
          durationMinutes: stepMap['durationMinutes'] as int?,
        );
      }).toList();

      return Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        servings: servings,
        prepMinutes: prepMinutes,
        cookMinutes: cookMinutes,
        ingredients: ingredients,
        steps: steps,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on FormatException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error parsing Gemini response: $e');
        debugPrint('❌ Response text: $text');
      }
      // Vérifier si c'est une erreur de légende insuffisante
      if (text.toLowerCase().contains('ne contient pas suffisamment') ||
          text.toLowerCase().contains('trop vague') ||
          text.toLowerCase().contains('pas suffisamment d\'informations') ||
          text.toLowerCase().contains('je ne peux pas générer')) {
        throw RecipeGenerationException.insufficientCaption(
          originalMessage: text,
        );
      }
      throw RecipeGenerationException.parsingError(
        originalError: e.toString(),
        originalMessage: text,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error parsing Gemini response: $e');
        debugPrint('❌ Response text: $text');
      }
      throw RecipeGenerationException.parsingError(
        originalError: e.toString(),
        originalMessage: text,
      );
    }
  }
}
