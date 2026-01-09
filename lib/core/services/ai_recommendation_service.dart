import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'tmdb_service.dart';

class AiRecommendationService {
  late final GenerativeModel _model;
  final TmdbService _tmdbService;

  AiRecommendationService(this._tmdbService) {
    final apiKey = dotenv.env['GOOGLE_GEMINI_API_KEY'];
    if (apiKey == null) {
      if (kDebugMode) {
        print('❌ AiRecommendationService: GOOGLE_GEMINI_API_KEY manquant');
      }
      return;
    }
    _model = GenerativeModel(model: 'gemini-3-pro-preview', apiKey: apiKey);
  }

  /// Génère des recommandations basées sur l'humeur
  Future<List<TmdbResult>> getRecommendations(String mood) async {
    try {
      if (dotenv.env['GOOGLE_GEMINI_API_KEY'] == null) {
        throw Exception('Clé API Gemini manquante');
      }

      final prompt =
          '''
      Tu es un expert en cinéma. Je veux que tu me recommandes 5 films ou séries basés sur cette envie/humeur : "$mood".
      
      Règles strictes :
      1. Retourne UNIQUEMENT un tableau JSON de chaînes de caractères contenant les titres exacts.
      2. Pas de texte avant ou après le JSON.
      3. Pas de markdown (ne mets pas ```json ... ```).
      4. Priorise les contenus populaires et bien notés.
      
      Exemple de réponse attendue :
      ["Inception", "Interstellar", "Dark", "Tenet", "Arrival"]
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final responseText = response.text;
      if (responseText == null) return [];

      // Nettoyage au cas où Gemini ajoute du markdown malgré les instructions
      final cleanedText = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final List<dynamic> titles = jsonDecode(cleanedText);

      final List<TmdbResult> results = [];

      for (final title in titles) {
        // Recherche sur TMDB pour récupérer les infos (images, etc.)
        final searchResults = await _tmdbService.search(title.toString());
        if (searchResults.isNotEmpty) {
          // On prend le premier résultat pertinent
          results.add(searchResults.first);
        }
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur AI Recommendations: $e');
      }
      return [];
    }
  }
}
