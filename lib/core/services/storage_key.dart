/// Clés de stockage local utilisées dans l'application.
/// 
/// Centralise toutes les clés pour éviter les erreurs de typage
/// et faciliter la maintenance.
class StorageKey {
  StorageKey._();

  /// Indique si l'onboarding a été complété.
  static const String onboardingCompleted = 'onboarding_completed';
  
  /// Token d'authentification (optionnel, si stocké localement).
  static const String authToken = 'auth_token';
  
  /// ID de l'utilisateur actuel.
  static const String userId = 'user_id';
  
  /// Préférences utilisateur.
  static const String userPreferences = 'user_preferences';
  
  /// Langue sélectionnée par l'utilisateur ('fr' ou 'en').
  /// Si null, utilise la langue du téléphone.
  static const String selectedLanguage = 'selected_language';
}

