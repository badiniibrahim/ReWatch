import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration de l'environnement de l'application.
///
/// Contient les clés API et autres variables d'environnement.
class Environment {
  /// Clé API Google Gemini.
  ///
  /// Récupérée depuis le fichier .env avec la clé `GEMINI_API_KEY`.
  static String get googleGeminiApiKey {
    final key = dotenv.env['GOOGLE_GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'GOOGLE_GEMINI_API_KEY non trouvée dans le fichier .env. '
        'Veuillez ajouter votre clé API Gemini dans le fichier .env à la racine du projet.',
      );
    }
    return key;
  }

  /// Clé API RevenueCat (peut être la même pour iOS et Android)
  /// Ou utilisez REVENUECAT_API_KEY_IOS et REVENUECAT_API_KEY_ANDROID
  /// pour des clés différentes par plateforme
  static String get revenueCatApiKey => dotenv.env['REVENUECAT_API_KEY'] ?? '';

  /// Clé API RevenueCat pour iOS (optionnelle)
  static String get revenueCatApiKeyIOS =>
      dotenv.env['REVENUECAT_API_KEY_IOS'] ?? revenueCatApiKey;

  /// Clé API RevenueCat pour Android (optionnelle)
  static String get revenueCatApiKeyAndroid =>
      dotenv.env['REVENUECAT_API_KEY_ANDROID'] ?? revenueCatApiKey;
}
